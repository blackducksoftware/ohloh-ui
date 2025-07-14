# frozen_string_literal: true

module Reverification
  module Amazon
    include Reverification::ExceptionHandlers

    def ses
      @ses ||= Aws::SES::Client.new
    end

    def sqs
      @sqs ||= Aws::SQS::Resource.new
    end

    def success_queue
      @success_queue ||= sqs.queues.named(ENV.fetch('AWS_SQS_SUCCESS_QUEUE', nil))
    end

    def bounce_queue
      @bounce_queue ||= sqs.queues.named(ENV.fetch('AWS_SQS_BOUNCE_QUEUE', nil))
    end

    def complaints_queue
      @complaints_queue ||= sqs.queues.named(ENV.fetch('AWS_SQS_COMPLAINT_QUEUE', nil))
    end

    def bad_email_queue
      @bad_email_queue ||= sqs.queues.named(ENV.fetch('AWS_SQS_BAD_EMAIL_QUEUE', nil))
    end

    def amazon_stat_settings
      @amazon_stat_settings ||= {}
    end

    def set_amazon_stat_settings(bounce_rate, amount_of_email)
      amazon_stat_settings[:bounce_rate] = bounce_rate.to_f
      amazon_stat_settings[:amount_of_email] = amount_of_email.to_f
    end

    def sent_last_24_hrs
      response = ses.get_send_quota
      response.sent_last_24_hours
    end

    def send_limit
      response = ses.get_send_quota
      response.max_24_hour_send - response.sent_last_24_hours
    end

    def statistics_of_last_24_hrs
      response = ses.get_send_statistics.to_h
      response[:send_data_points].find_all { |s| s[:timestamp].between?(Time.now.utc - 24.hours, Time.now.utc) }
    end

    def check_statistics_of_last_24_hrs
      stats = statistics_of_last_24_hrs

      raise(BounceRateLimitError, 'Bounce Rate exceeded') if bounce_rate(stats) >= amazon_stat_settings[:bounce_rate]
      raise(ComplaintRateLimitError, 'Complaint Rate exceeded 0.1%') if complaint_rate(stats) >= 0.1
    end

    def check_statistics_and_wait_to_avoid_exceeding_throttle_limit
      check_statistics_of_last_24_hrs if sent_last_24_hrs >= amazon_stat_settings[:amount_of_email]
      sleep(3)
    end
  end
end
