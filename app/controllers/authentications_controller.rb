class AuthenticationsController < ApplicationController
  skip_before_action :session_required, if: :account_params_present?, only: :new
  before_action :session_required, unless: :account_params_present?, only: :new
  before_action :set_account, only: :new
  before_action :redirect_matching_account, only: :github_callback, unless: -> { current_user.present? }
  before_action :set_session_account_params, only: :github_callback, unless: -> { current_user.present? }
  before_action :session_account_params_or_current_user_required, only: [:new, :github_callback, :firebase_callback]
  before_action :redirect_if_current_user_verified

  def new
    @account.build_firebase_verification
    render partial: 'fields' if request.xhr?
  end

  def github_callback
    create(github_verification_params)
  end

  def firebase_callback
    create(firebase_verification_params)
  end

  private

  def create(modified_params)
    session[:auth_params] = modified_params

    redirect_to(current_user.present? ? generate_account_verifications_path(current_user) : generate_registrations_path)
  end

  def firebase_verification_params
    params.require(:account).permit(firebase_verification_attributes: [:credentials])
  end

  def github_verification_params
    { github_verification_attributes: { unique_id: github_api.login, token: github_api.access_token } }
  end

  def redirect_matching_account
    account = Account.find_by_email(github_api.email)
    return unless account
    account.access.verify_existing_github_user(github_api)
    reset_session
    clearance_session.sign_in account
    redirect_to account
  end

  def set_session_account_params
    login = get_unique_login(github_api.login)
    password = SecureRandom.uuid
    session[:account_params] = { login: login, email: github_api.email, password: password, activated_at: Time.current }
  end

  def get_unique_login(account_login)
    login = account_login
    while Account.exists?(login: login)
      login = account_login + Random.rand(999).to_s
    end
    login
  end

  def github_api
    @github_api ||= GithubApi.new(params[:code])
  end

  def session_account_params_or_current_user_required
    raise ParamRecordNotFound if session[:account_params].nil? && current_user.nil?
  end

  def redirect_if_current_user_verified
    return if current_user.nil?
    redirect_to root_path if current_user.access.mobile_or_oauth_verified?
  end

  def set_account
    @account = current_user.present? ? current_user : Account.new
  end

  def account_params_present?
    session[:account_params].present?
  end
end
