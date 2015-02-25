# rubocop:disable Metrics/ClassLength
class AccountsController < ApplicationController
  helper :Projects

  before_action :set_account, only: [:destroy, :show, :update, :edit, :commits_by_project_chart,
                                     :commits_by_language_chart, :confirm_delete, :make_spammer,
                                     :activate, :languages]
  # FIXME: Add the disabled view
  before_action :redirect_if_disabled, only: [:show, :update, :edit, :commits_by_project_chart,
                                              :commits_by_language_chart]
  before_action :check_activation, only: [:activate]
  before_action :deleted_account?, only: :destroy_feedback
  before_action :disabled_during_read_only_mode, only: [:new, :create, :edit, :update, :activate]
  # later: FIXME: Integrate these actions.
  # before_action :set_smart_sort, only: [:index]
  before_action :session_required, only: [:edit, :destroy, :confirm_delete]
  before_action :must_own_account, only: [:edit, :update, :destroy, :confirm_delete]
  before_action :check_banned_domain, only: :create
  before_action :captcha_response, only: :create
  before_action :account_context, only: :edit
  # FIXME: params[:_action] does not seem to be passed anywhere, but staging db has latest records.
  after_action :create_action_record, only: :create, if: -> { @account.persisted? && params[:_action].present? }

  protect_from_bots :create, redirect_to: :index, controller: :home

  # later: FIXME: people have to be sorted. See sorted_and_filtered in older code.
  def index
    @people = Person.find_claimed(page: params[:page])
    @cbp_map = PeopleDecorator.new(@people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end

  def show
    @projects, @logos = @account.project_core.used
    @twitter_detail = TwitterDetail.new(@account)
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_to message_path, flash: { success: t('.success', email: @account.email) }
    else
      render :new
    end
  end

  def update
    if @account.update(account_params)
      redirect_to @account, notice: t('.success')
    else
      render 'edit'
    end
  end

  def destroy
    @account.destroy
    unless current_user_is_admin?
      cookies.delete(:auth_token)
      reset_session
    end
    redirect_to delete_feedback_accounts_path(@account.login)
  end

  # NOTE: Replaces commits_history
  def commits_by_project_chart
    render json: Chart.new(@account).commits_by_project
  end

  # NOTE: Replaces language_experience
  def commits_by_language_chart
    render json: Chart.new(@account).commits_by_language(params[:scope])
  end

  def languages
    @contributions = @account.positions.includes(:contribution).map(&:contribution).group_by(&:project_id)
    return if @account.best_vita.nil?
    @vlfs = @account.best_vita.vita_language_facts.with_language_and_projects
    @logos_map = @account.best_vita.language_logos.index_by(&:id)
  end

  # NOTE: Replaces delete_feedback
  def destroy_feedback
    return if request.get? || params[:reasons].blank?
    processed_reasons = process_reason_params(params)
    @deleted_account.update_attributes(reasons: processed_reasons[:reasons], reason_other: processed_reasons[:other])
    redirect_to message_path, flash: { success: t('.success') }
  end

  def make_spammer
    Account::Access.new(@account).spam!
    flash[:success] = t('.success', name: CGI.escapeHTML(@account.name))
    redirect_to account_path(@account)
  end

  def activate
    return unless Account::Access.new(@account).activate!(params[:code])
    @account.run_actions(Action::STATUSES[:after_activation])
    session[:account] = @account.id
    redirect_to account_path(@account), flash: { success: t('.success') }
  end

  def search
    if request.xhr?
      accounts = Account.simple_search(params[:term])
      render json: accounts.map { |a| { id: a.to_param, value: a.login } }
    else
      redirect_to people_path(q: params[:term])
    end
  end

  # specific for autocomplete helper
  def autocomplete
    accounts = Account.simple_search(params[:term])
    render json: accounts.map { |a| { login: a.login, name: a.name, value: a.login } }
  end

  def resolve_login
    q = params[:q].to_s
    account = Account.resolve_login(params[:q])
    render json: account ? account.attributes.merge(q: q) : { id: nil, q: q }
  end

  def unsubscribe_emails
    account_id = Ohloh::Cipher.decrypt(CGI.escape(params[:key]))
    @account = Account.where(id: account_id).first
    @status = @account.try(:email_master)
    @account.update_attribute(:email_master, false) if @status
  end

  private

  def set_account
    @account = Account.where('id = :id or login = :login', id: params[:id].to_i, login: params[:id]).first!
  rescue ActiveRecord::RecordNotFound
    raise ParamRecordNotFound
  end

  def redirect_if_disabled
    redirect_to disabled_account_url(@account) if @account && Account::Access.new(@account).disabled?
  end

  def deleted_account?
    @deleted_account = DeletedAccount.find_deleted_account(params[:login])
    elapsed = @deleted_account.try(:feedback_time_elapsed?)
    account = Account.find_by_login(params[:login])
    return if account.nil? && @deleted_account && !elapsed
    redirect_to message_path, flash: { error: elapsed ? t('.expired') : t('.invalid_request') }
  end

  def check_activation
    redirect_to account_path(@account), notice: t('.notice') if Account::Access.new(@account).activated?
  end

  def process_reason_params(params)
    { reasons: "{#{params[:reasons].join(',')}}", other: String.clean_string(params[:reason_other]) }
  end

  def check_banned_domain
    @account = Account.new(account_params)
    return unless @account.email?
    render :new, status: 418 if DomainBlacklist.email_banned?(@account.email)
  end

  def captcha_response
    @account = Account.new(account_params)
    verify_recaptcha(model: @account, attribute: :captcha)
    render :new if @account.errors.messages[:captcha].present?
  end

  def create_action_record
    Action.create(account: @account, _action: params[:_action], status: :after_activation)
  end

  def account_params
    params.require(:account).permit(
      :login, :email, :email_confirmation, :name, :country_code, :location, :latitude, :longitude,
      :twitter_account, :organization_id, :organization_name, :affiliation_type, :invite_code,
      :password, :password_confirmation, :about_raw, :url)
  end
end
# rubocop:enable Metrics/ClassLength
