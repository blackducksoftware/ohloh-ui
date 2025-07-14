# frozen_string_literal: true

module Patterns
  DEFAULT_PARAM_FORMAT = /\A[[:alpha:]][[:alnum:]_-]*\Z/

  BAD_NAME = /(=|;|--|:\/\/)/
  BAD_QUERY = /['=;]/
end
