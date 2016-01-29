require_relative '../account_reverification'

namespace :reverification do
  desc 'This task begins the initial reverification process'
  task send_reverification_notice: :environment do
    AccountReverification.run
  end
end
