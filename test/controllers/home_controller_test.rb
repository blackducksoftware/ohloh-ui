# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  it 'index should load' do
    Rails.cache.clear
    best_account_analysis = create(:best_account_analysis)
    best_account_analysis.account.update(best_vita_id: best_account_analysis.id, created_at: 4.days.ago)
    account_analysis_fact = best_account_analysis.account_analysis_fact
    account_analysis_fact.update(last_checkin: Time.current)
    Rails.cache.stubs(:fetch).returns(Account.recently_active)

    get :index
    assert_response :success
    _(assigns(:home).class).must_equal HomeDecorator
  end

  it 'server_info should load' do
    get :server_info
    assert_response :success
    resp = JSON.parse(response.body)
    _(resp['status']).must_equal 'OK'
  end
end
