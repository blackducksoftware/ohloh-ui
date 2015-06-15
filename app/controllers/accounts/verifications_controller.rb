class Accounts::VerificationsController < ApplicationController
  include RedirectIfDisabled

  before_action :session_required
  before_action :set_account
  before_action :redirect_if_disabled
  before_action :must_own_account

  private

  def set_account
    @account = Account.from_param(params[:account_id]).take
    fail ParamRecordNotFound unless @account
  end
end
