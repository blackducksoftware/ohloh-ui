class AccountMailer < ActionMailer::Base
  default from: 'mailer@openhub.net'

  def signup_notification(account)
    @account = account
    @url = activate_account_accesses_url(account_id: account.to_param, code: account.activation_code,
                                         host: URL_HOST, protocol: 'https')
    mail to: account.email, subject: t('.subject'), bcc: 'pdegenportnoy@blackducksoftware.com'
  end
end
