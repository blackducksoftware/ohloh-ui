class AccountsController < ApplicationController
  include RedirectIfDisabled

  helper MapHelper

  skip_before_action :store_location, only: %i[new create]
  before_action :session_required, only: %i[edit destroy confirm_delete me]
  before_action :set_account, only: %i[destroy show update edit confirm_delete disabled settings]
  before_action :redirect_if_disabled, only: %i[show update edit]
  before_action :redirect_unverified_account, only: %i[edit destroy confirm_delete me]
  before_action :disabled_during_read_only_mode, only: %i[edit update]
  before_action :account_context, only: %i[edit update confirm_delete]
  before_action :must_own_account, only: %i[edit update confirm_delete]
  before_action :find_claimed_people, only: :index
  before_action :redirect_if_logged_in, only: :new

  def new
    @account = Account.new
    @account.build_firebase_verification
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      clearance_session.sign_in @account
      redirect_to @account
    else
      render :new
    end
  end

  def index
    @cbp_map = PeopleDecorator.new(@people).commits_by_project_map
    @positions_map = Position.where(id: @cbp_map.values.map(&:first).flatten)
                             .preload(project: [{ best_analysis: :main_language }, :logo])
                             .index_by(&:id)
  end

  def show
    @projects, @logos = @account.project_core.used
    @twitter_detail = TwitterDetail.new(@account)
    page_context[:page_header] = 'accounts/show/header'
  end

  def me
    redirect_to account_path(current_user)
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
      cookies.delete(:remember_token)
      reset_session
    end
    redirect_to edit_deleted_account_path(@account.login)
  end

  def unsubscribe_emails
    account_id = Ohloh::Cipher.decrypt(CGI.escape(params[:key].to_s))
    @account = Account.where(id: account_id).first
    @notification_type = params[:notification_type].try(:to_sym)
    @status = @account.try(:email_master)
    Account::Subscription.new(@account).unsubscribe(@notification_type) if @status
  end

  private

  def find_claimed_people
    total_entries = params[:query].blank? ? Person::Count.claimed : nil
    @people = Person.find_claimed(params[:query], params[:sort])
                    .paginate(page: page_param, per_page: 10, total_entries: total_entries)
  end

  def set_account
    set_account_by_email_md5
    @account ||= if params[:id] == 'me'
                   return redirect_to new_session_path if current_user.nil?
                   current_user
                 else
                   AccountFind.by_id_or_login(params[:id])
                 end
    raise ParamRecordNotFound unless @account
  end

  def set_account_by_email_md5
    @account = Account.find_by(email_md5: params[:id]) if request_format == 'xml'
  end

  def create_action_record
    Action.create(account: @account, _action: params[:_action], status: :after_activation)
  end

  def account_params
    params.require(:account).permit(
      :login, :email, :password, :name, :country_code, :location, :latitude, :longitude,
      :twitter_account, :organization_id, :organization_name, :affiliation_type, :invite_code,
      :about_raw, :url, firebase_verification_attributes: [:credentials]
    )
  end

  def redirect_if_logged_in
    redirect_to account_path(current_user), notice: t('password_resets.already_logged_in') if logged_in?
  end
end
