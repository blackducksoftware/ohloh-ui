require 'test_helper'

class CodeSetAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'index loads' do
    create(:clump)
    login_as admin
    get admin_code_sets_path
    assert_response :success
  end

  it 'loads show' do
    code_set = create(:code_set)
    login_as admin
    get admin_code_set_path(code_set)
    assert_response :success
  end

  it 'fetch works' do
    CodeSet.any_instance.stubs(:code_location).returns(code_location_stub)
    code_set = create(:code_set)
    login_as admin

    get fetch_admin_code_set_path(code_set)
    job = FetchJob.last
    assert_equal job.code_set, code_set
    assert_redirected_to admin_job_path(job)
    assert_equal flash[:success], "FetchJob #{job.id} created."
  end

  it 're-import works' do
    CodeSet.any_instance.stubs(:code_location).returns(code_location_stub)
    clump = create(:clump)
    code_set = clump.code_set
    login_as admin
    get reimport_admin_code_set_path(code_set)
    job = ImportJob.last
    assert_equal flash[:success], "CodeSet #{job.code_set_id} and ImportJob #{job.id} created."
    assert_redirected_to admin_job_path(job)
  end

  it 'resloc works' do
    CodeSet.any_instance.stubs(:code_location).returns(code_location_stub)
    code_set = create(:code_set)
    login_as admin
    get resloc_admin_code_set_path(code_set)
    job = SlocJob.last
    assert_equal job.code_set, code_set
    assert_redirected_to admin_job_path(job)
    assert_equal flash[:success], "SlocJob #{job.id} created."
  end
end
