require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  fixtures :accounts

  test 'sent_kudos' do
    Kudo.delete_all
    admin_account = accounts(:admin)
    create(:kudo, sender: admin_account, account: accounts(:user))
    create(:kudo, sender: admin_account, account: accounts(:joe))

    assert_equal 2, admin_account.sent_kudos.count
  end
end
