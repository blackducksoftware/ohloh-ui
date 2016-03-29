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
      @success_queue ||= sqs.queues.named('ses-success-queue')
    end

    def bounce_queue
      @bounce_queue ||= sqs.queues.named('ses-bounces-queue')
    end

    def complaints_queue
      @complaints_queue ||= sqs.queues.named('ses-complaints-queue')
    end

    def ses_daily_limit_available
      quotas = ses.quotas
      PILOT_AMOUNT - quotas[:sent_last_24_hours]
    end
  end
end
