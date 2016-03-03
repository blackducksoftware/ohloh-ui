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

      def ses_limit_reached?
        ses.quotas[:sent_last_24_hours] == ses.quotas[:max_24_hour_send]
      end

      def send(template, account, phase)
        return if ses_limit_reached?
        resp = ses.send_email(template)
        if account.reverification_tracker
           # Note: Increment the attempts counter for retry. For new notification, resets attempts counter as 1

          # In mailer.rb the send method has hard coded values of 0, 1, 2, 3, 
          # In addition, the resend_soft_bounced_notifications checks for the correct phase.
          # Won't the line of code below always be true?

          # if phase == ReverificationTracker.phases[account.reverification_tracker.phase]
          #   account.reverification_tracker.increment! :attempts
          # else
          #   account.reverification_tracker.update attempts: 1
          # end
          # account.reverification_tracker.update(message_id: resp[:message_id], status: 0, phase: phase, sent_at: Time.now)
          
          if account.reverification_tracker.attempts >= 3
             account.reverification_tracker.update(message_id: resp[:message_id], status: 0, phase: phase + 1, sent_at: Time.now, attempts: 1)
          else
            account.reverification_tracker.increment! :attempts
            return
          end
        else
          account.create_reverification_tracker(message_id: resp[:message_id], sent_at: Time.now)
        end
      end

      def poll_success_queue
        success_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          message_hash = msg.as_sns_message.body_message_as_h
          message_hash['delivery']['recipients'].each do |recipient|
            account = Account.find_by_email recipient
            account.reverification_tracker.delivered! if account.reverification_tracker.pending?
          end
        end
      end

      def poll_bounce_queue
        bounce_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          decoded_msg = msg.as_sns_message.body_message_as_h
          decoded_msg['bounce']['bouncedRecipients'].each do |recipient|
            account = Account.find_by_email recipient['emailAddress']
            notification = account.reverification_tracker
            case decoded_msg['bounce']['bounceType']
            when 'Permanent'
              ReverificationTracker.destroy_account(recipient['emailAddress'])
            when 'Transient', 'Undetermined'
              notification.soft_bounced!
            end
          end
        end
      end

      def poll_complaints_queue
        complaints_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
          decoded_msg = msg.as_sns_message.body_message_as_h
          decoded_msg['complaint']['complainedRecipients'].each do |recipient|
            account = Account.find_by_email recipient['emailAddress']
            account.reverification_tracker.complained!
            account.reverification_tracker.update feedback: decoded_msg['complaint']['complaintFeedbackType']
          end
        end
      end
    end
  end
end
