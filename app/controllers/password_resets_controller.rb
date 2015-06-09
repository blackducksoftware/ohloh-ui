class PasswordResetsController < ApplicationController
  before_action :redirect_if_logged_in
  before_action :set_account, only: [:confirm, :reset]
  before_action :check_token_expiration, only: [:confirm, :reset]

  def new
    @password_reset = PasswordReset.new
  end

  def create
    @password_reset = PasswordReset.new(params[:password_reset])

    if @password_reset.valid?
      @password_reset.refresh_token_and_email_link

      redirect_to message_path, flash: { success: t('.success') }
    else
      render :new
    end
  end

  def confirm
  end

  def reset
    @account.reset_password_tokens = nil
    if @account.update(account_params)
      redirect_to new_session_url(return_to: account_path(@account)), flash: { success: t('.success') }
    else
      render :confirm
    end
  end

  private

  def account_params
    params.require(:account).permit(:password, :password_confirmation, :current_password)
  end

  def set_account
    @account = Account.from_param(params[:account_id]).first
    fail ParamRecordNotFound unless @account
  end

  def check_token_expiration
    token_expires_at = @account.reset_password_tokens[params[:token]]
    return render_404 unless token_expires_at
    return if token_expires_at > Time.current

    redirect_to new_password_reset_path, flash: { error: t('password_resets.token_expired_error') }
  end

  def redirect_if_logged_in
    return unless logged_in?

    redirect_to account_path(current_user), notice: t('password_resets.already_logged_in')
  end
end
