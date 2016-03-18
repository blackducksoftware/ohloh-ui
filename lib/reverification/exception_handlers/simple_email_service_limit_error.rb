module Reverification
  module ExceptionHandlers
    class SimpleEmailServiceLimitError < Exception
      def to_s
        Process.start_polling_queues
        super
      end
    end
  end
end
