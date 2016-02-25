require_relative '../reverification_tracker'

namespace :reverification do
  desc 'This task begins the initial reverification process'
  task send_reverification_notice: :environment do
    ReverificationTracker.run
  end

  desc 'This task polls the success queue'
  task poll_success_queue: :environment do
    ReverificationTracker.poll_success_queue
  end

  desc 'This task polls the bounce queue'
  task poll_bounce_queue: :environment do
    ReverificationTracker.poll_bounce_queue
  end

  desc 'This task removes the reverificaton_tracker associaton when an account validates'
  task remove_reverification_trackers_for_validated_accounts: :environment do
    ReverificationTracker.remove_reverification_trackers_for_validated_accounts
  end
end
