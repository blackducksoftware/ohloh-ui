class Accounts::VerificationsController < ApplicationController
  include RedirectIfDisabled

  skip_before_action :store_location
  before_action :session_required
  before_action :set_account
  before_action :redirect_if_disabled
  before_action :must_own_account

  def create
    twitter_id = TwitterDigits.get_twitter_id(params[:verification][:service_provider_url],
                                              params[:verification][:credentials])

    if twitter_id
      @account.update!(twitter_id: twitter_id)
      redirect_back
    else
      flash[:error] = t('.error')
      render :new
    end
  end

  private

  def set_account
    @account = Account.from_param(params[:account_id]).take
    fail ParamRecordNotFound unless @account
  end
end
