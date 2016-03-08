namespace :reverification do
  desc 'This task begins the initial reverification process'
  task execute_process: :environment do
    p '====== Starts cleaning up unverified accounts and unverified trackers'
    Reverification::Process.cleanup
    p '====== Starts sending notification emails of different phases'
    Reverification::Mailer.run
    p '====== Wait for a minute.......'
    sleep(1.minute)
    p '====== Starts polling delivery feedback notification queues'
    Reverification::Process.start_polling_queues
    p '====== Process completed ======'
  end

  namespace :cleanup do
    desc 'Removes the reverification trackers of verified accounts and removes unverified accounts'
    task all: [:verified, :unverified]

    desc 'Removes the reverification trackers of verified accounts'
    task verified: :environment do
      p '====== Remove verified accounts reverification tracker'
      ReverificationTracker.remove_reverification_trackers_for_verifed_accounts
    end

    desc 'Removes unverified accounts'
    task unverified: :environment do
      p '====== Remove unverified accounts'
      ReverificationTracker.delete_expired_accounts
    end
  end

  namespace :notifications do
    desc 'This resends soft bounced notifications and sends all phases notifications'
    task all: [:resend, :send]

    desc 'This sends notifiactions of all phases'
    task send: :environment do
      p '====== Sends notifications of all phases'
      Reverification::Mailer.send_notifications
    end

    desc 'This retries to send an email to accounts that have soft bounced'
    task resend: :environment do
      p '====== Resends soft bounced notifications'
      Reverification::Mailer.resend_soft_bounced_notifications
    end
  end

  namespace :poll do
    desc 'Polls AWS SQS success, bounce and complaints queues'
    task all_queues: [:success_queue, :bounce_queue, :complaints_queue]

    desc 'This task polls the success queue'
    task success_queue: :environment do
      p '====== Poll success queue'
      Reverification::Process.poll_success_queue
    end

    desc 'This task polls the complaints queue'
    task complaints_queue: :environment do
      p '====== Poll complaints queue'
      Reverification::Process.poll_complaints_queue
    end

    desc 'This task polls the bounce queue'
    task bounce_queue: :environment do
      p '====== Poll bounce queue'
      Reverification::Process.poll_bounce_queue
    end
  end
end
