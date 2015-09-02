require 'test_helper'

class ReverificationTest < ActiveSupport::TestCase
  # TODO: Ask the team how to test mail failures. I can explore other gems
  # but maybe there happens to be an easier way to implement that test.
  # Ask how to test email failures.

  describe 'populate_reverification_fields' do
    it 'should grab an account with valid twitter_id and populate reverification tables' do
      # Because ohloh_slave is automatically generated, the count is incremented by 2
      reverification_count = Reverification.count
      create(:account, twitter_id: Faker::Lorem.words(6))
      Reverification.populate_reverification_fields
      Reverification.count.must_equal reverification_count + 2
      Reverification.first.twitter_reverified.must_equal true
      Reverification.first.twitter_reverification_sent_at.class.must_equal ActiveSupport::TimeWithZone
      Reverification.first.notification_counter.must_equal 0
      Reverification.last.twitter_reverified.must_equal true
      Reverification.last.twitter_reverification_sent_at.class.must_equal ActiveSupport::TimeWithZone
      Reverification.last.notification_counter.must_equal 0
    end

    it 'should not grab an account without a twitter_id and populate the reverification tables' do
      # Because ohloh_slave is automatically generated with a twitter_id, the increment fails.
      account = build(:account, salt: Faker::Lorem.words(15), twitter_id: nil)
      account.save(validate: false)
      reverification_count = Reverification.count
      Reverification.populate_reverification_fields
      Reverification.count.must_equal reverification_count + 1
      Reverification.count.must_equal 1
    end
  end

  describe 'send_reverification_emails' do
    it 'should send emails to accounts that have not verified with twitter' do
      account = build(:account, salt: Faker::Lorem.words(15), twitter_id: nil)
      account.save(validate: false)
      ActionMailer::Base.deliveries.clear
      Reverification.send_reverification_emails(0)
      ActionMailer::Base.deliveries.size.must_equal 1
      account.reverification.twitter_reverification_sent_at.class.must_equal ActiveSupport::TimeWithZone
    end

    # TODO: Ask the team how to test this.
    # it 'should raise an exception if the email could not be delivered' do
    #   account = build(:account, email: 'notarealemail@somedomain.com', salt: Faker::Lorem.words(15), twitter_id: nil)
    #   account.save(validate: false)
    #   ActionMailer::Base.deliveries.clear
    #   Reverification.send_reverification_emails(0)
    #   ActionMailer::Base.deliveries.size.must_equal 0
    #   FAILED_EMAILS.size.must_equal 1
    #   account.reverification.twitter_reverification_sent_at.class.must_not_equal ActiveSupport::TimeWithZone
    #   account.reverification.notification_counter.must_equal 0
    # end
  end

  describe 'check_account_status' do
    it 'should send the correct reminder email one week prior to account disablement' do
      # Three weeks since initial email
      reverification = create(:reverification)
      initial_notification = reverification.twitter_reverification_sent_at
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(initial_notification + 20.days) do
        Reverification.check_account_status
        ActionMailer::Base.deliveries.size.must_equal 1
        ActionMailer::Base.deliveries.first.subject.must_equal I18n.t('.account_mailer.one_week_left.subject')
        reverification = Reverification.first
        reverification.reminder_sent_at.class.must_equal ActiveSupport::TimeWithZone
        reverification.notification_counter.must_equal 1
      end
    end

    it 'should send the correct reminder email when one day remains before disablement' do
      reverification = create(:reverification,
                              twitter_reverification_sent_at: Time.now.utc,
                              reminder_sent_at: Time.now.utc + 20.days,
                              notification_counter: 1)
      first_reminder_sent_at = reverification.reminder_sent_at
      ActionMailer::Base.deliveries.clear
      # Time is set to the day before the account is marked as spam.
      Timecop.freeze(first_reminder_sent_at + 9.days) do
        Reverification.check_account_status
        ActionMailer::Base.deliveries.size.must_equal 1
        ActionMailer::Base.deliveries.first.subject.must_equal I18n.t('.account_mailer.one_day_left.subject')
        # We had reverification.reload here in order for the test to work.
        reverification = Reverification.first
        reverification.reminder_sent_at.class.must_equal ActiveSupport::TimeWithZone
        reverification.notification_counter.must_equal 2
      end
    end

    it 'should flag an account as spam once the time limit criteria has been met' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc + 29.days,
                              notification_counter: 2)
      reminder_sent_at = reverification.reminder_sent_at
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(reminder_sent_at + 1.day) do
        Reverification.check_account_status
        ActionMailer::Base.deliveries.size.must_equal 1
        ActionMailer::Base.deliveries.first.subject.must_equal I18n.t('.account_mailer.mark_as_spam.subject')
        reverification = Reverification.first
        reverification.reminder_sent_at.class.must_equal ActiveSupport::TimeWithZone
        reverification.notification_counter.must_equal 3
      end
    end

    it 'should send the correct notification one month prior to account deletion' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc,
                              notification_counter: 3)
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(Time.now.utc.to_datetime + 60) do
        Reverification.check_account_status
        ActionMailer::Base.deliveries.size.must_equal 1
        translation = I18n.t('.account_mailer.one_month_left_before_deletion.subject')
        ActionMailer::Base.deliveries.first.subject.must_equal translation
        reverification = Reverification.first
        reverification.reminder_sent_at.class.must_equal ActiveSupport::TimeWithZone
        reverification.notification_counter.must_equal 4
      end
    end

    it 'should send the correct notification one day prior to account deletion' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc,
                              notification_counter: 4)
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(Time.now.utc + 29.days) do
        Reverification.check_account_status
        ActionMailer::Base.deliveries.size.must_equal 1
        translation = I18n.t('.account_mailer.one_day_left_before_deletion.subject')
        ActionMailer::Base.deliveries.first.subject.must_equal translation
        reverification = Reverification.first
        reverification.reminder_sent_at.class.must_equal ActiveSupport::TimeWithZone
        reverification.notification_counter.must_equal 5
      end
    end

    it 'should completely delete an account from Open Hub once enough time passes' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc,
                              notification_counter: 5)
      Reverification.check_account_status
      reverification.class.count.must_equal 0
      # ignore ohloh_slave, which is the first account
      Account.last.login.must_equal 'anonymous_coward'
      DeletedAccount.count.must_equal 1
    end
  end
end
