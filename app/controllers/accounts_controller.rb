class AccountsController < ApplicationController
  helper :Projects

  before_action :account, only: [:show, :commits_by_project_chart, :commits_by_language_chart,
                                 :make_spammer, :activate, :languages]
  before_action :redirect_if_disabled, only: [:show, :commits_by_project_chart, :commits_by_language_chart]
  before_action :check_activation, only: [:activate]
  before_action :deleted_account?, only: :destroy_feedback
  before_action :disabled_during_read_only_mode, only: [:activate]

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

  # NOTE: Replaces commits_history
  def commits_by_project_chart
    render json: Chart.new(@account).commits_by_project
  end

  # NOTE: Replaces language_experience
  def commits_by_language_chart
    render json: Chart.new(@account).commits_by_language(params[:scope])
  end

  def languages
    @contributions = @account.positions.map(&:contribution).group_by(&:project_id)
    return if @account.best_vita.nil?
    @vlfs = @account.best_vita.vita_language_facts.with_languages_and_commits
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
    redirect_to account_path(account)
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

  def disabled_during_read_only_mode
    redirect_to maintenance_path if read_only_mode? && !params[:admin]
  end

  def account
    accounts = Account.arel_table
    @account = Account.where(accounts[:id].eq(params[:id]).or(accounts[:login].eq(params[:id]))).first
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
    { reason: "{#{params[:reasons].join(',')}}", other: String.clean_string(params[:reason_other]) }
  end
end
