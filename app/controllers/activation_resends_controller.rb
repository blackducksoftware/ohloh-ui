class ActivationResendsController < ApplicationController
  before_action :find_account_by_email, only: :create
  before_action :prevent_email_delivery_for_active_account, only: :create
  before_action :prevent_email_delivery_for_recently_activated, only: :create

  def create
    @account.resend_activation!
    redirect_to message_path, notice: t('.success')
  end

  private

  def prevent_email_delivery_for_active_account
    redirect_to new_session_path, notice: t('.already_active') if Account::Access.new(@account).activated?
  end

  def prevent_email_delivery_for_recently_activated
    return unless @account.activation_resent_at && Time.now.utc < @account.activation_resent_at.since(2.hours)
    redirect_to message_path, flash: { success: t('.recently_activated') }
  end

  def find_account_by_email
    @account = Account.find_by_email(params[:email])
    return unless @account.nil?
    @errors = t('.no_account')
    render :new
  end
end
