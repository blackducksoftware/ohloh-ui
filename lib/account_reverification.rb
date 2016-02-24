class ReverificationTracker < ActiveRecord::Base
  belongs_to :account

  class << self
    def right_now
      @right_now = Time.now.utc
    end

    def gt_equal(date)
      right_now >= date
    end

    def second_phase_accounts(limit)
      Account.find_by_sql("SELECT accounts.email FROM accounts
                            INNER JOIN reverification_trackers
                          ON accounts.id = reverification_trackers.account_id 
                            LEFT OUTER JOIN verifications 
                          ON verifications.account_id = accounts.id
                            WHERE verifications.account_id is NULL
                          AND reverification_trackers.status = 'marked for spam' LIMIT #{limit}") 
    end

    def first_phase_accounts(limit)
      Account.find_by_sql("SELECT accounts.email FROM accounts
                            INNER JOIN reverification_trackers
                          ON accounts.id = reverification_trackers.account_id 
                            LEFT OUTER JOIN verifications 
                          ON verifications.account_id = accounts.id
                            WHERE verifications.account_id is NULL
                          AND reverification_trackers.status = 'initial' LIMIT #{limit}") 
    end

    def unverified_accounts(limit)
      Account.find_by_sql("SELECT accounts.email FROM accounts
                            LEFT OUTER JOIN verifications 
                          ON verifications.account_id = accounts.id
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

    def success_queue
      @success_queue ||= sqs.queues.named('ses-success-queue')
    end

    def find_account_by_email(email)
      Account.find_by_email(email)
    end

    def poll_success_queue
      success_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
        message_as_hash = msg.as_sns_message.body_message_as_h
        account = find_account_by_email(message_as_hash['mail']['delivery']['recipients'][0])
        account.reverification_tracker == nil ? create_reverification_tracker(account) : update_reverification_tracker(account)
      end
    end

    def transient_bounce_queue
      @transient_bounce_queue ||= sqs.queues.named('ses-transientbounces-queue')
    end

    def poll_transient_bounce_queue
      return if ses_limit_reached?
      transient_bounce_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
        email_address = msg.body
        account = find_account_by_email(email_address)
        if account.reverification_tracker.nil?
          ses.send_email(first_reverification_notice(email_address))
        elsif account.reverification_tracker.present? && account.reverification_tracker.status == 'marked for spam'
          ses.send_email(account_is_spam_notice(email_address))
        else 
          ses.send_email(marked_for_spam_notice(email_address))
        end
      end
    end

    def bounce_queue
      @bounce_queue ||= sqs.queues.named('ses-bounces-queue')
    end

    def poll_bounce_queue
      bounce_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
        process_bounce(msg.as_sns_message.body_message_as_h)
      end
    end

    def destroy_account(email_address)
      account = find_account_by_email(email_address)
      account.destroy if account
    end

    def store_email_for_later_retry(email_address)
      transient_bounce_queue.send_message(email_address)
    end

    def process_bounce(message_body)
      email_address = message_body['bounce']['bouncedRecipients'][0]['emailAddress']
      bounce_type = message_body['bounce']['bounceType']
      if bounce_type == 'Permanent'
        destroy_account(email_address)
      else
        store_email_for_later_retry(email_address)
      end
    end

    def convert_to_spam(account)
      account.access.spam!
    end

    def update_reverification_tracker(account)
      if account.reverification_tracker.status == 'marked for spam'
        convert_to_spam(account)
        account.reverification_tracker.update(status: 'spam', updated_at: DateTime.now.utc)
      else
        account.reverification_tracker.update(status: 'marked for spam', updated_at: DateTime.now.utc)
      end
    end

    def create_reverification_tracker(account)
      account.reverification_tracker = AccountReverification.create
    end

    # Note: Don't forget to internationalize and test
    def account_is_spam_notice(email)
       { to: "#{email}",
        subject: 'Your Account Status Has Converted to Spam',
        from: 'info@openhub.net',
        body_text:  "Hello, you are receiving this notice because Open Hub has determined that this account is spam
          and has changed the status of your account to spam in its system. If this is incorrect, please click
          on the reverification link www.openhub.net/authentications/new in order to restore your account. Failure
          to do so will result in your account's eventual deletion. Please reverify your account within 7 days
          so that you may continue to enjoy our services. Please note that if you fail
          to verify in this time period, your account and all data associated it will be deleted from the system.

          Sincerely,

          The Open Hub Team

          8 New England Executive Park, Burlington, MA 01803" }
    end

    # Note: Don't forget to internationalize and test
    def marked_for_spam_notice(email)
      { to: "#{email}",
        subject: 'Account Marked for Spam',
        from: 'info@openhub.net',
        body_text:  'As an effort to eliminate excessive spam accounts, Open Hub has provided you the following link in order
          to reverify your account with us. Please click on the reverification link www.openhub.net/authentications/new
          within 24 hours so that you may continue to enjoy our services. Please note that if you fail
          to verify your account within 24 hours, Open Hub will flag your account as spam. Thank you.

          Sincerely,

          The Open Hub Team

          8 New England Executive Park, Burlington, MA 01803' }
    end

    # Note: Don't forget to internationalize and test
    def first_reverification_notice(email)
      { to: "#{email}",
        subject: 'Please Reverify Your Open Hub Account',
        from: 'info@openhub.net',
        body_text:  'As an effort to eliminate excessive spam accounts, Open Hub has provided you the following link in order
          to reverify your account with us. Please click on the reverification link www.openhub.net/authentications/new
          within 2 weeks so that you may continue to enjoy our services. Please note that if you fail
          to verify your account within 2 weeks, Open Hub will flag your account as spam. Thank you.

          Sincerely,

          The Open Hub Team

          8 New England Executive Park, Burlington, MA 01803' }
    end

    # TODO: This needs to be rigorously tested
    def time_is_right?(created_at, updated_at, status)
      if status == 'marked for spam'
        gt_equal(updated_at + 1.day) 
      else
        gt_equal(created_at + 13.days)
      end
    end

    def send_account_is_spam_notification
      return if ses_limit_reached?
      second_phase_accounts(5).each do |account|
        account = find_account_by_email(account.email)
        created_at = account.reverification_tracker.created_at
        updated_at = account.reverification_tracker.updated_at
        status = account.reverification_tracker.status
        time_is_right?(created_at, updated_at, status) ? ses.send_email(account_is_spam_notice(account.email)) : return
      end
    end

    def send_marked_for_spam_notification
      return if ses_limit_reached?
      first_phase_accounts(5).each do |account|
        account = find_account_by_email(account.email)
        created_at = account.reverification_tracker.created_at
        updated_at = account.reverification_tracker.updated_at
        status = account.reverification_tracker.status
        time_is_right?(created_at, updated_at, status) ? ses.send_email(marked_for_spam_notice(account.email)) : return
      end
    end

    def send_first_notification
      return if ses_limit_reached?
      unverified_accounts(5).each do |account|
        ses.send_email(first_reverification_notice(account.email)) 
      end
    end

    def run
      poll_success_queue
      poll_transient_bounce_queue
      poll_bounce_queue
      send_account_is_spam_notification
      send_marked_for_spam_notification
      send_first_notification
      poll_success_queue
      poll_transient_bounce_queue
      poll_bounce_queue
    end
  end
end
