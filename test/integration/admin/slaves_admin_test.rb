require 'test_helper'
require 'test_helpers/admin_test_helper'

class SlavesAdminTest < ActionDispatch::IntegrationTest
  include AdminTestHelper
  include ActionView::Helpers::DateHelper

  before do
    @slave = create(:slave)
    create_and_login_admin
  end

  it 'renders the slave page' do
    get admin_slaves_path
    assert_response :success
  end

  it 'shows the correct columns in the index page' do
    get admin_slaves_path
    assert_select 'tr' do
      assert_select 'th', text: 'Id'
      assert_select 'th', text: 'Hostname'
      assert_select 'th', text: 'Load Average'
      assert_select 'th', text: 'Allow Deny'
      assert_select 'th', text: 'Used Percent'
      assert_select 'th', text: 'Clump Status'
      assert_select 'th', text: 'Clump Age'
      assert_select 'th', text: 'Blocked Types'
    end
  end

  it 'shows the Allow status of the slave' do
    get admin_slaves_path
    assert_select "span[class='status_tag allow ok']", text: 'Allow'
  end

  it 'shows the Deny status of the slave' do
    @slave.update_attribute(:allow_deny, 'deny')
    get admin_slaves_path
    assert_select "span[class='status_tag deny error']", text: 'Deny'
  end

  it 'shows the timestamp of the oldest clump' do
    clump_timestamp = Time.now - 3.weeks
    @slave.update_attribute(:oldest_clump_timestamp, clump_timestamp)
    get admin_slaves_path
    assert_select "td[class='col col-clump_age']", text: time_ago_in_words(clump_timestamp)
  end

  it 'renders the slave show page' do
    get admin_slafe_path(@slave)
    assert_response :success
  end

  it 'renders the slave edit page' do
    get edit_admin_slafe_path(@slave)
    assert_response :success
  end

  it 'should do deny batch action' do
    post batch_action_admin_slaves_path(batch_action: 'deny', collection_selection: [@slave.id])
    assert_response :redirect
    must_redirect_to admin_slaves_path
    @slave.allow_deny == 'deny'
  end

  it 'should do allow batch action' do
    post batch_action_admin_slaves_path(batch_action: 'allow', collection_selection: [@slave.id])
    assert_response :redirect
    must_redirect_to admin_slaves_path
    @slave.allow_deny == 'allow'
  end
end
