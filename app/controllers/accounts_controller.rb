class AccountsController < ApplicationController
  include RedirectIfDisabled

  before_action :session_required, only: [:edit, :destroy, :confirm_delete]
  before_action :set_account, only: [:destroy, :show, :update, :edit, :confirm_delete, :disabled, :settings]
  before_action :redirect_if_disabled, only: [:show, :update, :edit]
  before_action :disabled_during_read_only_mode, only: [:new, :create, :edit, :update]
  # FIXME: Integrate this action.
  # before_action :set_smart_sort, only: [:index]
  before_action :must_own_account, only: [:edit, :update, :destroy, :confirm_delete]
  before_action :check_banned_domain, only: :create
  before_action :captcha_response, only: :create
  before_action :account_context, only: :edit
  before_action :find_claimed_people, only: :index
  after_action :create_action_record, only: :create, if: -> { @account.persisted? && params[:_action].present? }

  protect_from_bots :create, redirect_to: :index, controller: :home

  # FIXME: people have to be sorted. See sorted_and_filtered in older code.
  def index
    @cbp_map = PeopleDecorator.new(@people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten).includes(:project)
                     .references(:all).index_by(&:id)
  end

  def show
    @projects, @logos = @account.project_core.used
    @twitter_detail = TwitterDetail.new(@account)
    page_context[:page_header] = 'accounts/show/header'
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
      redirect_to account_path(@account), notice: t('.success')
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
    redirect_to edit_deleted_account_path(@account.login)
  end

  def unsubscribe_emails
    account_id = Ohloh::Cipher.decrypt(CGI.escape(params[:key]))
    @account = Account.where(id: account_id).first
    @status = @account.try(:email_master)
    @account.update_attribute(:email_master, false) if @status
  end

  private

  def find_claimed_people
    total_entries = params[:query].blank? ? Person::Count.claimed : nil
    @people = Person.find_claimed(params[:query], params[:sort])
              .paginate(page: params[:page], per_page: 10, total_entries: total_entries)
  end

  def set_account
    @account = Account::Find.by_id_or_login(params[:id])
    fail ParamRecordNotFound unless @account
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
