require 'test_helper'

describe 'CodeopenhubController' do
  it 'should return 200 for index' do
    get :index
    assert_response :success
  end
end
