class RegistrationsController < ApplicationController
  before_action :check_for_account_and_auth_params, only: :generate

  def new
    @account = Account.new
  end

  def validate
    @account = Account.new(account_params)
    if @account.valid?
      session[:account_params] = account_params
      redirect_to new_authentication_path
    else
      render :new
    end
  end

  def generate
    @account = Account.new(session[:account_params].merge(session[:auth_params]))

    if @account.save
      reset_session
      session[:account_id] = @account.id
      redirect_to @account
    else
      redirect_to_new_authentication_path
    end
  end

  private

  def redirect_to_new_authentication_path
    redirect_to new_authentication_path, notice: @account.errors.messages.values.last.last
  end

  def account_params
    params.require(:account).permit(:login, :email, :email_confirmation, :password,
                                    :password_confirmation, :invite_code)
  end

  def check_for_account_and_auth_params
    fail ParamRecordNotFound unless session[:account_params] && session[:auth_params]
  end
end
