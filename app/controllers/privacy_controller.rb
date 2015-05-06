class PrivacyController < ApplicationController
  before_action :set_account_and_authorizations

  private

  def set_account_and_authorizations
    @account = Account::Find.by_id_or_login(params[:id])
    fail ParamRecordNotFound unless @account
    @account.update_attribute(:email_opportunities_visited, Time.now.utc)
    # TODO: @active_authorizations needs to be implemented after OAuth ticket is done.
    # @active_authorizations = @account.authorizations.active
  end
end
