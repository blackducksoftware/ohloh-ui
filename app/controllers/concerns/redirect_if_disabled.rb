module RedirectIfDisabled
  def redirect_if_disabled
    return unless @account && (@account.access.disabled? || @account.access.spam?)
    redirect_to disabled_account_url(@account)
  end
end
