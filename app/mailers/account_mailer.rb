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
    @my_account_url = account_url(host: ENV['URL_HOST'], id: 'me')
    @email_settings_url = edit_account_privacy_account_url(host: ENV['URL_HOST'], id: @kudo.account.to_param)
    mail to: @kudo.account.email, subject: t('.subject', from: @kudo.sender.name)
  end

  def reverification(account)
    @account = account
    @twitter_reverification_url = new_authentication_url
    @unsubscribe_url = edit_account_privacy_account_url(id: account.to_param, host: ENV['URL_HOST'])
    mail to: @account.email, from: 'info@openhub.net',
         subject: t('.subject'), template_name: 'reverification',
         bcc: 'pdegenportnoy@blackducksoftware.com'
  end

  def one_week_left(account)
    @account = account
    @twitter_reverification_url = new_authentication_url
    @unsubscribe_url = edit_account_privacy_account_url(id: account.to_param, host: ENV['URL_HOST'])
    mail to: @account.email, from: 'info@openhub.net',
         subject: t('.subject'), template_name: 'reverification',
         bcc: 'pdegenportnoy@blackducksoftware.com'
  end

  def one_day_left(account)
    @account = account
    @twitter_reverification_url = new_authentication_url
    @unsubscribe_url = edit_account_privacy_account_url(id: account.to_param, host: ENV['URL_HOST'])
    mail to: @account.email, from: 'info@openhub.net',
         subject: t('.subject'), template_name: 'reverification',
         bcc: 'pdegenportnoy@blackducksoftware.com'
  end

  def mark_as_spam(account)
    @account = account
    @unsubscribe_url = edit_account_privacy_account_url(id: account.to_param, host: ENV['URL_HOST'])
    mail to: @account.email, from: 'info@openhub.net',
         subject: t('.subject'), bcc: 'pdegenportnoy@blackducksoftware.com'
  end

  def one_month_left_before_deletion(account)
    @account = account
    @twitter_reverification_url = new_authentication_url
    @unsubscribe_url = edit_account_privacy_account_url(id: account.to_param, host: ENV['URL_HOST'])
    mail to: @account.email, from: 'info@openhub.net',
         subject: t('.subject'), template_name: 'reverification',
         bcc: 'pdegenportnoy@blackducksoftware.com'
  end

  def one_day_left_before_deletion(account)
    @account = account
    @twitter_reverification_url = new_authentication_url
    @unsubscribe_url = edit_account_privacy_account_url(id: account.to_param, host: ENV['URL_HOST'])
    mail to: @account.email, from: 'info@openhub.net',
         subject: t('.subject'), template_name: 'reverification',
         bcc: 'pdegenportnoy@blackducksoftware.com'
  end
end
