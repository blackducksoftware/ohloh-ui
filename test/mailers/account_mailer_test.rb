require 'test_helper'

class AccountMailerTest < ActionMailer::TestCase
  it '#signup_notification' do
    user = create(:account, activated_at: nil)
    before = ActionMailer::Base.deliveries.count
    email = AccountMailer.signup_notification(user).deliver_now
    ActionMailer::Base.deliveries.count.must_equal before + 1
    email.to.must_equal [user.email]
    email[:from].value.must_equal 'mailer@openhub.net'
    email.subject.must_equal I18n.t('account_mailer.signup_notification.subject')
    email.body.encoded.must_match I18n.t('.account_mailer.signup_notification.body', login: user.login)
  end

  it '#activation' do

    # TODO: Ask PDP about where the activation email comes from. 
    # Does it come from the old architecture because its created in prd-oh-utility?
    # Or does the mail come from ohloh-ui
    # In short does it come from ohloh or ohloh-ui

    # Ask if any part of the production architecture still comes from ohloh.

    user = create(:account, activated_at: nil)
    user.update!(activated_at: Time.now, activation_code: Faker::Lorem.characters(20))
    activation_email = ActionMailer::Base.deliver_now
    # user should receive an email
    #check all the fields

  end

  it '#reset_password_link' do
  end

  it '#kudo_recipient' do
  end
end
