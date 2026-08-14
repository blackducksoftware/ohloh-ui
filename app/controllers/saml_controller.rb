# frozen_string_literal: true

class SamlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[callback global_token_revocation]
  before_action :verify_gtr_request, only: :global_token_revocation

  def callback
    okta_email = extract_okta_email
    cache_data = fetch_cache_data
    return handle_email_mismatch unless email_matches?(okta_email, cache_data&.dig(:email))

    complete_authentication(okta_email, cache_data)
  end

  def extract_okta_email
    auth = request.env['omniauth.auth']
    auth&.info&.email || auth&.uid
  end

  def fetch_cache_data
    token = params[:RelayState]
    Rails.cache.read("saml_pending:#{token}")
  end

  def email_matches?(okta_email, pending_email)
    okta_email.present? && okta_email.downcase == pending_email&.downcase
  end

  def complete_authentication(okta_email, cache_data)
    Rails.cache.delete("saml_pending:#{params[:RelayState]}")
    account = Account.find_by('lower(email) = ?', okta_email.to_s.downcase)
    sign_in(account) { |status| handle_sign_in_status(status, cache_data) }
  end

  def handle_sign_in_status(status, cache_data)
    if status.success?
      session[:okta_authed_at] = Time.current.to_i
      redirect_to cache_data&.dig(:return_to) || Clearance.configuration.redirect_url
    else
      redirect_to new_session_path, alert: status.failure_message
    end
  end

  def handle_email_mismatch
    redirect_to new_session_path, alert: t('flashes.saml_email_mismatch')
  end

  def global_token_revocation
    params[:sub] || params[:login]
    head :ok
  end

  private

  def verify_gtr_request
    secret = ENV.fetch('OKTA_GTR_SECRET', nil)
    return head :unauthorized if secret.blank?

    auth_header = request.headers['Authorization']
    return head :unauthorized if auth_header.blank?

    expected_token = "Bearer #{secret}"
    return head :unauthorized if auth_header.length != expected_token.length

    head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(auth_header, expected_token)
  end
end
