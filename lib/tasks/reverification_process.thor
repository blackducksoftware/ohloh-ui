require 'thor/group'
require File.expand_path('config/environment.rb')

module ReverificationTask
  class Reverify < Thor
    desc 'execute [BOUNCE_THRESHOLD] [NUM_EMAIL]', 'Executes the entire reverification process
          specifying when to check statistics through the amount of emails and for what acceptable bounce percentage'
    method_option :bounce_threshold, :aliases => '-bt', :desc => 'Sets bounce rate', :required => true
    method_option :num_email, :aliases => '-e', :desc => 'Sets the amount of email', :required => true

    def execute(bounce_rate, amount_of_email)
      Reverification::Process.set_amazon_stat_settings(bounce_rate, amount_of_email)
      Reverification::Process.cleanup
      Reverification::Mailer.run
      Reverification::Process.start_polling_queues
    end
  end

  class Preparation < Thor
    desc 'pilot_preparation', 'This task does the preparation work for the pilot process'

    def pilot_preparation
      ReverificationPilotAccount.copy_accounts
    end
  end

  class Cleanup < Thor
    desc 'clean_all', 'Invokes all three cleanup tasks'

    def clean_all
      invoke :verified
      invoke :unverified
      invoke :delete_orphaned_rev_trackers
    end

    desc 'verified', 'Removes the reverification trackers of verified accounts'

    def verified
      ReverificationTracker.remove_reverification_trackers_for_verified_accounts
    end

    desc 'unverified', 'Removes unverified accounts'

    def unverified
      ReverificationTracker.delete_expired_accounts
    end

    desc 'delete_orphaned_rev_trackers', 'Removes orphan reverification trackers'

    def delete_orphaned_rev_trackers
      ReverificationTracker.remove_orphans
    end
  end

  class Notifications < Thor
    class ResendAndSend < Thor::Group
      argument :bounce_threshold
      argument :num_email

      desc 'specifies amazon stat settings,
            begins resending to soft bounced accounts,
            and sends email [BOUNCE_THRESHOLD] [NUM_EMAIL]'

      def resend_to_soft_bounced_emails(bounce_rate, amount_of_email)
        Reverification::Process.set_amazon_stat_settings(bounce_rate, amount_of_email)
        Reverification::Mailer.resend_soft_bounced_notifications
      end

      def send_email(bounce_rate, amount_of_email)
        Reverification::Process.set_amazon_stat_settings(bounce_rate, amount_of_email)
        Reverification::Mailer.send_notifications
      end
    end

    method_option :bounce_threshold, :aliases => '-br', :desc => 'Sets bounce rate', :required => true
    method_option :num_email, :aliases => '-e', :desc => 'Sets the amount of email', :required => true
    desc 'resend_to_soft_bounced_emails [BOUNCE_THRESHOLD] [NUM_EMAIL]', 'Resends to all accounts that soft bounced
          specifying when to check statistics through the amount of emails and for what acceptable bounce percentage'

    def resend_to_soft_bounced_emails(bounce_rate, amount_of_email)
      Reverification::Process.set_amazon_stat_settings(bounce_rate, amount_of_email)
      Reverification::Mailer.resend_soft_bounced_notifications
    end

    method_option :bounce_threshold, :aliases => '-br', :desc => 'Sets bounce rate', :required => true
    method_option :num_email, :aliases => '-e', :desc => 'Sets the amount of email', :required => true
    desc 'send_emails [BOUNCE_THRESHOLD] [NUM_EMAIL]', 'sends to accounts specifying when to check statistics
          through the amount of emails and for what acceptable bounce percentage'

    def send_emails(bounce_rate, amount_of_email)
      Reverification::Process.set_amazon_stat_settings(bounce_rate, amount_of_email)
      Reverification::Mailer.send_notifications
    end
  end

  class Poll < Thor
    desc 'all_queues', 'This task polls all AWS SQS queues'

    def all_queues
      invoke :success_queue
      invoke :bounce_queue
      invoke :complaints_queue
    end

    desc 'success_queue', 'This task polls the success queue'

    def success_queue
      Reverification::Process.poll_success_queue
    end

    desc 'complaints_queue', 'This task polls the complaints queue'

    def complaints_queue
      Reverification::Process.poll_complaints_queue
    end

    desc 'bounce_queue', 'This task polls the bounce queue'
    def bounce_queue
      Reverification::Process.poll_bounce_queue
    end
  end
end
