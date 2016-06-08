module Reverification
  module Amazon
    def ses
      @ses ||= AWS::SimpleEmailService.new
    end

    def sqs
      @sqs ||= AWS::SQS.new
    end

    def success_queue
      @success_queue ||= sqs.queues.named(ENV['AWS_SQS_SUCCESS_QUEUE'])
    end

    def bounce_queue
      @bounce_queue ||= sqs.queues.named(ENV['AWS_SQS_BOUNCE_QUEUE'])
    end

    def complaints_queue
      @complaints_queue ||= sqs.queues.named(ENV['AWS_SQS_COMPLAINT_QUEUE'])
    end
  end
end
