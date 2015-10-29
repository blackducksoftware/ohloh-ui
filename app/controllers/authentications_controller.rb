class AuthenticationsController < ApplicationController
  before_action :set_account, only: :new
  before_action :session_account_params_or_current_user_required, only: [:new, :github_callback, :digits_callback]
  before_action :redirect_if_current_user_verified

  def new
    @account.build_twitter_digits_verification
    render partial: 'fields' if request.xhr?
  end

  def github_callback
    create(github_verification_params)
  end

  def digits_callback
    create(digits_verification_params)
  end

  private

  def create(modified_params)
    session[:auth_params] = modified_params

    redirect_to(current_user.present? ? generate_account_verifications_path(current_user) : generate_registrations_path)
  end

  def digits_verification_params
    params.require(:account).permit(twitter_digits_verification_attributes: [:service_provider_url, :credentials])
  end

  def github_verification_params
    { github_verification_attributes: { code: params[:code] } }
  end

  def session_account_params_or_current_user_required
    fail ParamRecordNotFound if session[:account_params].nil? && current_user.nil?
  end

  def redirect_if_current_user_verified
    return if current_user.nil?
    redirect_to root_path if current_user.access.mobile_or_oauth_verified?
  end

  def set_account
    @account = current_user.present? ? current_user : Account.new
  end
end
