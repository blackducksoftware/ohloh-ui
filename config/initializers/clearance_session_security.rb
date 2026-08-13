# frozen_string_literal: true

# CWE-1021: Prevent clickjacking on session pages.
#
# GET /sessions/new and DELETE /sessions are routed directly to
# Clearance::SessionsController (bypassing our SessionsController subclass),
# so security headers are added here via to_prepare, which re-runs on every
# code reload in development and once at boot in production.
Rails.application.config.to_prepare do
  Clearance::SessionsController.class_eval do
    # Uses after_action (not content_security_policy DSL) so it runs even when a before_action redirects.
    after_action :set_clickjacking_headers_on_session

    private

    def set_clickjacking_headers_on_session
      response.headers['X-Frame-Options'] = 'SAMEORIGIN'
      if (policy = request.content_security_policy)
        modified = policy.clone
        modified.frame_ancestors :self
        request.content_security_policy = modified
      end
    end
  end
end
