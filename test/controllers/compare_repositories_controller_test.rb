require 'test_helper'

class CompareRepositoriesControllerTest < ActionController::TestCase
  test 'should render with no projects passed in' do
    CodeLocation.stubs(:scm_type_count).returns([{ type: 'svn', count: 3 }, { type: 'svn_sync', count: 2 }])
    get :chart
    assert_response :success
  end
end
