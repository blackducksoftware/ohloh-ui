class PasswordsController < ApplicationController
  before_action :session_required
  before_action :set_account

  def update
    if @account.update_attributes(account_params)
      redirect_to account_path
      flash[:password_changed] = t('.password_changed')
    else
      render :edit, status: :unprocessable_entity
      flash[:password_error] = t('.problem_saving')
    end
  end

  private

  def set_account
    @account = Account.from_param(params[:id]).take
    fail ParamRecordNotFound unless @account
  end

  def account_params
    params.require(:account).permit(:current_password, :password, :password_confirmation)
  end
end
