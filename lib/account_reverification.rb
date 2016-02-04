class AccountReverification
  class << self
    def accounts_without_verifications(limit)
      Account.find_by_sql("SELECT accounts.email, accounts.name FROM accounts
                          LEFT OUTER JOIN verifications ON verifications.account_id = accounts.id
                          WHERE verifications.account_id is NULL LIMIT #{limit}")
    end

    def ses
      @ses ||= AWS::SimpleEmailService.new
    end

    def ses_limit_reached?
      ses.quotas[:sent_last_24_hours] == ses.quotas[:max_24_hour_send]
    end

    def sqs
      @sqs ||= AWS::SQS.new
    end

    def transient_bounce_queue
      @transient_bounce_queue ||= sqs.queues.named('ses-transientbounces-queue')
    end

    def messages_in_the_transient_bounce_queue?
      transient_bounce_queue.approximate_number_of_messages != 0 ? true : false
    end

    def bounce_queue
      @bounce_queue ||= sqs.queues.named('ses-bounces-queue')
    end

    def poll_bounce_queue
      bounce_queue.poll(initial_time: false, idle_timeout: 5) do |msg|
        puts "#{msg}"
        process_bounce(msg.as_sns_message.body_message_as_h)
      end
    end

    def destroy_account(email_address)
      puts "#{email_address}"
      account = Account.find_by_email(email_address)
      account.destroy if account
    end

    def store_email_for_later_retry(email_address)
      transient_bounce_queue.send_message("#{email_address}")
    end

    def process_bounce(email)
      email_address = email['bounce']['bouncedRecipients'][0]['emailAddress']
      bounce_type = email['bounce']['bounceType']
      if bounce_type == 'Permanent'
        destroy_account(email_address)
      else
        store_email_for_later_retry(email_address)
      end
    end

    def first_reverification_notice(account)
      { to: "#{account.email}",
      subject: 'Please reverify your Open Hub account',
      from: 'info@openhub.net',
      body_text:  "Hello #{account.name}, as an effort to eliminate excessive spam accounts, Open Hub has provided you the following link in order
        to reverify your account with us. Please click on the reverification link www.openhub.net/authentications/new
        within 30 days so that you may continue to enjoy our services. Please note that if you fail
        to verify your account within 30 days, Open Hub will flag your account as spam. Thank you!

        Sincerely,

        The Open Hub Team

        8 New England Executive Park, Burlington, MA 01803" }
    end

    def send_first_notification
      return if ses_limit_reached?
      accounts_without_verifications(5).each do |account|
        puts "#{account}"
        ses.send_email(first_reverification_notice(account))
      end
    end

    def run
      # retry_notification if messages_in_the_transient_bounce_queue?
      # poll_bounce_queue
      # poll_complaint_queue
      # send_final_deletion_warnings
      # send_made_spammer_notifications
      # send_making_spammer_warnings
      send_first_notification
      poll_bounce_queue
      #poll_complaint_queue
    end
  end
end

 # def retry_notification_notice(account)
 #      { to: "#{account.email}",
 #      subject: 'Please reverify your Open Hub account',
 #      from: 'info@openhub.net',
 #      body_text:  "Hello #{account.name}, as an effort to eliminate excessive spam accounts, Open Hub has provided you the following link in order
 #        to reverify your account with us. Please click on the reverification link www.openhub.net/authentications/new
 #        within 30 days so that you may continue to enjoy our services. Please note that if you fail
 #        to verify your account within 30 days, Open Hub will flag your account as spam. Thank you!

 #        Sincerely,

 #        The Open Hub Team

 #        8 New England Executive Park, Burlington, MA 01803" }
 #    end

    # def retry_notification
    #   abort 'Reached AWS sending limit' if ses_limit_reached?
    #   transient_bounce_queue.receive_message do |msg|
    #   ses.send_email(retry_notification_notice)
    #   poll_bounce_queue
    #   end
    # end
