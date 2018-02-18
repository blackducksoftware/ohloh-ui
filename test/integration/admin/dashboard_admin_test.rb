require 'test_helper'
require 'test_helpers/admin_test_helper'

class DashboardAdminTest < ActionDispatch::IntegrationTest
  include AdminTestHelper

  before do
    LoadAverage.create(current: 4.8)
    create_and_login_admin
  end

  it 'renders the dashbord' do
    create(:fetch_job, status: Job::STATUS_RUNNING, current_step_at: Time.current)
    get admin_root_path
    assert_response :ok
  end

  it 'renders the dashboard when a job is newly running but current_step_at has not been updated' do
    create(:complete_job, status: Job::STATUS_RUNNING, current_step_at: nil)
    get admin_root_path
    assert_response :ok
  end

  it 'renders the Overviews' do
    get admin_root_path
    assert_select 'h1', text: 'Project Stats Overview'
    assert_select 'h1', text: 'Accounts Overview'
    assert_select 'h1', text: 'Last Activities'
  end
end
