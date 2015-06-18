require 'test_helper'

describe AccountMailer do
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
end
