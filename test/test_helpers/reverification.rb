# frozen_string_literal: true

# Note: These classes are used for mocking Reverification Aws::SES responses and messages.
#        Used for the spammer cleanup initiative.
module MOCK
  module AWS
    class SimpleEmailService
      class << self
        def amazon_stat_settings
          { bounce_rate: 5.0, amount_of_email: 1000.0 }
        end

        def send_quota
          Struct.new(:max_24_hour_send, :max_send_rate, :sent_last_24_hours)
                .new(5000, 1.0, 50)
        end

        def response
          { message_id: "XYZ0-1234-AB56-67GJ-#{Time.now.utc.to_i}" }
        end

        def under_bounce_limit
          Struct.new(:send_data_points).new(
            [{ timestamp: Time.now.utc - 10.hours, delivery_attempts: 0, rejects: 0, bounces: 1, complaints: 0 },
             { timestamp: Time.now.utc - 8.hours, delivery_attempts: 0, rejects: 0, bounces: 0, complaints: 0 },
             { timestamp: Time.now.utc - 3.hours, delivery_attempts: 0, rejects: 0, bounces: 0, complaints: 0 }]
          )
        end

        def over_bounce_limit
          Struct.new(:send_data_points).new(
            [{ timestamp: Time.now.utc - 10.hours, delivery_attempts: 0, rejects: 0, bounces: 48, complaints: 0 },
             { timestamp: Time.now.utc - 8.hours, delivery_attempts: 0, rejects: 0, bounces: 2, complaints: 0 },
             { timestamp: Time.now.utc - 3.hours, delivery_attempts: 0, rejects: 0, bounces: 6, complaints: 0 }]
          )
        end

        def under_complaint_limit
          Struct.new(:send_data_points).new(
            [{ timestamp: Time.now.utc - 10.hours, delivery_attempts: 0, rejects: 0, bounces: 0, complaints: 0 },
             { timestamp: Time.now.utc - 8.hours, delivery_attempts: 0, rejects: 0, bounces: 0, complaints: 0 },
             { timestamp: Time.now.utc - 3.hours, delivery_attempts: 0, rejects: 0, bounces: 0, complaints: 0 }]
          )
        end

        def over_complaint_limit
          Struct.new(:send_data_points).new(
            [{ timestamp: Time.now.utc - 10.hours, delivery_attempts: 0, rejects: 0, bounces: 0, complaints: 2 },
             { timestamp: Time.now.utc - 8.hours, delivery_attempts: 0, rejects: 0, bounces: 0, complaints: 0 },
             { timestamp: Time.now.utc - 3.hours, delivery_attempts: 0, rejects: 0, bounces: 0, complaints: 0 }]
          )
        end
      end
    end

    module SQS
      class QueueCollection
        def named(queue_name)
          Queue.new(queue_name)
        end
      end

      class Queue
        def initialize(queue_name)
          @queue_name = queue_name
        end

        def url
          'https://sqs.us-east-1.amazonaws.com/637372123053/' + @queue_name
        end
      end
    end
  end
end

class UndeterminedBounceBody
  def body_message_as_h
    {
      bounce: { bounceType: 'Undetermined',
                bouncedRecipients: [{ emailAddress: 'someone@gmail.com' }] }
    }.with_indifferent_access
  end
end

class UndeterminedBounceMessage
  def as_sns_message
    UndeterminedBounceBody.new
  end
end

class HardBounceBody
  def body_message_as_h
    {
      bounce: { bounceType: 'Permanent',
                bouncedRecipients: [{ emailAddress: 'bounce@simulator.amazonses.com' }] }
    }.with_indifferent_access
  end
end

class HardBounceMessage
  def as_sns_message
    HardBounceBody.new
  end
end

class SuccessBody
  def body_message_as_h
    { delivery: { recipients: ['success@simulator.amazonses.com'] } }.with_indifferent_access
  end
end

class SuccessMessage
  def as_sns_message
    SuccessBody.new
  end
end

class TransientBounceBody
  def body_message_as_h
    {
      bounce: { bounceType: 'Transient',
                bouncedRecipients: [{ emailAddress: 'ooto@simulator.amazonses.com' }] }
    }.with_indifferent_access
  end
end

class TransientBounceMessage
  def as_sns_message
    TransientBounceBody.new
  end

  def body
    'ooto@simulator.amazonses.com'
  end
end

class ComplaintBody
  def body_message_as_h
    {
      complaint: { complainedRecipients: [{ emailAddress: 'complaint@simulator.amazonses.com' }],
                   complaintFeedbackType: 'abuse' }
    }.with_indifferent_access
  end
end

class ComplaintMessage
  def as_sns_message
    ComplaintBody.new
  end
end
