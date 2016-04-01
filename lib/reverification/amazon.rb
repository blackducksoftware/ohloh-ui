module Reverification
  module Amazon
    PILOT_AMOUNT = 5000
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

    def ses_daily_limit_available
      quotas = ses.quotas
      PILOT_AMOUNT - quotas[:sent_last_24_hours]
    end
  end
end
