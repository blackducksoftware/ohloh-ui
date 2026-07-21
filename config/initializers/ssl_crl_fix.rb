# frozen_string_literal: true

# In development, Zscaler SSL inspection proxy intercepts HTTPS traffic and
# replaces server certificates with its own. Those replacement certs include
# CRL Distribution Point (CDP) extensions whose URLs are unreachable, causing:
#   SSL_connect: certificate verify failed (unable to get certificate CRL)
#
# This initializer installs a verify callback that allows CRL-check failures
# through in development while keeping all other certificate checks intact.
if Rails.env.development?
  require 'openssl'

  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.merge!(
    verify_callback: proc do |preverify_ok, store_ctx|
      if !preverify_ok && store_ctx.error == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL
        Rails.logger.debug { "[SSL] Skipping CRL check failure for: #{store_ctx.current_cert&.subject}" }
        true
      else
        preverify_ok
      end
    end
  )
end
