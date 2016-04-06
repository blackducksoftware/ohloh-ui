namespace :reverification do
  # desc 'This task begins the initial reverification process'
  # task execute_process: :environment do
  #   Reverification::Process.cleanup
  #   Reverification::Mailer.run
  #   Reverification::Process.start_polling_queues
  # end

  desc 'This task does the preparation works for pilot'
  task pilot_preparation: :environment do
    ReverificationPilotAccount.copy_accounts
  end

  namespace :cleanup do
    desc 'Removes the reverification trackers of verified accounts and removes unverified accounts'
    task all: [:verified, :unverified, :orphan_trackers]

    desc 'Removes the reverification trackers of verified accounts'
    task verified: :environment do
      ReverificationTracker.remove_reverification_trackers_for_verified_accounts
    end

    desc 'Removes unverified accounts'
    task unverified: :environment do
      ReverificationTracker.delete_expired_accounts
    end

    desc 'Removes orphan reverification trackers'
    task orphan_trackers: :environment do
      ReverificationTracker.remove_orphans
    end
  end

  namespace :notifications do
    desc 'This resends soft bounced notifications and sends all phases notifications'
    task all: [:resend, :send]

    desc 'This sends notifications of all phases'
    task send: :environment do
      Reverification::Mailer.send_notifications
    end

    desc 'This retries to send an email to accounts that have soft bounced'
    task resend: :environment do
      Reverification::Mailer.resend_soft_bounced_notifications
    end
  end

  namespace :poll do
    desc 'Polls AWS SQS success, bounce and complaints queues'
    task all_queues: [:success_queue, :bounce_queue, :complaints_queue]

    desc 'This task polls the success queue'
    task success_queue: :environment do
      Reverification::Process.poll_success_queue
    end

    desc 'This task polls the complaints queue'
    task complaints_queue: :environment do
      Reverification::Process.poll_complaints_queue
    end

    desc 'This task polls the bounce queue'
    task bounce_queue: :environment do
      Reverification::Process.poll_bounce_queue
    end
  end
end
