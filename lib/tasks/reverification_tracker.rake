namespace :reverification do
  desc 'This task begins the initial reverification process'
  task execute_reverification_process: :environment do
    Reverification::Mailer.run
  end

  desc 'This retries to send an email to accounts that have soft bounced'
  task retry_soft_bounced_responses: :environment do
    Reverification::Process.resend_soft_bounced_notifications
  end

  desc 'This task polls the success queue'
  task poll_success_queue: :environment do
    Reverification::Process.poll_success_queue
  end

  desc 'This task polls the complaints queue'
  task poll_complaints_queue: :environment do
    Reverification::Process.poll_complaints_queue
  end

  desc 'This task polls the bounce queue'
  task poll_bounce_queue: :environment do
    Reverification::Process.poll_bounce_queue
  end

  desc 'This task removes the reverificaton_tracker associaton when an account validates'
  task cleanup: :environment do
    ReverificationTracker.cleanup
  end
end
