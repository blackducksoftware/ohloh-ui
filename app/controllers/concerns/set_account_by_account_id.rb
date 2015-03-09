module SetAccountByAccountId
  extend ActiveSupport::Concern

  included do
    before_action :set_account_by_account_id
  end

  private

  def set_account_by_account_id
    @account = Account::Find.by_id_or_login(params[:account_id])
    fail ParamRecordNotFound unless @account
  end
end
