class StagingMailInterceptor
  def self.delivering_email(message)
    staging_email_recipients = %w( ramprasath.r@imaginea.com gopal.a@imaginea.com )

    Rails.logger.warn "Emails are sent to #{staging_email_recipients} email account from #{Rails.env} env"

    recipients_information =  "( TO: #{message.to} )"
    recipients_information << " ( CC: #{message.cc} )" if message.cc
    recipients_information << " ( BCC: #{message.bcc} )" if message.bcc

    message.to = staging_email_recipients
    message.cc = nil
    message.bcc = nil
    message.subject = "[Staging] #{message.subject} #{recipients_information}"
  end
end
