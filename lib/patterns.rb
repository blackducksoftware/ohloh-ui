# frozen_string_literal: true

module Patterns
  DEFAULT_PARAM_FORMAT = /\A[[:alpha:]][[:alnum:]_-]*\Z/.freeze

  BAD_NAME = /(=|;|--|:\/\/)/.freeze
  BAD_QUERY = /['=;]/.freeze
end
