require 'test_helper'

class ReverificationTest < ActiveSupport::TestCase
  # Note: ohloh_slave is present in every test and is verified by Github.
  describe 'create_and_populate_reverification_fields' do
    it 'should grab every single account, create and then populate a reverification assoc.' do
      reverification_count = Reverification.count
      create(:account_with_no_verifications)
      Reverification.create_and_populate_reverification_fields
      Reverification.count.must_equal reverification_count + 2
      Reverification.last.verified.must_equal false
      Reverification.last.initial_email_sent_at.must_equal nil
      Reverification.last.notification_counter.must_equal 0
    end

    it 'should update the reverifications verified column if an account has already been verified' do
      reverification_count = Reverification.count
      create(:account_with_verifications)
      Reverification.create_and_populate_reverification_fields
      Reverification.count.must_equal reverification_count + 2
      Reverification.last.verified.must_equal true
      Reverification.last.initial_email_sent_at.must_equal nil
      Reverification.last.notification_counter.must_equal 0
    end
  end

  describe 'send_reverification_emails' do
    it 'should send emails to accounts that have not reverified at all' do
      reverification = create(:reverification)
      ActionMailer::Base.deliveries.clear
      Reverification.send_reverification_emails(0)
      ActionMailer::Base.deliveries.size.must_equal 1
      reverification.initial_email_sent_at.class.must_equal ActiveSupport::TimeWithZone
    end

    it 'should raise an exception if the email could not be delivered' do
      account = build(:account, email: 'notarealemail@somedomain.com', salt: Faker::Lorem.words(15))
      account.save(validate: false)
      ActionMailer::Base.deliveries.clear
      Reverification.stubs(:send_reverification_emails).with(0)
      AccountMailer.stubs(:reverification).with(account).raises(Net::SMTPError)
      ActionMailer::Base.deliveries.size.must_equal 0
      account.reverification.must_equal nil
    end
  end

  describe 'check_account_status' do
    it 'should send the correct reminder email one week prior to account disablement' do
      # Three weeks since initial email
      reverification = create(:reverification)
      initial_notification = reverification.initial_email_sent_at
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

    it 'should raise an exception if the one week leftemail could not be delivered' do
      reverification = create(:reverification)
      initial_notification = reverification.initial_email_sent_at
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(initial_notification + 20.days) do
        Reverification.stubs(:check_account_status)
        AccountMailer.stubs(:one_week_left).with(reverification.account).raises(Net::SMTPError)
        ActionMailer::Base.deliveries.size.must_equal 0
        reverification = Reverification.first
        reverification.reminder_sent_at.must_equal nil
        reverification.notification_counter.must_equal 0
      end
    end

    it 'should send the correct reminder email when one day remains before disablement' do
      reverification = create(:reverification,
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

    it 'should raise an exception if the one day left email could not be delivered' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc + 20.days,
                              notification_counter: 1)
      first_reminder_sent_at = reverification.reminder_sent_at
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(first_reminder_sent_at + 9.days) do
        Reverification.stubs(:check_account_status)
        AccountMailer.stubs(:one_day_left).with(reverification.account).raises(Net::SMTPError)
        ActionMailer::Base.deliveries.size.must_equal 0
        reverification = Reverification.first
        reverification.notification_counter.must_equal 1
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

    it 'should raise an exception if the mark as spam email could not be delivered' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc + 29.days,
                              notification_counter: 2)
      reminder_sent_at = reverification.reminder_sent_at
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(reminder_sent_at + 1.day) do
        Reverification.stubs(:check_account_status)
        AccountMailer.stubs(:mark_as_spam).with(reverification.account).raises(Net::SMTPError)
        ActionMailer::Base.deliveries.size.must_equal 0
        reverification = Reverification.first
        reverification.account.level.must_equal 0
        reverification.notification_counter.must_equal 2
      end
    end

    it 'should send the correct notification one month prior to account deletion' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc,
                              notification_counter: 3)
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(Time.now.utc + 60.days) do
        Reverification.check_account_status
        ActionMailer::Base.deliveries.size.must_equal 1
        translation = I18n.t('.account_mailer.one_month_left_before_deletion.subject')
        ActionMailer::Base.deliveries.first.subject.must_equal translation
        reverification = Reverification.first
        reverification.reminder_sent_at.class.must_equal ActiveSupport::TimeWithZone
        reverification.notification_counter.must_equal 4
      end
    end

    it 'should raise an exception if the one month before deletion email could not be delivered' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc,
                              notification_counter: 3)
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(Time.now.utc + 60.days) do
        Reverification.stubs(:check_account_status)
        AccountMailer.stubs(:one_month_left_before_deletion).with(reverification.account).raises(Net::SMTPError)
        ActionMailer::Base.deliveries.size.must_equal 0
        reverification = Reverification.first
        reverification.notification_counter.must_equal 3
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

    it 'should raise an exception if the one month before deletion email could not be delivered' do
      reverification = create(:reverification,
                              reminder_sent_at: Time.now.utc,
                              notification_counter: 4)
      ActionMailer::Base.deliveries.clear
      Timecop.freeze(Time.now.utc + 29.days) do
        Reverification.stubs(:check_account_status)
        AccountMailer.stubs(:one_day_left_before_deletion).with(reverification.account).raises(Net::SMTPError)
        ActionMailer::Base.deliveries.size.must_equal 0
        reverification = Reverification.first
        reverification.notification_counter.must_equal 4
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
