class RegistrationsController < ApplicationController
  before_action :check_for_account_and_auth_params, only: :generate

  def generate
    @account = Account.new(session[:account_params].merge(session[:auth_params]))

    if @account.save
      reset_session
      clearance_session.sign_in @account
      redirect_to @account
    else
      redirect_with_error
    end
  end

  private

  def redirect_with_error
    flash_notice = @account.errors.full_messages.join(', ')
    redirect_to new_account_path, notice: flash_notice
  end

  def check_for_account_and_auth_params
    raise ParamRecordNotFound unless session[:account_params] && session[:auth_params]
  end
end
