module Reverification
  class Process
    class << self
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

      def transient_bounce_queue
        @transient_bounce_queue ||= sqs.queues.named('ses-transientbounces-queue')
      end

      def ses_limit_reached?
        ses.quotas[:sent_last_24_hours] == ses.quotas[:max_24_hour_send]
      end

      def send(template)
        return if ses_limit_reached?
        ses.send_email(template)
      end

      def send_to_transient_bounce_queue(recipient)
        account = Account.find_by_email recipient['emailAddress']
        account.reverification_tracker.soft_bounced!
        transient_bounce_queue.send_message recipient['emailAddress']
      end

      def poll_success_queue
        success_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          message_hash = msg.as_sns_message.body_message_as_h
          message_hash['delivery']['recipients'].each do |recipient|
            account = Account.find_by_email recipient
            if account.reverification_tracker.pending?
              account.reverification_tracker.delivered!
            end
          end
        end
      end

      def poll_bounce_queue
        bounce_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          decoded_msg = msg.as_sns_message.body_message_as_h
          decoded_msg['bounce']['bouncedRecipients'].each do |recipient|
            case decoded_msg['bounce']['bounceType']
            when 'Undetermined'
              send_to_transient_bounce_queue(recipient)
            when 'Permanent'
              ReverificationTracker.destroy_account(recipient['emailAddress'])
            when 'Transient'
              send_to_transient_bounce_queue(recipient)
            end
          end
        end
      end

      def poll_complaints_queue
        complaints_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          decoded_msg(msg)['complaint']['complainedRecipients'].each do |recipient|
            account = Account.find_by_email recipient['emailAddress']
            account.reverification_tracker.complained!
            account.reverification_tracker.update feedback: decoded_msg['complaint']['complaintFeedbackType']
          end
        end
      end

      # Note: How can I modify this to handle the emails that are also in success queue?
      def poll_transient_bounce_queue
        transient_bounce_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          email_address = msg.body
          rev_tracker = Account.find_by_email(email_address).reverification_tracker
          ReverificationTracker.determine_correct_notification_to_send(rev_tracker)
        end
      end
    end
  end
end