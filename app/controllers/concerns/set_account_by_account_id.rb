module SetAccountByAccountId
  extend ActiveSupport::Concern

  included do
    include RedirectIfDisabled
    before_action :set_account_by_account_id
    before_action :redirect_if_disabled
  end

  private

  def set_account_by_account_id
    @account = Rails.cache.fetch("set_account_id_#{params[:account_id]}", expires_in: 24.hours) do
      Account::Find.by_id_or_login(params[:account_id])
    end
    fail ParamRecordNotFound unless @account
  end
end
