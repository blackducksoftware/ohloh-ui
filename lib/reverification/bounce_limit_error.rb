module Reverification
  class BounceLimitError < Exception
    def to_s
      Process.start_polling_queues
      super
    end
  end
end
