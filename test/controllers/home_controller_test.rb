require 'test_helper'

describe 'HomeController' do
  it 'index should load' do
    Rails.cache.clear
    best_vita = create(:best_vita)
    best_vita.account.update_attributes(best_vita_id: best_vita.id, created_at: Time.current - 4.days)
    vita_fact = best_vita.vita_fact
    vita_fact.update_attributes(last_checkin: Time.current)
    Rails.cache.stubs(:fetch).returns(Account.recently_active)

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
