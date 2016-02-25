require_relative '../reverification_tracker'

namespace :reverification do
  desc 'This task begins the initial reverification process'
  task send_reverification_notice: :environment do
    ReverificationTracker.run
  end

  desc 'This task begins the initial reverification process'
  task remove_reverification_trackers_for_validated_accounts: :environment do
    ReverificationTracker.remove_reverification_trackers_for_validated_accounts
  end
end
