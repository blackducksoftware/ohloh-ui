# frozen_string_literal: true

allowed_script_sources = %w[https://www.google.com https://www.gstatic.com https://maps.googleapis.com
                            https://maps.gstatic.com https://s7.addthis.com https://cdnjs.cloudflare.com
                            https://www.googletagmanager.com]

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.connect_src :self, :https, 'maps.googleapis.com'
  policy.font_src :self, :https, :data
  policy.img_src :self, :https, :data
  policy.object_src :none
  policy.script_src :self, *allowed_script_sources
  policy.style_src :self, :https, :unsafe_inline
  policy.base_uri :self
  policy.form_action :self
end

Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
