require 'test_helper'

class CodeSetAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }

  it 'mark_as_failed should work' do
    request.env['HTTP_REFERER'] = 'http://test.com/admin/jobs'
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
    assert_redirected_to admin_fetch_job_path(new_job)
    assert_equal flash[:success], "FetchJob #{new_job.id} created."
  end
end
