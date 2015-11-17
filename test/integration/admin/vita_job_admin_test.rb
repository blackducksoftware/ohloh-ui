require 'test_helper'

class VitaJobTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }

  it 'should render index page' do
    admin.password = 'xyzzy123456'
    login_as admin
    create(:vita_job)
    get admin_vita_jobs_path
    assert_response :success
  end
end
