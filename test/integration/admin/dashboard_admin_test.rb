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
    assert_response :redirect
  end

  it 'renders the dashboard when a job is newly running but current_step_at has not been updated' do
    job = create(:complete_job, status: Job::STATUS_RUNNING, current_step_at: nil)
    get admin_root_path
    assert_response :redirect
    assert_select "a[href='#{admin_job_path(job)}']", false # do
    assert_select 'span.under-five-minute', false # text: "C #{job.id}"
    # end
  end

  it 'renders the Overviews' do
    get admin_root_path

    assert_select 'h3', false  # text: 'Overview Statistics'
    assert_select 'h3', false  # text: 'Job Overview'
  end

  it 'should list different time windows' do
    get admin_root_path
    assert_select "div[class='panel_contents']", false do
      assert_select 'a', false  # text: 'Ten Minutes'
      assert_select 'a', false  # text: 'One Hour'
      assert_select 'a', false  # text: 'Two Hours'
      assert_select 'a', false  # text: 'Eight Hours'
      assert_select 'a', false  # text: 'One Day'
      assert_select 'a', false  # text: 'Two Days'
      assert_select 'a', false  # text: 'One Week'
      assert_select 'a', false  # text: 'One Month'
      assert_select 'a', false  # text: 'All'
    end
  end

  it 'shows the slaves' do
    Slave.delete_all
    slave = create(:slave)
    get admin_root_path
    assert_select "a[href='/admin/slaves/#{slave.id}']", false # text: slave.hostname
    assert_select 'span.allow', false # text: 'Allow'
    assert_select 'td.col-load_average', false # text: slave.load_average.to_s
  end

  it 'shows the jobs' do
    Slave.delete_all
    slave = create(:slave)
    job = create(:complete_job, slave: slave, status: Job::STATUS_RUNNING, current_step_at: Time.current - 10.minutes)
    get admin_root_path
    assert_select "a[href='/admin/jobs/#{job.id}']", false # text: "C #{job.id}"
  end
end
