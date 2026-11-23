# frozen_string_literal: true

require 'test_helper'

# Regression tests for CWE-1021 (clickjacking).
#
# GET /sessions/new is routed to Clearance::SessionsController (not our SessionsController
# subclass), so an ActionDispatch::IntegrationTest is used — it runs the full middleware
# stack and exercises the to_prepare patch in clearance_session_security.rb.
class ClickjackingProtectionTest < ActionDispatch::IntegrationTest
  describe 'GET /sessions/new (Clearance::SessionsController)' do
    it 'sets X-Frame-Options: SAMEORIGIN' do
      get new_session_path

      _(response.headers['X-Frame-Options']).must_equal 'SAMEORIGIN'
    end

    it 'includes frame-ancestors \'self\' in Content-Security-Policy' do
      get new_session_path

      _(response.headers['Content-Security-Policy']).must_include "frame-ancestors 'self'"
    end
  end

  describe 'GET /accounts/:id' do
    it 'sets X-Frame-Options: SAMEORIGIN' do
      account = create(:account)
      get account_path(account)

      _(response.headers['X-Frame-Options']).must_equal 'SAMEORIGIN'
    end

    it 'includes frame-ancestors \'self\' in Content-Security-Policy' do
      account = create(:account)
      get account_path(account)

      _(response.headers['Content-Security-Policy']).must_include "frame-ancestors 'self'"
    end
  end
end
