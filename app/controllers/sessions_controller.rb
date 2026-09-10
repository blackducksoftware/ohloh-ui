# frozen_string_literal: true

class SessionsController < Clearance::SessionsController
  helper StatsdHelper

  before_action :account_must_exist, only: :create
  before_action :captcha_verify, only: :create, if: :failed_login_thrice?
  before_action :reset_auth_fail_count, only: :create, if: :auth_failure_timeout?
  attr_reader :account

  def create
    account_or_nil = authenticate(params)
    return handle_admin_login(account_or_nil) if account_or_nil&.admin?

    handle_regular_login(account_or_nil)
  end

  def handle_regular_login(account)
    sign_in(account) do |status|
      if status.success?
        reset_auth_fail_count
        redirect_back_or url_after_create
      else
        increment_auth_fail_count
        sign_in_failure(status.failure_message)
      end
    end
  end

  def handle_admin_login(admin)
    reset_auth_fail_count
    return direct_sign_in(admin) if okta_auth_excluded?(admin.email) || Rails.env.test?

    prepare_okta_redirect(admin)
  end

  def direct_sign_in(admin)
    sign_in(admin) do |status|
      if status.success?
        session[:okta_authed_at] = Time.current.to_i
        reset_auth_fail_count
        redirect_back_or url_after_create
      else
        increment_auth_fail_count
        sign_in_failure(status.failure_message)
      end
    end
  end

  def prepare_okta_redirect(admin)
    token = SecureRandom.hex(16)
    cache_data = { email: admin.email, return_to: session[:return_to] }
    Rails.cache.write("saml_pending:#{token}", cache_data, expires_in: 10.minutes)
    @relay_state = token
    render 'sessions/saml_redirect'
  end

  def okta_auth_excluded?(email)
    excluded_emails = ENV.fetch('OKTA_AUTH_EXCLUDED_ADMINS', '').split(',').map(&:strip)
    excluded_emails.include?(email)
  end

  def health
    render plain: Time.current
  end

  private

  def failed_login_thrice?
    account.auth_fail_count >= 3
  end

  def captcha_verify
    return if verify_recaptcha

    statsd_increment('Openhub.Session.fail')
    @ask_for_recaptcha = true
    flash.now[:error] = t('.recaptcha_failure')
    render 'sessions/new', status: :unauthorized
  end

  def sign_in_failure(failure_message)
    statsd_increment('Openhub.Session.fail')
    flash.now[:error] = failure_message
    @ask_for_recaptcha = true if failed_login_thrice?
    disable_account_for_retries
    render 'sessions/new', status: :unauthorized
  end

  def disable_account_for_retries
    return if retries_remaining.positive? || account.access.disabled?

    disable_account_and_notify_admin
    flash.now[:error] = t('.locked_message')
  end

  def auth_failure_timeout?
    return false unless account

    Time.current - account.updated_at > ENV['FAILED_LOGIN_TIMEOUT'].to_i.minutes.to_i
  end

  def retries_remaining
    ENV['MAX_LOGIN_RETRIES'].to_i - account.auth_fail_count
  end

  def disable_account_and_notify_admin
    account.update!(level: Account::Access::DISABLED)
    AccountMailer.notify_disabled_account_for_login_failure(account).deliver_now
    AppLogger.info("#{account.login} deactivated for repeated failed login attempts.")
  end

  def increment_auth_fail_count
    account.update!(auth_fail_count: account.auth_fail_count + 1)
  end

  def reset_auth_fail_count
    statsd_increment('Openhub.Session.success')
    account.update!(auth_fail_count: 0)
  end

  def account_must_exist
    @account = Account.fetch_by_login_or_email(params[:login][:login]) if params[:login].present?
    return if @account

    flash.now[:error] = t('flashes.failure_after_create')
    render 'sessions/new', status: :unauthorized
  end
end
