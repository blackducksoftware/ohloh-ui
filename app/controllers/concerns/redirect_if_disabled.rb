module RedirectIfDisabled
  def redirect_if_disabled
    account = current_user
    return unless account && account.access.disabled?
    request.env[:clearance].sign_out
    redirect_to disabled_account_url(account)
  end
end
