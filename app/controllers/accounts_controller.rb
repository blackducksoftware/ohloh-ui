class AccountsController < ApplicationController
  include RedirectIfDisabled

  helper MapHelper

  before_action :session_required, :redirect_unverified_account, only: [:edit, :destroy, :confirm_delete, :me]
  before_action :set_account, only: [:destroy, :show, :update, :edit, :confirm_delete, :disabled, :settings]
  before_action :redirect_if_disabled, only: [:show, :update, :edit]
  before_action :disabled_during_read_only_mode, only: [:new, :create, :edit, :update]
  before_action :account_context, only: [:edit, :update, :confirm_delete]
  before_action :must_own_account, only: [:edit, :update, :confirm_delete]
  before_action :find_claimed_people, only: :index
  after_action :create_action_record, only: :create, if: -> { @account.persisted? && params[:_action].present? }

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
      cookies.delete(:auth_token)
      reset_session
    end
    redirect_to edit_deleted_account_path(@account.login)
  end

  def unsubscribe_emails
    account_id = Ohloh::Cipher.decrypt(CGI.escape(params[:key].to_s))
    @account = Account.where(id: account_id).first
    @status = @account.try(:email_master)
    @account.update_attribute(:email_master, false) if @status
  end

  private

  def find_claimed_people
    total_entries = params[:query].blank? ? Person::Count.claimed : nil
    @people = Person.find_claimed(params[:query], params[:sort])
              .paginate(page: page_param, per_page: 10, total_entries: total_entries)
  end

  def set_account
    @account = if params[:id] == 'me'
                 return redirect_to new_session_path if current_user.nil?
                 current_user
               else
                 Account::Find.by_id_or_login(params[:id])
               end
    fail ParamRecordNotFound unless @account
  end

  def create_action_record
    Action.create(account: @account, _action: params[:_action], status: :after_activation)
  end

  def account_params
    params.require(:account).permit(
      :login, :email, :email_confirmation, :name, :country_code, :location, :latitude, :longitude,
      :twitter_account, :organization_id, :organization_name, :affiliation_type, :invite_code,
      :digits_credentials, :digits_service_provider_url, :digits_oauth_timestamp,
      :password, :password_confirmation, :about_raw, :url)
  end
end
