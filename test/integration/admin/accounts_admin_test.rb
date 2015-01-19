require 'test_helper'

class AccountsAdminTest < ActionDispatch::IntegrationTest
  it 'index loads' do
    create(:account)
    create(:admin)
    login_as create(:admin)
    get admin_accounts_path
    assert_response :success
  end

  it 'show loads' do
    account = create(:account)
    login_as create(:admin)
    get admin_account_path(account)
    assert_response :success
  end

  it 'edit loads' do
    account = create(:account)
    login_as create(:admin)
    get edit_admin_account_path(account)
    assert_response :success
  end
end
