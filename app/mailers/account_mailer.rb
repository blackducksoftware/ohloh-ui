class AccountMailer < ActionMailer::Base
  default from: 'mailer@openhub.net'

  def signup_notification(account)
    @account = account
    @url = activate_account_accesses_url(account_id: account.to_param, code: account.activation_code,
                                         host: ENV['URL_HOST'], protocol: 'https')
    mail to: account.email, subject: t('.subject'), bcc: 'peterdp@synopsys.com'
  end

  def activation(account)
    @url = root_url(host: ENV['URL_HOST'])
    @account = account
    mail to: account.email, subject: t('.subject')
  end

  def kudo_recipient(kudo)
    @kudo = kudo
    @my_account_url = account_url(id: 'me')
    @email_settings_url = edit_account_privacy_account_url(id: @kudo.account.to_param)
    @unsubscribe_emails_url = unsubscribe_emails_accounts_url(
      notification_type: 'kudo',
      key: Account::Subscription.new(@kudo.account).generate_unsubscription_key
    )

    mail to: @kudo.account.email, subject: t('.subject', from: @kudo.sender.name)
  end
end
