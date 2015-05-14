require 'test_helper'

class CompareRepositoriesControllerTest < ActionController::TestCase
  test 'should render with no projects passed in' do
    get :chart
    assert_response :success
  end
end
