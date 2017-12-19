class AuthenticationsController < ApplicationController
  before_action :session_required, only: [:new, :firebase_callback]
  before_action :redirect_matching_account, only: :github_callback, unless: -> { current_user.present? }
  before_action :redirect_if_current_user_verified

  def new
    @account = current_user
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

  def create(auth_params)
    current_user.present? ? save_account(auth_params) : create_account_using_github(auth_params)
  end

  def save_account(auth_params)
    account = current_user
    if account.update(auth_params)
      redirect_to account
    else
      redirect_to new_authentication_path, notice: account.errors.messages.values.last.last
    end
  end

  def create_account_using_github(auth_params)
    account = Account.new(github_account_params.merge(auth_params))

    if account.save
      clearance_session.sign_in account
      redirect_to account
    else
      redirect_to new_account_path, notice: account.errors.full_messages.join(', ')
    end
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

  def github_account_params
    login = get_unique_login(github_api.login)
    password = SecureRandom.uuid
    { login: login, email: github_api.email, password: password, activated_at: Time.current }
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

  def redirect_if_current_user_verified
    return if current_user.nil?
    redirect_to root_path if current_user.access.mobile_or_oauth_verified?
  end
end
