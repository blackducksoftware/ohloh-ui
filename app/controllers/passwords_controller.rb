class PasswordsController < ApplicationController
  before_action :session_required
  before_action :set_account

  def update
    if @account.update_attributes(account_params)
      redirect_to account_path, notice: t('.password_changed')
    else
      flash.now[:error] = t('.problem_saving')
      render :edit, status: :unprocessable_entity
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
