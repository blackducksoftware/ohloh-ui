require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  it 'index should load' do
    get :index
    must_respond_with :success
  end
end
