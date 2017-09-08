require 'test_helper'

class CodeLocationAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin
    repository = create(:repository, url: 'git://github.com/rails/rails.git')
    create(:code_location, status: 0, repository: repository, update_interval: 3600)
    create(:code_location, status: 1, repository: repository)
    create(:code_location, status: 2, repository: repository)
    get admin_code_locations_path
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    get admin_code_location_path(create(:code_location))
    assert_response :success
  end

  it 'should refetch the code_location' do
    login_as admin
    assert_difference 'RepositoryDirectory.count' do
      get refetch_admin_code_location_path(create(:code_location))
    end
    assert_response :redirect
  end
end
