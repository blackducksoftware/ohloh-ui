module Reverification
  module Amazon
    include Reverification::ExceptionHandlers

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

    def amazon_stat_settings
      @amazon_stat_settings ||= {}
    end

    def set_amazon_stat_settings(bounce_rate, amount_of_email)
      amazon_stat_settings[:bounce_rate] = bounce_rate.to_f
      amazon_stat_settings[:amount_of_email] = amount_of_email.to_f
    end

    def sent_last_24_hrs
      ses.quotas[:sent_last_24_hours].to_f
    end

    def send_limit
      # ses.quotas[:max_24_hour_send] - ses.quotas[:sent_last_24_hours]
      2000
    end

    def statistics_of_last_24_hrs
      ses.statistics.find_all { |s| s[:sent].between?(Time.now.utc - 24.hours, Time.now.utc) }
    end

    def check_statistics_of_last_24_hrs
      stats = statistics_of_last_24_hrs

      if bounce_rate(stats) >= amazon_stat_settings[:bounce_rate]
        raise(BounceRateLimitError, 'Bounce Rate exceeded')
      end
      raise(ComplaintRateLimitError, 'Complaint Rate exceeded 0.1%') if complaint_rate(stats) >= 0.1
    end

    def check_statistics_and_wait_to_avoid_exceeding_throttle_limit
      check_statistics_of_last_24_hrs if sent_last_24_hrs >= amazon_stat_settings[:amount_of_email]
      sleep(3)
    end
  end
end
