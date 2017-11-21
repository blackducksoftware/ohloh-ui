class PasswordResetsController < Clearance::PasswordsController
  private

  def deliver_email(account)
    ::ClearanceMailer.change_password(account).deliver_now
  end

  def find_user_by_id_and_confirmation_token
    token = params[:token] || session[:password_reset_token]

    Clearance.configuration.user_model
             .find_by_login_and_confirmation_token params[:user_id], token.to_s
  end
end
