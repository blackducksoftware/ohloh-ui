require 'test_helper'

class RepositoryTest < ActionDispatch::IntegrationTest
  let(:admin) { create(:admin, password: 'xyzzy123456') }

  it 'should render index page' do
    admin.password = 'xyzzy123456'
    login_as admin
    create(:repository)
    get admin_repositories_path
    assert_response :success
  end

  it 'should render show page' do
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_repository_path(create(:repository))
    assert_response :success
  end

  it 'should refetch the repository' do
    admin.password = 'xyzzy123456'
    login_as admin
    post refetch_admin_repository_path(create(:repository))
    assert_response :redirect
  end
end
