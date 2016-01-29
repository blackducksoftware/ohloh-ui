class AccountReverification

  class << self
    def run
      # Business code goes here. This is where the timing logic is going to go etc.
      retry_notification if messages_in_the_transient_bounce_queue?
      send_first_notification
    end

    def messages_in_the_transient_bounce_queue?
      transient_bounce_queue.approximate_number_of_messages != 0 ? true : false
    end

    def retry_notification
      abort 'Reached AWS sending limit' if ses_limit_reached?
      transient_bounce_queue.receive_message do |msg|
      ses.send_email(
        to: "#{msg.body}",
        subject: 'Please reverify your Open Hub account',
        from: 'info@openhub.net',
        body_text: message)
      end
      poll_bounce_queue
    end

    def send_first_notification
      accounts_without_verifications(1).each do |account|
      ses.send_email(to: "#{account}",
          subject: 'Please reverify your Open Hub account',
          from: 'info@openhub.net',
          body_text: message)
        poll_bounce_queue
      end
    end

    def ses
      @ses ||= AWS::SimpleEmailService.new
    end

    def sqs
      @sqs ||= AWS::SQS.new
    end

    def transient_bounce_queue
      @transient_bounce_queue ||= sqs.queues.named('ses-transientbounces-queue')
    end

    def bounce_queue
      @bounce_queue ||= sqs.queues.named('ses-bounces-queue')
    end

    def ses_limit_reached?
      ses.quotas[:sent_last_24_hours] == ses.quotas[:max_24_hour_send]
    end

    def message
      "Hello #{account}, as an effort to eliminate excessive spam accounts, Open Hub has provided you the following link in order
               to reverify your account with us. Please click on the reverification link www.openhub.net/authentications/new
               within 30 days so that you may continue to enjoy our services. Please note that if you fail
               to verify your account within 30 days, Open Hub will flag your account as spam. Thank you!

               Sincerely,

               The Open Hub Team

               8 New England Executive Park, Burlington, MA 01803"
    end

    def destroy_account(email_address)
      account = Account.find_by_email(email_address)
      account.destroy unless account.nil?
    end

    def store_email_for_later_retry(email_address)
      transient_bounce_queue = sqs.queues.named('ses-transientbounces-queue')
      transient_bounce_queue.send_message("#{email_address}")
    end

    def poll_bounce_queue
      bounce_queue.poll(initial_time: false, idle_timeout: 10) do |msg|
        process_bounce(msg.as_sns_message.body_message_as_h)
      end
    end

    def process_bounce(email)
      # puts "#{email}"
      email_address = email['bounce']['bouncedRecipients'][0]['emailAddress']
      bounce_type = email['bounce']['bounceType']
      if bounce_type == 'Permanent'
        destroy_account(email_address)
      else
        store_email_for_later_retry(email_address)
      end
    end

    def accounts_without_verifications(limit)
      # NOTE: This needs to be sure to grab the correct accounts for reverification!!!
      # I might need to add another argument for reverificatoin_attempt and reverification_notice
      ['complaint@simulator.amazonses.com', 'bounce@simulator.amazonses.com',
       'ooto@simulator.amazonses.com', 'success@simulator.amazonses.com', ]
      # Account.find_by_sql("SELECT accounts.email, accounts.name FROM accounts
      #                     LEFT OUTER JOIN verifications ON verifications.account_id = accounts.id
      #                     WHERE verifications.account_id is NULL LIMIT #{limit}")
    end
  end
end