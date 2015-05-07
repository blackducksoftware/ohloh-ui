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
      flash[:success] = 'A link to reset your password was sent to your email address.'

      redirect_to message_path
    else
      render :new
    end
  end

  def confirm
  end

  def reset
    @account.reset_password_tokens = nil
    if @account.update(account_params)
      flash[:success] = 'Your password has been reset successfully.'
      redirect_to new_session_url(return_to: account_path(@account))
    else
      render :confirm
    end
  end

  private

  def account_params
    params.require(:account).permit(:password, :password_confirmation)
  end

  def set_account
    @account = Account.from_param(params[:account_id]).first
    raise ParamRecordNotFound unless @account
  end

  def check_token_expiration
    token_expires_at = @account.reset_password_tokens[params[:token]]
    return render_404 unless token_expires_at

    if token_expires_at < Time.now.utc
      flash[:error] = 'Your password reset URL has expired. Please try again!'
      redirect_to new_password_reset_path
    end
  end

  def redirect_if_logged_in
    if logged_in?
      flash[:notice] = 'You are already logged in.'
      redirect_to account_path(current_user)
    end
  end
end
