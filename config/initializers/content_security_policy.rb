# frozen_string_literal: true

allowed_script_sources = %w[www.google.com cdn.firebase.com www.gstatic.com s7.addthis.com cdnjs.cloudflare.com]

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src :self, :https, :data
  policy.img_src :self, :https, :data
  policy.object_src :none
  policy.script_src :self, :https, :unsafe_eval, *allowed_script_sources
  policy.style_src :self, :https, :unsafe_inline
  policy.report_uri '/csp-violation-report'
end

Rails.application.config.content_security_policy_report_only = true
