# frozen_string_literal: true

require 'test_helper'

class AccountsHelperTest < ActionView::TestCase
  include AccountsHelper

  let(:account) { create(:account) }
  let(:privacy_settings_link_text) { I18n.t('accounts.unsubscribe_emails.settings') }
  let(:privacy_policy_link_text) { I18n.t('accounts.unsubscribe_emails.privacy_policy') }

  describe '#privacy_settings_text' do
    it 'should return privacy settings link for existing account' do
      link = %(<a href="/accounts/#{account.to_param}/edit_privacy">#{privacy_settings_link_text}</a>)
      privacy_settings_text(account).must_equal "You may view your #{link} to review and modify your email preferences."
    end

    it 'should return new session link for non-existing account' do
      link = %(<a href="/sessions/new">#{privacy_settings_link_text}</a>)
      privacy_settings_text.must_equal "You may view your #{link} to review and modify your email preferences."
    end
  end

  describe '#privacy_policy_link' do
    it 'should return privacy policy link for existing account' do
      url = 'https://community.synopsys.com/s/article/Black-Duck-Open-Hub-Open-Hub-Privacy-Policy'
      link = %(<a target="_blank" rel="noopener" href="#{url}">#{privacy_policy_link_text}</a>)
      privacy_policy_link.must_equal link
    end
  end

  describe '#notification_type_text' do
    it 'should return kudo notification type text' do
      notification_type_text(:kudo).must_equal t('accounts.unsubscribe_emails.kudo_notification_type')
    end

    it 'should return post notification type text' do
      notification_type_text(:post).must_equal t('accounts.unsubscribe_emails.post_notification_type')
    end

    it 'should return default notification type text' do
      notification_type_text(nil).must_equal t('accounts.unsubscribe_emails.default_notification_type')
    end
  end
end
