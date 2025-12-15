# frozen_string_literal: true

class MimeTypeSanitizer
  VALID_MIME_PATTERN = %r{\A[a-zA-Z0-9][\w.+-]*/[a-zA-Z0-9][\w.+-]*\z}
  WILDCARD_SUBTYPE_PATTERN = %r{\A[a-zA-Z0-9][\w.+-]*/\*\z}

  def initialize(app)
    @app = app
  end

  def call(env)
    # Validate Accept header
    if env['HTTP_ACCEPT'].present? && !valid_accept_header?(env['HTTP_ACCEPT'])
      return [406, { 'Content-Type' => 'text/plain' }, ['Not Acceptable: Invalid Accept header']]
    end

    # Validate Content-Type header
    if env['CONTENT_TYPE'].present? && !valid_content_type?(env['CONTENT_TYPE'])
      return [406, { 'Content-Type' => 'text/plain' }, ['Not Acceptable: Invalid Content-Type header']]
    end

    # Reject format=* in query string
    if env['QUERY_STRING']&.match?(/format=[^&]*\*/)
      return [406, { 'Content-Type' => 'text/plain' }, ['Not Acceptable: Invalid format parameter']]
    end

    @app.call(env)
  end

  private

  def valid_accept_header?(accept_header)
    accept_header.split(',').all? do |type|
      type = type.split(';').first.strip
      # Allow */* or type/* or valid type/subtype patterns only
      type == '*/*' || type.match?(WILDCARD_SUBTYPE_PATTERN) || type.match?(VALID_MIME_PATTERN)
    end
  rescue StandardError
    false
  end

  def valid_content_type?(content_type)
    type = content_type.split(';').first&.strip
    return false if type.blank?

    type.match?(VALID_MIME_PATTERN)
  rescue StandardError
    false
  end
end
