require 'test_helper'

class CodeSetAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }

  it 'mark_as_failed should work' do
    job = create(:sloc_job, repository: create(:repository, best_code_set: create(:code_set)))
    admin.password = 'xyzzy123456'
    login_as admin

    get mark_as_failed_admin_job_path(job)

    assert_equal job.failure_group, nil
    assert_equal job.status, 2
    assert_equal SlaveLog.last.job, job
    assert_equal flash[:notice], "Job #{job.id} marked as failed."
  end

  it 'refetch should work' do
    job = create(:fetch_job, repository: create(:repository))
    admin.password = 'xyzzy123456'
    login_as admin
    post refetch_admin_job_path(job)

    new_job = FetchJob.last
    assert_redirected_to admin_job_path(new_job)
    assert_equal flash[:success], "FetchJob #{new_job.id} created."
  end

  it 'recoount should work' do
    job = create(:fetch_job, repository: create(:repository))
    admin.password = 'xyzzy123456'
    login_as admin
    get recount_admin_job_path(job)

    assert_redirected_to admin_job_path(job)
    assert_equal job.retry_count, 0
    assert_equal job.wait_until, nil
    assert_equal flash[:notice], "Job #{ job.id } retry attempts counter has been reset to 0."
  end
end
