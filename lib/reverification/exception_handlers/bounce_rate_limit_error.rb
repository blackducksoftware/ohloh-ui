# frozen_string_literal: true

module Reverification::ExceptionHandlers
  class BounceRateLimitError < SimpleEmailServiceLimitError; end
end
