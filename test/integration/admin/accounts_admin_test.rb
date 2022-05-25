# frozen_string_literal: true

require 'test_helper'
require 'test_helpers/admin_test_helper'

class AccountsAdminTest < ActionDispatch::IntegrationTest
  include AdminTestHelper

  it 'shows the index page' do
    create(:account)
    create(:admin)
    create(:disabled_account)
    create(:spammer)
    create_and_login_admin
    get admin_accounts_path
    assert_response :success
  end

  it 'contains the correct columns for the index page' do
    create(:account)
    create_and_login_admin
    get admin_accounts_path
    assert_select 'th', text: 'Id'
    assert_select 'th', text: 'Name'
    assert_select 'th', text: 'Login'
    assert_select 'th', text: 'Email'
    assert_select 'th', text: 'Level'
    assert_select 'th', text: 'Url'
    assert_select 'th', text: 'Last Seen At'
    assert_select 'th', text: 'Last Seen Ip'
  end

  it 'shows the correct default access' do
    create(:account)
    create_and_login_admin
    get admin_accounts_path
    assert_select 'td' do
      assert_select "span[class='status_tag default ok']"
      assert_select "span[class='status_tag admin warning']", count: 2 # ohloh_slave and the account we created
    end
  end

  it 'shows the correct disabled access' do
    create(:disabled_account)
    create_and_login_admin
    get admin_accounts_path
    assert_select 'td' do
      assert_select "span[class='status_tag disabled error']"
      assert_select "span[class='status_tag admin warning']", count: 2 # ohloh_slave and the account we created
      assert_select "span[class='status_tag default ok']", false
    end
  end

  it 'shows the correct spammer access' do
    create(:spammer)
    create_and_login_admin
    get admin_accounts_path
    assert_select 'td' do
      assert_select "span[class='status_tag spammer error']"
      assert_select "span[class='status_tag admin warning']", count: 2 # ohloh_slave and the account we created
      assert_select "span[class='status_tag default ok']", false
    end
  end

  it 'shows the show page' do
    account = create(:account)
    create_and_login_admin
    get admin_account_path(account)
    assert_response :success
  end

  it 'redirects to ' do
    # TODO this test is failing on routes path
    account = create(:account)
    create_and_login_admin
    get admin_account_path(account)
    byebug
    get maintenance_admin_account_path, headers: { 'HTTP_REFERER' => admin_account_path }
    assert_response :success
    _(flash[:notice]).must_equal 'Accounts successfully logged out'

  end

  it 'tests maintenance route' do
    account = create(:account)
    create_and_login_admin
    opts = {:controller => "admin/accounts", :action => "index"}
    assert_routing '/admin/accounts/', opts
  end

  it 'shows the edit page' do
    account = create(:account)
    create_and_login_admin
    get edit_admin_account_path(account)
    assert_response :success
  end

  it 'should update email address' do
    account = create(:account)
    create_and_login_admin
    put admin_account_path(account), params: { account: account.attributes.merge(email: 'test@hotmail.com') }
    _(account.reload.email).must_equal 'test@hotmail.com'
  end
end
