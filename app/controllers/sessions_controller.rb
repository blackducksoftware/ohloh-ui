# frozen_string_literal: true

class SessionsController < Clearance::SessionsController
  helper StatsdHelper

  before_action :account_must_exist, only: :create
  before_action :captcha_verify, only: :create, if: :failed_login_thrice?
  before_action :reset_auth_fail_count, only: :create, if: :auth_failure_timeout?
  attr_reader :account

  def create
    account_or_nil = authenticate(params)

    sign_in(account_or_nil) do |status|
      if status.success?
        reset_auth_fail_count
        redirect_back_or url_after_create
      else
        increment_auth_fail_count
        sign_in_failure(status.failure_message)
      end
    end
  end

  def health
    # if ApplicationRecord.connected?
      render plain: Time.current
    # else
    #   head :internal_server_error
    # end
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
    return unless account

    Time.current - account.updated_at > ENV['FAILED_LOGIN_TIMEOUT'].to_i.minutes.to_i
  end

  def retries_remaining
    ENV['MAX_LOGIN_RETRIES'].to_i - account.auth_fail_count
  end

  def disable_account_and_notify_admin
    account.update!(level: Account::Access::DISABLED)
    AccountMailer.notify_disabled_account_for_login_failure(account).deliver_now
    DataDogReport.error("#{account.login} deactivated for repeated failed login attempts.")
  end

  def increment_auth_fail_count
    account.update!(auth_fail_count: account.auth_fail_count + 1)
  end

  def reset_auth_fail_count
    statsd_increment('Openhub.Session.success')
    account.update!(auth_fail_count: 0)
  end

  def account_must_exist
    @account = Account.fetch_by_login_or_email(params[:login][:login])
    return if @account

    flash.now[:error] = t('flashes.failure_after_create')
    render 'sessions/new', status: :unauthorized
  end
end
