class SessionsController < Clearance::SessionsController
  def create
    @account = Account.fetch_by_login_or_email(params[:login][:login])
    account_or_nil = authenticate(params)

    sign_in(account_or_nil) do |status|
      if status.success?
        @account.update!(auth_fail_count: 0)
        redirect_back_or url_after_create
      else
        sign_in_failure(status.failure_message)
      end
    end
  end

  private

  def sign_in_failure(failure_message)
    set_auth_fail_count

    if retries_remaining >= 1
      flash.now.notice = failure_message
    else
      disable_account_and_notify_admin
      flash.now.notice = t('.locked_message')
    end

    render template: 'sessions/new', status: :unauthorized
  end

  def set_auth_fail_count
    if auth_failure_within_lock_timeout?
      @account.update!(auth_fail_count: @account.auth_fail_count + 1)
    else
      @account.update!(auth_fail_count: 1)
    end
  end

  def auth_failure_within_lock_timeout?
    Time.current - @account.updated_at < ENV['FAILED_LOGIN_TIMEOUT'].to_i.minutes
  end

  def retries_remaining
    ENV['MAX_LOGIN_RETRIES'].to_i - @account.auth_fail_count
  end

  def disable_account_and_notify_admin
    @account.update!(level: Account::Access::DISABLED)
    AccountMailer.notify_disabled_account_for_login_failure(@account).deliver_now
    NewRelic::Agent.notice_error("#{@account.login} deactivated for repeated failed login attempts.")
  end
end
