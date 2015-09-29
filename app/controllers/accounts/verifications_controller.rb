class Accounts::VerificationsController < ApplicationController
  include RedirectIfDisabled

  skip_before_action :store_location
  before_action :session_required
  before_action :set_account
  before_action :redirect_if_disabled
  before_action :must_own_account
  before_action :redirect_if_verified
  before_action :check_for_auth_session

  def generate
    if @account.update(session[:auth_params])
      session[:auth_params] = nil
      redirect_to @account
    else
      redirect_to new_authentication_path, notice: @account.errors.messages.values.last.last
    end
  end

  private

  def set_account
    @account = Account.from_param(params[:account_id]).take
    fail ParamRecordNotFound unless @account
  end

  def redirect_if_verified
    redirect_to root_path if @account.access.mobile_or_oauth_verified?
  end

  def update_account_and_reverification_with_twitter_id(account, proposed_twitter_id)
    account.twitter_id = proposed_twitter_id
    account.validate
    twitter_id_valid = account.errors.messages[:twitter_id].blank?
    account.update_column(:twitter_id, proposed_twitter_id) if twitter_id_valid
    account.reverification.update_column(:twitter_reverified, true)
    twitter_id_valid

  def check_for_auth_session
    fail ParamRecordNotFound unless session[:auth_params]
  end
end
