require 'test_helper'

class AccountsAdminTest < ActionDispatch::IntegrationTest
  it 'index loads' do
    create(:account)
    create(:admin)
    create(:disabled_account)
    create(:spammer)
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_accounts_path
    assert_response :success
  end

  it 'show loads' do
    account = create(:account)
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_account_path(account)
    assert_response :success
  end

  it 'edit loads' do
    account = create(:account)
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
    get edit_admin_account_path(account)
    assert_response :success
  end
end
