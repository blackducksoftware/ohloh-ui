require 'test_helper'
require 'test_helpers/admin_test_helper'

class DashboardAdminTest < ActionDispatch::IntegrationTest
  include AdminTestHelper

  it 'renders the dashbord' do
    LoadAverage.create(current: 4.8)
    create_and_login_admin
    get admin_root_path
    assert_response :success
  end

  it 'renders the Overviews' do
    LoadAverage.create(current: 4.8)
    create_and_login_admin
    get admin_root_path
    assert_select 'h3', text: 'Overview Statistics'
    assert_select 'h3', text: 'Job Overview'
  end

  it 'should list different time windows' do
    LoadAverage.create(current: 4.8)
    create_and_login_admin
    get admin_root_path
    assert_select "div[class='panel_contents']" do
      assert_select 'a', text: 'Ten Minutes'
      assert_select 'a', text: 'One Hour'
      assert_select 'a', text: 'Two Hours'
      assert_select 'a', text: 'Eight Hours'
      assert_select 'a', text: 'One Day'
      assert_select 'a', text: 'Two Days'
      assert_select 'a', text: 'One Week'
      assert_select 'a', text: 'One Month'
      assert_select 'a', text: 'All'
    end
  end
end
