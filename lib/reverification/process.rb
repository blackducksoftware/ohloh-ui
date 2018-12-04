module Reverification
  class Process
    extend Amazon
    class << self
      def bounce_rate(stats)
        no_of_bounces = stats.inject(0.0) { |a, e| a + e[:bounces] }
        sent_last_24_hrs.zero? ? 0.0 : (no_of_bounces / sent_last_24_hrs) * 100
      end

      def complaint_rate(stats)
        no_of_complaints = stats.inject(0.0) { |a, e| a + e[:complaints] }
        sent_last_24_hrs.zero? ? 0.0 : (no_of_complaints / sent_last_24_hrs) * 100
      end

      def poll_success_queue
        success_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          message_hash = msg.as_sns_message.body_message_as_h
          message_hash['delivery']['recipients'].each do |recipient|
            account = Account.find_by email: recipient
            next unless account.try(:reverification_tracker)
            account.reverification_tracker.delivered! if account.reverification_tracker.pending?
          end
        end
      end

      def poll_bounce_queue
        bounce_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          decoded_msg = msg.as_sns_message.body_message_as_h
          decoded_msg['bounce']['bouncedRecipients'].each do |recipient|
            handle_bounce_notification(decoded_msg['bounce']['bounceType'], recipient['emailAddress'])
          end
        end
      end

      def poll_complaints_queue
        complaints_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          decoded_msg = msg.as_sns_message.body_message_as_h
          decoded_msg['complaint']['complainedRecipients'].each do |recipient|
            rev_tracker = Account.find_by(email: recipient['emailAddress']).try(:reverification_tracker)
            next unless rev_tracker
            rev_tracker.complained!
            rev_tracker.update feedback: decoded_msg['complaint']['complaintFeedbackType']
          end
        end
      end

      def start_polling_queues
        poll_success_queue
        poll_bounce_queue
        poll_complaints_queue
      end

      def handle_bounce_notification(type, recipient)
        rev_tracker = Account.find_by(email: recipient).try(:reverification_tracker)
        return unless rev_tracker
        case type
        when 'Permanent' then ReverificationTracker.destroy_account(recipient)
        when 'Transient', 'Undetermined' then rev_tracker.soft_bounced!
        end
      end
    end
  end
end
