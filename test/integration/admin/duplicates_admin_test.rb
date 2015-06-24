require 'test_helper'

class DuplicatesAdminTest < ActionDispatch::IntegrationTest
  it 'index loads' do
    create(:duplicate)
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_duplicates_path
    assert_response :success
  end

  it 'show loads' do
    duplicate = create(:duplicate)
    admin = create(:admin, password: 'xyzzy123456')
    admin.password = 'xyzzy123456'
    login_as admin
    get admin_duplicate_path(duplicate)
    assert_response :success
  end
end
