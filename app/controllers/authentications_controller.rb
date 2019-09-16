class AuthenticationsController < ApplicationController
  include AuthenticationFilter
  before_action :session_required, only: %i[new firebase_callback]
  skip_before_action :store_location

  def new
    @account = current_user
    @account.build_firebase_verification
    render partial: 'fields' if request.xhr?
  end

  def github_callback
    StatsD.increment('Openhub.Account.Signup.github')
    create(github_verification_params)
  end

  def firebase_callback
    StatsD.increment('Openhub.Account.Signup.firebase')
    create(firebase_verification_params)
  end

  private

  def create(auth_params)
    current_user.present? ? save_account(auth_params) : create_account_using_github(auth_params)
  end

  def save_account(auth_params)
    account = current_user
    if account.update(auth_params)
      flash[:notice] = t('verification_completed')
      StatsD.increment('Openhub.Account.Signup.success')
      redirect_back(account)
    else
      StatsD.increment('Openhub.Account.Signup.failure')
      redirect_to new_authentication_path, notice: account.errors.messages.values.last.last
    end
  end

  def create_account_using_github(auth_params)
    account = Account.new(github_account_params.merge(auth_params))

    if account.save
      StatsD.increment('Openhub.Account.Signup.success')
      clearance_session.sign_in account
      redirect_back(account)
    else
      StatsD.increment('Openhub.Account.Signup.failure')
      redirect_to new_account_path, notice: account.errors.full_messages.join(', ')
    end
  end

  def firebase_verification_params
    params.require(:account).permit(firebase_verification_attributes: [:credentials])
  end

  def github_verification_params
    { github_verification_attributes: { unique_id: github_api.login, token: github_api.access_token } }
  end

  def github_account_params
    login = Account::LoginFormatter.new(github_api.login).sanitized_and_unique
    password = SecureRandom.uuid
    { login: login, email: github_api.email, password: password, activated_at: Time.current }
  end
end
