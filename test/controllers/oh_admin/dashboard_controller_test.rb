# frozen_string_literal: true

require 'test_helper'

class OhAdmin::DashboardControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }

  it 'should render dashboard for a logged admin user' do
    login_as admin
    get :index
    assert_response :ok
    assert_template :index
  end

  it 'should unauthorized for non admins' do
    get :index
    assert_response :unauthorized
  end
end
