require 'test_helper'

describe AccountMailer do
  describe '#signup_notification' do
    it 'should send a notification when a user signs up' do
      user = create(:account, activated_at: nil)
      before = ActionMailer::Base.deliveries.count
      email = AccountMailer.signup_notification(user).deliver_now
      ActionMailer::Base.deliveries.count.must_equal before + 1
      email.to.must_equal [user.email]
      email[:from].value.must_equal 'mailer@openhub.net'
      email.subject.must_equal I18n.t('account_mailer.signup_notification.subject')
      email.body.encoded.must_match I18n.t('.account_mailer.signup_notification.body', login: user.login)
    end
  end

  describe 'reverification' do
    it 'should send a reverification email' do
      account = build(:account, salt: Faker::Lorem.words(15))
      account.save(validation: false)
      before = ActionMailer::Base.deliveries.count
      email = AccountMailer.reverification(account).deliver_now
      ActionMailer::Base.deliveries.count.must_equal before + 1
      email.to.must_equal [account.email]
      email.from.must_equal ['info@openhub.net']
      email.subject.must_equal I18n.t('.account_mailer.reverification.subject')
      email.bcc.must_equal ['pdegenportnoy@blackducksoftware.com']
      email.body.encoded.must_match I18n.t('account_mailer.reverification.signature')
      email.body.encoded.must_match I18n.t('account_mailer.reverification.openhub_team')
      email.body.encoded.must_match I18n.t('account_mailer.reverification.blackduck_address')
    end
  end

  describe 'reverification process' do
    before do
      ActionMailer::Base.deliveries.clear
      @reverification = create(:reverification)
      @account = @reverification.account
      @before = ActionMailer::Base.deliveries.count
    end

    it 'should send out a warning one week notification before disable' do
      email = AccountMailer.one_week_left(@account).deliver_now
      ActionMailer::Base.deliveries.count.must_equal @before + 1
      email.to.must_equal [@account.email]
      email.from.must_equal ['info@openhub.net']
      email.bcc.must_equal ['pdegenportnoy@blackducksoftware.com']
      email.subject.must_equal I18n.t('.account_mailer.one_week_left.subject')
      email.body.encoded.must_match I18n.t('account_mailer.one_week_left.signature')
      email.body.encoded.must_match I18n.t('account_mailer.one_week_left.openhub_team')
      email.body.encoded.must_match I18n.t('account_mailer.one_week_left.blackduck_address')
    end

    it 'should send out a notification the day prior to account disabling' do
      email = AccountMailer.one_day_left(@account).deliver_now
      ActionMailer::Base.deliveries.count.must_equal @before + 1
      email.to.must_equal [@account.email]
      email.from.must_equal ['info@openhub.net']
      email.bcc.must_equal ['pdegenportnoy@blackducksoftware.com']
      email.subject.must_equal I18n.t('.account_mailer.one_day_left.subject')
      email.body.encoded.must_match I18n.t('account_mailer.one_day_left.signature')
      email.body.encoded.must_match I18n.t('account_mailer.one_day_left.openhub_team')
      email.body.encoded.must_match I18n.t('account_mailer.one_day_left.blackduck_address')
    end
  end

  describe 'mark_as_spam' do
    it 'should send a notification stating that the user is now a spammer' do
      reverification = create(:reverification)
      account = reverification.account
      before = ActionMailer::Base.deliveries.count
      email = AccountMailer.mark_as_spam(account).deliver_now
      ActionMailer::Base.deliveries.count.must_equal before + 1
      email.to.must_equal [account.email]
      email.from.must_equal ['info@openhub.net']
      email.bcc.must_equal ['pdegenportnoy@blackducksoftware.com']
      email.subject.must_equal I18n.t('.account_mailer.mark_as_spam.subject')
      email.body.encoded.must_match I18n.t('account_mailer.mark_as_spam.body', account: account.login)
      email.body.encoded.must_match I18n.t('account_mailer.mark_as_spam.openhub_team')
      email.body.encoded.must_match I18n.t('account_mailer.mark_as_spam.blackduck_address')
    end
  end

  describe 'one_month_left_before_deletion' do
    it 'should send a notification one month before account deletion' do
      reverification = create(:reverification)
      account = reverification.account
      before = ActionMailer::Base.deliveries.count
      email = AccountMailer.one_month_left_before_deletion(account).deliver_now
      ActionMailer::Base.deliveries.count.must_equal before + 1
      email.to.must_equal [account.email]
      email.from.must_equal ['info@openhub.net']
      email.bcc.must_equal ['pdegenportnoy@blackducksoftware.com']
      email.subject.must_equal I18n.t('.account_mailer.one_month_left_before_deletion.subject')
      email.body.encoded.must_match I18n.t('account_mailer.one_month_left_before_deletion.openhub_team')
      email.body.encoded.must_match I18n.t('account_mailer.one_month_left_before_deletion.blackduck_address')
    end
  end

  describe 'one_day_left_before_deletion' do
    it 'should send a notification one day before deletion' do
      reverification = create(:reverification)
      account = reverification.account
      before = ActionMailer::Base.deliveries.count
      email = AccountMailer.one_day_left_before_deletion(account).deliver_now
      ActionMailer::Base.deliveries.count.must_equal before + 1
      email.to.must_equal [account.email]
      email.from.must_equal ['info@openhub.net']
      email.bcc.must_equal ['pdegenportnoy@blackducksoftware.com']
      email.subject.must_equal I18n.t('.account_mailer.one_day_left_before_deletion.subject')
      email.body.encoded.must_match I18n.t('account_mailer.one_day_left_before_deletion.openhub_team')
      email.body.encoded.must_match I18n.t('account_mailer.one_day_left_before_deletion.blackduck_address')
    end
  end
end
