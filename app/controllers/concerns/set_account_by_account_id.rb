module SetAccountByAccountId
  extend ActiveSupport::Concern

  included do
    include RedirectIfDisabled

    before_action :redirect_if_disabled
    before_action :set_account_by_account_id
  end

  private

  def set_account_by_account_id
    @account = Account::Find.by_id_or_login(params[:account_id])
    raise ParamRecordNotFound unless @account
  end
end
