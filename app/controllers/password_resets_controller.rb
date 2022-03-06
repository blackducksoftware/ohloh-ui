# frozen_string_literal: true

class PasswordResetsController < Clearance::PasswordsController
  private

  def deliver_email(account)
    ::ClearanceMailer.change_password(account).deliver_now
  end

  def find_user_by_id_and_confirmation_token
    token = params[:token] || session[:password_reset_token]

    Clearance.configuration.user_model
             .find_by(login: params[:account_id], confirmation_token: token.to_s)
  end

  def flash_failure_when_forbidden
    flash.now[:error] = t('passwords.token_expired_error')
  end
end
