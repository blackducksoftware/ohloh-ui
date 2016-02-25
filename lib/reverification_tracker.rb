# rubocop:disable Metrics/ClassLength
class ReverificationTracker < ActiveRecord::Base
  belongs_to :account
  enum status: [:initial, :marked_for_spam, :spam, :final_warning]

  class << self
    def one_day_before_deletion_notice(email)
      { to: "#{email}",
        subject: 'Your Account Will Be Deleted Tomorrow: Please Reverify',
        from: 'info@openhub.net',
        body_text:  "Hello, you are receiving this notice because Open Hub has determined that this account is spam
          and will be deleted from the website tomorrow. If this is incorrect, please click on the reverification link
          www.openhub.net/authentications/new in order to restore your account. Failure to do so by tomorrow
          will result in your account's deletion and will no longer be able to be restored.
          Please reverify your account by tomorrow so that you may continue to enjoy our services.

          Sincerely,

          The Open Hub Team

          8 New England Executive Park, Burlington, MA 01803" }
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

    def spam_phase_accounts(limit)
      ReverificationTracker.spam.limit(limit)
    end

    def marked_for_spam_phase_accounts(limit)
      ReverificationTracker.marked_for_spam.limit(limit)
    end

    def initial_phase_accounts(limit)
      ReverificationTracker.initial.limit(limit)
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

    def poll_success_queue
      success_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
        message_as_hash = msg.as_sns_message.body_message_as_h
        account = Account.find_by_email(message_as_hash['mail']['delivery']['recipients'][0])
        if account.reverification_tracker.nil?
          create_reverification_tracker(account)
        else
          update_reverification_tracker(account)
        end
      end
    end

    def transient_bounce_queue
      @transient_bounce_queue ||= sqs.queues.named('ses-transientbounces-queue')
    end

    def poll_transient_bounce_queue
      return if ses_limit_reached?
      transient_bounce_queue.poll(initial_timeout: 1, idle_timeout: 1) do |msg|
        email_address = msg.body
        account = Account.find_by_email(email_address)
        if account.reverification_tracker.present?
          determine_correct_notification_to_send(account)
        else
          ses.send_email(first_reverification_notice(account.email))
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
      account = Account.find_by_email(email_address)
      account.destroy if account
    end

    def determine_correct_notification_to_send(account)
      # I need to figure out how to condense this or disable rubocop warning.
      if account.reverification_tracker.spam?
        ses.send_email(one_day_before_deletion_notice(account.email))
      elsif account.reverification_tracker.marked_for_spam?
        ses.send_email(account_is_spam_notice(account.email))
      else
        ses.send_email(marked_for_spam_notice(account.email))
      end
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

    def delete_unverified_spam_accounts
      Account.where(level: -20).includes(:reverification_tracker).find_each do |account|
        if account.reverification_tracker.final_warning? && gt_equal(account.reverification_tracker.updated_at)
          account.destroy
        end
      end
    end

    def update_reverification_tracker(account)
      if account.reverification_tracker.spam?
        account.reverification_tracker.final_warning!
      elsif account.reverification_tracker.marked_for_spam?
        account.access.spam!
        account.reverification_tracker.spam!
      else
        account.reverification_tracker.marked_for_spam!
      end
    end

    def create_reverification_tracker(account)
      account.reverification_tracker = AccountReverification.create
      account.reverification_tracker.initial!
    end

    # TODO: This needs to be rigorously tested!
    def time_is_right?(reverification_tracker)
      if reverification_tracker.spam? || reverification_tracker.marked_for_spam?
        Time.now.utc >= (updated_at + 1.day)
      else
        Time.now.utc >= (updated_at + 1.day)
      end
    end

    def send_one_day_left_before_deletion_notification
      return if ses_limit_reached?
      spam_phase_accounts(5).each do |rev_track|
        time_is_right?(rev_track) if ses.send_email(one_day_before_deletion_notice(rev_track.account.email))
      end
    end

    def send_account_is_spam_notification
      return if ses_limit_reached?
      marked_for_spam_phase_accounts(5).each do |rev_track|
        time_is_right?(rev_track) if ses.send_email(account_is_spam_notice(rev_track.account.email))
      end
    end

    def send_marked_for_spam_notification
      return if ses_limit_reached?
      initial_phase_accounts(5).each do |rev_track|
        time_is_right?(rev_track) if ses.send_email(marked_for_spam_notice(rev_track.account.email))
      end
    end

    def send_first_notification
      return if ses_limit_reached?
      Account.unverified_accounts(5).each do |account|
        ses.send_email(first_reverification_notice(account.email))
      end
    end

    def run
      delete_unverified_spam_accounts
      send_one_day_left_before_deletion_notification
      send_account_is_spam_notification
      send_marked_for_spam_notification
      send_first_notification
    end

    def remove_reverification_tracker_for_validated_accounts
      ReverificationTracker.find_each do |rev_tracker|
        rev_tracker.destroy if rev_tracker.account.access.mobile_or_oauth_verified?
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
