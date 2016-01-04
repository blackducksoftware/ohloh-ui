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
    assert_response :success
  end

  it 'renders the dashboard when a job is newly running but current_step_at has not been updated' do
    job = create(:complete_job, status: Job::STATUS_RUNNING, current_step_at: nil)
    get admin_root_path
    assert_response :success
    assert_select "a[href='#{admin_job_path(job)}']" do |elements|
      assert_select 'span.under-five-minute', text: "C #{job.id}"
    end
  end

  it 'renders the Overviews' do
    get admin_root_path
    assert_select 'h3', text: 'Overview Statistics'
    assert_select 'h3', text: 'Job Overview'
  end

  it 'should list different time windows' do
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

  it 'shows the slaves' do
    Slave.delete_all
    slave = create(:slave)
    get admin_root_path
    assert_select "a[href='/admin/slaves/#{slave.id}']", text: slave.hostname
    assert_select 'span.allow', text: 'Allow'
    assert_select 'td.col-load_average', text: slave.load_average.to_s
  end 

  it 'shows the jobs' do
    Slave.delete_all
    slave = create(:slave)
    job = create(:complete_job, {slave: slave, status: Job::STATUS_RUNNING, current_step_at: Time.now() - 10.minutes})
    get admin_root_path
    assert_select "a[href='/admin/jobs/#{job.id}']", text:"C #{job.id}"
  end
end
