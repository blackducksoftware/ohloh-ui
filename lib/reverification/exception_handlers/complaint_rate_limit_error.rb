# frozen_string_literal: true

module Reverification::ExceptionHandlers
  class ComplaintRateLimitError < SimpleEmailServiceLimitError; end
end
