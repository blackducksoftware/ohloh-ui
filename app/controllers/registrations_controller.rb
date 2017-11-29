class RegistrationsController < ApplicationController
  before_action :check_for_account_and_auth_params, only: :generate
  before_action :redirect_if_logged_in, only: :new

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
      clearance_session.sign_in @account
      redirect_to @account
    else
      redirect_to_new_authentication_path
    end
  end

  private

  def redirect_if_logged_in
    redirect_to account_path(current_user), notice: t('password_resets.already_logged_in') if logged_in?
  end

  def redirect_to_new_authentication_path
    redirect_to new_authentication_path, notice: @account.errors.messages.values.last.join(', ')
  end

  def account_params
    params.require(:account).permit(:login, :email, :email_confirmation, :password,
                                    :password_confirmation, :invite_code)
  end

  def check_for_account_and_auth_params
    raise ParamRecordNotFound unless session[:account_params] && session[:auth_params]
  end
end
