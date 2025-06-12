# frozen_string_literal: true

require 'thor/group'
require File.expand_path('config/environment.rb')

module ReverificationTask
  class Reverify < Thor
    desc 'execute [BOUNCE_THRESHOLD] [NUM_EMAIL]', 'Executes the entire reverification process
          specifying when to check statistics through the amount of emails and for what acceptable bounce percentage'
    option :bounce_threshold, aliases: '-bt', desc: 'Sets bounce rate', required: true, type: :numeric
    option :num_email, aliases: '-e', desc: 'Sets the amount of email', required: true, type: :numeric
    def execute
      Reverification::Mailer.set_amazon_stat_settings(options[:bounce_threshold], options[:num_email])
      ReverificationTracker.cleanup
      Reverification::Mailer.run
      Reverification::Process.start_polling_queues
    end
  end

  class Cleanup < Thor
    desc 'clean_all', 'Invokes all three cleanup tasks'
    def clean_all
      ReverificationTracker.remove_reverification_trackers_for_verified_accounts
      ReverificationTracker.delete_expired_accounts
      ReverificationTracker.disable_accounts
      ReverificationTracker.remove_orphans
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

    desc 'disable_accounts', 'Disables all accounts with phase disable (2)'
    delegate :disable_accounts, to: :ReverificationTracker
  end

  class Notifications < Thor
    option :bounce_threshold, aliases: '-bt', desc: 'Sets bounce rate', required: true, type: :numeric
    option :num_email, aliases: '-e', desc: 'Sets the amount of email', required: true, type: :numeric
    desc 'resend_to_soft_bounced_emails [BOUNCE_THRESHOLD] [NUM_EMAIL]', 'Resends to all accounts that soft bounced
          specifying when to check statistics through the amount of emails and for what acceptable bounce percentage'

    def resend_to_soft_bounced_emails
      Reverification::Mailer.set_amazon_stat_settings(options[:bounce_threshold], options[:num_email])
      Reverification::Mailer.resend_soft_bounced_notifications
    end

    option :bounce_threshold, aliases: '-bt', desc: 'Sets bounce rate', required: true, type: :numeric
    option :num_email, aliases: '-e', desc: 'Sets the amount of email', required: true, type: :numeric
    desc 'send_emails [BOUNCE_THRESHOLD] [NUM_EMAIL]', 'sends to accounts specifying when to check statistics
          through the amount of emails and for what acceptable bounce percentage'

    def send_emails
      Reverification::Mailer.set_amazon_stat_settings(options[:bounce_threshold], options[:num_email])
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
