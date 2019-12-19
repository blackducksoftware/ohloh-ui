# frozen_string_literal: true

class AlterPasswordsController < ApplicationController
  before_action :session_required, :redirect_unverified_account
  before_action :set_account
  before_action :account_context

  def update
    @account.validate_current_password = true
    if @account.update(account_params)
      redirect_to account_path, flash: { success: t('.password_changed') }
    else
      render :edit, status: :unprocessable_entity
      flash[:error] = t('.problem_saving')
    end
  end

  private

  def set_account
    @account = if params[:id] == 'me'
                 return redirect_to new_session_path if current_user.nil?

                 current_user
               else
                 AccountFind.by_id_or_login(params[:id])
               end
    raise ParamRecordNotFound unless @account
  end

  def account_params
    params.require(:account).permit(:current_password, :password)
  end
end
