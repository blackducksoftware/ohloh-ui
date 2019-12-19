# frozen_string_literal: true

module SetAccountByAccountId
  extend ActiveSupport::Concern

  included do
    include RedirectIfDisabled

    before_action :set_account_by_account_id
    before_action :redirect_if_disabled
  end

  private

  def set_account_by_account_id
    @account = AccountFind.by_id_or_login(params[:account_id])
    raise ParamRecordNotFound unless @account
  end
end
