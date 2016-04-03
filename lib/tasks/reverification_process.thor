class ReverificationTask < Thor

  desc 'complete process [BOUNCE_RATE] [EMAIL]', 'Executes the entire reverification process
        specifying what bounce statistic to stop process after a certain amount
        of emails are sent'

  def complete_process(bounce_rate, amount_of_email)
    require File.expand_path('config/environment.rb')
    Reverification::Process.set_amazon_stat_settings(bounce_rate, amount_of_email)
    Reverification::Process.cleanup
    Reverification::Mailer.run
    Reverification::Process.start_polling_queues
  end
end