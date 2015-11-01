require 'test_helper'
require 'test_helpers/admin_test_helper'

class SlavesAdminTest < ActionDispatch::IntegrationTest
  include AdminTestHelper

  it 'renders the slave page' do
    create_and_login_admin
    get admin_slaves_path
    assert_response :success
  end

  it 'shows the correct columns in the index page' do
    slave = Slave.create(hostname: "Crawler 1")
    create_and_login_admin
    get admin_slaves_path
    assert_select 'tr' do 
      assert_select 'th', text: "Id"
      assert_select 'th', text: "Hostname"
      assert_select 'th', text: "Load Average"
      assert_select 'th', text: "Allow Deny"
      assert_select 'th', text: "Used Percent"
      assert_select 'th', text: "Clump Status"
      assert_select 'th', text: "Clump Age"
      assert_select 'th', text: "Blocked Types"
    end
  end

  it 'shows the Allow status of the slave' do
    slave = Slave.create(hostname: "Crawler 1", allow_deny: "allow")
    create_and_login_admin
    get admin_slaves_path
    assert_select "span[class='status_tag allow ok']", text: 'Allow'
  end

  it 'shows the Deny status of the slave' do
    slave = Slave.create(hostname: "Crawler 1", allow_deny: "deny")
    create_and_login_admin
    get admin_slaves_path
    assert_select "span[class='status_tag deny error']", text: 'Deny'
  end

end

