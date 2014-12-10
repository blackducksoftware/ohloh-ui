class SessionsController < ApplicationController
  skip_before_action :store_location

  def create
    authenticator = Authenticator.new(login: params[:login][:login], password: params[:login][:password])
    if authenticator.correct_password?
      initialize_session authenticator.account
    else
      flash[:error] = t '.error'
      render :new, status: :bad_request
    end
  end

  def destroy
    reset_session
    flash[:notice] = t '.success'
    redirect_back_or_default(root_path)
  end

  private

  def initialize_session(account)
    return if disabled_account?(account)
    return unless activated_account?(account)
    session[:account_id] = account.id
    flash[:notice] = t '.success'
    redirect_back_or_default account_path(account)
  end

  def disabled_account?(account)
    return false unless account.disabled?
    flash[:error] = t '.disabled_error'
    render :new, status: :bad_request
    true
  end

  def activated_account?(account)
    return true if account.activated?
    flash[:error] = t '.unactivated_error'
    render :new, status: :bad_request
    false
  end
end
