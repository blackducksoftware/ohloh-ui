module Reverification
  class SimpleEmailServiceLimitError < Exception
    #  Ask Johnson about the specifics of this method.
    # def to_s
    #   Process.start_polling_queues
    #   super
    # end
  end
  class BounceRateLimitError < SimpleEmailServiceLimitError; end
  class ComplaintRateLimitError < SimpleEmailServiceLimitError; end
end
