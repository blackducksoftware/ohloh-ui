class ReverificationTask < Thor

  desc 'complete process [BOUNCE_THRESHOLD] [NUM_EMAIL]', 'Executes the entire reverification process
        specifying when to check statistics through the amount of emails and for what acceptable bounce percentage'

  def complete_process(bounce_rate, amount_of_email)
    require File.expand_path('config/environment.rb')
    Reverification::Process.set_amazon_stat_settings(bounce_rate, amount_of_email)
    Reverification::Process.cleanup
    Reverification::Mailer.run
    Reverification::Process.start_polling_queues
  end
end