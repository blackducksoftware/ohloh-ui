require 'test_helper'

class AnonymousAccountTest < ActiveSupport::TestCase
  class Create < AnonymousAccountTest
    test 'must not deliver_signup_notification' do
      skip 'TODO: AccountNotifier'
      AccountNotifier.expects(:deliver_signup_notification).never
      AnonymousAccount.create!
    end

    test 'must not deliver_activation' do
      skip 'TODO: AccountNotifier'
      AccountNotifier.expects(:deliver_activation).never
      AnonymousAccount.create!
    end
  end
end
