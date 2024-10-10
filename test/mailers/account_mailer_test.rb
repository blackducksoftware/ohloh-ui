# frozen_string_literal: true

require 'test_helper'

describe AccountMailer do
  let(:url_helpers) { Rails.application.routes.url_helpers }
  let(:account)     { create(:account, activated_at: Time.current) }

  it '#signup_notification' do
    user = create(:account, activated_at: nil)
    before = ActionMailer::Base.deliveries.count
    email = AccountMailer.signup_notification(user).deliver_now
    _(ActionMailer::Base.deliveries.count).must_equal before + 1
    _(email.to).must_equal [user.email]
    _(email[:from].value).must_equal 'mailer@openhub.net'
    _(email.subject).must_equal I18n.t('account_mailer.signup_notification.subject')
    _(email.body.encoded).must_match I18n.t('.account_mailer.signup_notification.body', login: user.login)
  end

  describe '#activation' do
    let(:mail) { AccountMailer.activation(account) }

    it 'should have the provided subject' do
      _(mail.subject).must_equal I18n.t('account_mailer.activation.subject')
    end

    it 'should have the from address' do
      _(mail.from).must_equal ['mailer@openhub.net']
    end

    it 'should have the receiver address' do
      _(mail.to).must_equal [account.email]
    end

    it 'should have the content' do
      _(mail.body.encoded).must_match I18n.t('.account_mailer.activation.dear', login: account.login)
      _(mail.body.encoded).must_match I18n.t('.account_mailer.activation.body1')
      _(mail.body.encoded).must_match url_helpers.forums_url(host: ENV['URL_HOST'])
      _(mail.body.encoded).must_match url_helpers.account_privacy_account_url(account, host: ENV['URL_HOST'])
      _(mail.body.encoded).must_match url_helpers.edit_account_url(account, host: ENV['URL_HOST'])
      _(mail.body.encoded).must_match url_helpers.new_account_position_url(account, host: ENV['URL_HOST'])
      _(mail.body.encoded).must_match url_helpers.root_url(host: ENV['URL_HOST'])
    end
  end

  describe 'notify_disabled_account_for_login_failure' do
    let(:mail) { AccountMailer.notify_disabled_account_for_login_failure(account) }

    it 'should notify disabled account' do
      _(mail.to).must_equal [account.email]
    end
  end

  describe '#reset_password' do
    let(:mail) { AccountMailer.reset_password(account.id) }

    it 'should have the from address' do
      _(mail.from).must_equal ['mailer@openhub.net']
    end

    it 'should have the receiver address' do
      _(mail.to).must_equal [account.email]
    end

    it 'should have the content' do
      _(mail.body.encoded).must_match url_helpers.root_url(host: ENV['URL_HOST'])
      _(mail.body.encoded).must_match url_helpers.new_password_url(host: ENV['URL_HOST'])
    end
  end
end
