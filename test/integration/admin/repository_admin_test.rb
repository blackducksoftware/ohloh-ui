require 'test_helper'

class RepositoryAdminTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: TEST_PASSWORD) }

  it 'should render index page' do
    login_as admin
    create(:repository)
    get admin_repositories_path
    assert_response :success
  end

  it 'should render show page' do
    login_as admin
    get admin_repository_path(create(:repository))
    assert_response :success
  end

  it 'should refetch the repository' do
    login_as admin
    get refetch_admin_repository_path(create(:repository))
    assert_response :redirect
  end
end
