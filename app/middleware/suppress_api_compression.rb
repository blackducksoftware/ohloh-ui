# frozen_string_literal: true

# BREACH mitigation (CVE-2013-3587).
#
# HTTP compression over HTTPS creates a side-channel: an attacker who can observe
# compressed response sizes can infer secrets in the response body (BREACH attack).
#
# This middleware disables gzip compression for all /api/* responses by:
#   1. Forcing Accept-Encoding to 'identity' before the request reaches Rack::Deflater,
#      preventing Rails-level compression for any encoding (gzip, deflate, br).
#   2. Setting Content-Encoding: identity on the response (when not already set),
#      signalling nginx not to apply gzip compression at the infrastructure layer.
class SuppressApiCompression
  API_PATH_PREFIX = '/api/'

  def initialize(app)
    @app = app
  end

  def call(env)
    path = env['PATH_INFO'].to_s
    api_request = path == '/api' || path.start_with?(API_PATH_PREFIX)

    # Prevent Rack::Deflater from selecting gzip/deflate for API responses.
    env['HTTP_ACCEPT_ENCODING'] = 'identity' if api_request

    status, headers, body = @app.call(env)

    # Avoid clobbering an existing Content-Encoding set by downstream middleware.
    headers['Content-Encoding'] = 'identity' if api_request && !headers.key?('Content-Encoding')

    [status, headers, body]
  end
end
