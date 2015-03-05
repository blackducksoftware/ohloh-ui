module RedirectIfDisabled
  def redirect_if_disabled
    return unless @account && (Account::Access.new(@account).disabled? || Account::Access.new(@account).spam?)
    redirect_to disabled_account_url(@account)
  end
end
