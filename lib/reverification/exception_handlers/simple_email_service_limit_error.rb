module Reverification
  module ExceptionHandlers
    class SimpleEmailServiceLimitError < RuntimeError
      def to_s
        Process.start_polling_queues
        super
      end
    end
  end
end
