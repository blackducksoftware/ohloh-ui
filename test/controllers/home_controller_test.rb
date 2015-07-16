require 'test_helper'

describe 'HomeController' do
  it 'index should load' do
    Rails.cache.clear
    get :index
    must_respond_with :success
    assigns(:home).class.must_equal HomeDecorator
  end

  it 'server_info should load' do
    get :server_info
    must_respond_with :success
    resp = JSON.parse(response.body)
    resp['status'].must_equal 'OK'
  end
end
