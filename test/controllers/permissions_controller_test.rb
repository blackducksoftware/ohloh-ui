require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase
  fixtures :accounts, :projects

  # show action
  test 'unlogged users should see permissions alert' do
    login_as nil
    get :show, id: projects(:linux)
    assert_response :ok
  end
end
