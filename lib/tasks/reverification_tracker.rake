require_relative '../reverification_tracker'

namespace :reverification do
  desc 'This task begins the initial reverification process'
  task send_reverification_notice: :environment do
    ReverificationTracer.run
  end
end
