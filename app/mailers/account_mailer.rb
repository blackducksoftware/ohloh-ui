class AccountMailer < ActionMailer::Base
  default from: 'mailer@openhub.net'

  def signup_notification(account)
    @account = account
    @url = activate_account_accesses_url(account_id: account.to_param, code: account.activation_code,
                                         host: ENV['URL_HOST'], protocol: 'https')
    mail to: account.email, subject: t('.subject'), bcc: 'pdegenportnoy@blackducksoftware.com'
  end

  def activation(account)
    @url = root_url(host: ENV['URL_HOST'])
    @account = account
    mail to: account.email, subject: t('.subject')
  end
end
