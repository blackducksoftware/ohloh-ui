require 'test_helper'

describe 'HomeController' do
  it 'index should load' do
    get :index
    must_respond_with :success
    assigns(:home).class.must_equal HomeDecorator
  end
end
