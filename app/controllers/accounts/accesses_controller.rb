class Accounts::AccessesController < ApplicationController
  include SetAccountByAccountId

  before_action :check_activation, only: :activate
  before_action :admin_session_required, only: :make_spammer
  before_action :disabled_during_read_only_mode, only: :activate

  # NOTE: Replaces accounts#make_spammer.
  def make_spammer
    Account::Access.new(@account).spam!
    flash[:success] = t('.success', name: CGI.escapeHTML(@account.name))
    render template: 'accounts/disabled'
  end

  # NOTE: Replaces accounts#activate.
  def activate
    return unless Account::Access.new(@account).activate!(params[:code])
    @account.run_actions(Action::STATUSES[:after_activation])
    session[:account] = @account.id
    redirect_to account_path(@account), flash: { success: t('.success') }
  end

  private

  def check_activation
    redirect_to account_path(@account), notice: t('.notice') if Account::Access.new(@account).activated?
  end
end
