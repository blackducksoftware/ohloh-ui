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

  def reset_password_link(account, token)
    @url = confirm_password_reset_index_url(host: ENV['URL_HOST'], account_id: account.to_param, token: token)
    @account = account
    mail to: account.email, subject: t('.subject'), bcc: 'pdegenportnoy@blackducksoftware.com'
  end

  def kudo_recipient(kudo)
    @kudo = kudo
    @my_account_url = me_accounts_url(host: ENV['URL_HOST'])
    @email_settings_url = edit_account_privacy_account_url(host: ENV['URL_HOST'], id: @kudo.account.to_param)
    mail to: @kudo.account.email, subject: t('.subject', from: @kudo.sender.name)
  end
end
