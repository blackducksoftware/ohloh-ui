require 'test_helper'

class SlaveLogTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin
    create(:slave_log, job: create(:complete_job))
    get admin_slave_logs_path
    assert_response :success
  end

  it 'should render repository slave logs' do
    login_as admin
    repository = create(:repository)
    create(:slave_log, code_set_id: create(:code_set, repository: repository).id)
    get admin_repository_slave_logs_path(repository)
    assert_response :success
  end

  it 'should render job slave logs' do
    login_as admin
    job = create(:complete_job)
    create(:slave_log, job: job)
    get admin_job_slave_logs_path(job)
    assert_response :success
  end
end
