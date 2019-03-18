module RedirectIfDisabled
  def redirect_if_disabled
    return unless @account && @account.access.disabled?

    request.env[:clearance].sign_out if @account.id == current_user.id
    redirect_to disabled_account_url(@account)
  end
end
