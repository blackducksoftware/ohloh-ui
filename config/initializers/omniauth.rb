# frozen_string_literal: true

OmniAuth.config.allowed_request_methods = %i[post]

Rails.application.config.middleware.insert_after(ActionDispatch::Session::CookieStore, OmniAuth::Builder) do
  provider :saml,
           sp_entity_id: ENV.fetch('SAML_SP_ENTITY_ID', nil),
           assertion_consumer_service_url: ENV.fetch('OKTA_ACS_URL', nil),
           idp_sso_service_url: ENV.fetch('OKTA_IDP_SSO_TARGET_URL', nil),
           idp_cert: ENV.fetch('OKTA_IDP_CERT', nil),
           name_identifier_format: 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
           attribute_statements: { email: ['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] }
end
