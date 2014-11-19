require 'test_helper'

class CoverageControllerTest < ActionController::TestCase
  test 'visit the index' do
    get :index
    assert_response :success
  end
end
