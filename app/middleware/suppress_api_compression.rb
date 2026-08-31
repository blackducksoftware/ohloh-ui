# frozen_string_literal: true

# BREACH mitigation (CVE-2013-3587).
#
# HTTP compression over HTTPS creates a side-channel: an attacker who can observe
# compressed response sizes can infer secrets in the response body (BREACH attack).
#
# This middleware disables gzip compression for all /api/* responses by:
#   1. Removing gzip from Accept-Encoding before the request reaches Rack::Deflater,
#      preventing Rails-level compression.
#   2. Setting Content-Encoding: identity on the response, signalling nginx not to
#      apply gzip compression at the infrastructure layer.
class SuppressApiCompression
  API_PATH_PREFIX = '/api/'

  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'].start_with?(API_PATH_PREFIX)
      env['HTTP_ACCEPT_ENCODING'] = strip_gzip(env['HTTP_ACCEPT_ENCODING'])
    end

    status, headers, body = @app.call(env)

    headers['Content-Encoding'] = 'identity' if env['PATH_INFO'].start_with?(API_PATH_PREFIX)

    [status, headers, body]
  end

  private

  def strip_gzip(accept_encoding)
    return accept_encoding if accept_encoding.blank?

    result = accept_encoding
               .gsub(/gzip\s*(;\s*q\s*=\s*[\d.]+)?\s*,?\s*/i, '')
               .gsub(/,\s*$/, '')
               .strip
    result.presence
  end
end
