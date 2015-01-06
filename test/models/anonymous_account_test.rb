require 'test_helper'

class AnonymousAccountTest < ActiveSupport::TestCase
  describe 'create' do
    it 'must not deliver_signup_notification' do
      skip 'TODO: AccountNotifier'
      AccountNotifier.expects(:deliver_signup_notification).never
      AnonymousAccount.create!
    end

    it 'must not deliver_activation' do
      skip 'TODO: AccountNotifier'
      AccountNotifier.expects(:deliver_activation).never
      AnonymousAccount.create!
    end
  end
end
