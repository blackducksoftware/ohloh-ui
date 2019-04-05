class Accounts::AccessesController < ApplicationController
  include SetAccountByAccountId

  before_action :check_activation, only: :activate
  before_action :session_required, only: %i[make_spammer manual_verification make_bot]
  before_action :admin_session_required, only: %i[make_spammer manual_verification make_bot]
  before_action :disabled_during_read_only_mode, only: :activate

  def make_spammer
    @account.access.spam!
    flash[:success] = t('.success', name: CGI.escapeHTML(@account.name))
    redirect_to account_path(@account)
  end

  def activate
    return unless @account.access.activate!(params[:code])

    @account.run_actions(Action::STATUSES[:after_activation])
    session[:account] = @account.id
    redirect_to account_path(@account), flash: { success: t('.success') }
  end

  def manual_verification
    @account.create_manual_verification
    flash[:success] = t('.success', name: CGI.escapeHTML(@account.name))
    redirect_to account_path(@account)
  end

  def make_bot
    @account.access.bot!
    flash[:success] = t('.success', name: CGI.escapeHTML(@account.name))
    redirect_to account_path(@account)
  end

  private

  def check_activation
    redirect_to account_path(@account), notice: t('.notice') if @account.access.activated?
  end
end
