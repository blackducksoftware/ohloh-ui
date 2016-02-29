namespace :reverification do
  desc 'This task begins the initial reverification process'
  task send_reverification_notice: :environment do
    Reverification::Process.run
  end

  desc 'This task polls the success queue'
  task poll_success_queue: :environment do
    Reverification::Mailer.poll_success_queue
  end

  desc 'This task polls the complaints queue'
  task poll_complaints_queue: :environment do
    Reverification::Mailer.poll_complaints_queue
  end

  desc 'This task polls the bounce queue'
  task poll_bounce_queue: :environment do
    Reverification::Mailer.poll_bounce_queue
  end

  desc 'This task removes the reverificaton_tracker associaton when an account validates'
  task cleanup: :environment do
    ReverificationTracker.cleanup
  end
end
