# frozen_string_literal: true

module AccountsHelper
  def notification_type_text(notification_type)
    case notification_type
    when :kudo then t('accounts.unsubscribe_emails.kudo_notification_type')
    when :post then t('accounts.unsubscribe_emails.post_notification_type')
    else t('accounts.unsubscribe_emails.default_notification_type')
    end
  end

  def privacy_policy_link
    url = 'https://community.blackduck.com/s/article/Black-Duck-Open-Hub-Open-Hub-Privacy-Policy'
    link_to(t('accounts.unsubscribe_emails.privacy_policy'), url, target: '_blank', rel: 'noopener')
  end

  def privacy_settings_text(account = nil)
    t('accounts.unsubscribe_emails.privacy_html', privacy_settings_link: privacy_settings_link(account))
  end

  private

  def privacy_settings_link(account)
    url = account ? edit_account_privacy_account_path(account) : new_session_path
    link_to(t('accounts.unsubscribe_emails.settings'), url)
  end
end
