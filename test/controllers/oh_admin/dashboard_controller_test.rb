# frozen_string_literal: true

require 'test_helper'

class OhAdmin::DashboardControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }

  it 'should render dashboard for any user' do
    get :index
    assert_response :ok
    assert_template :index
  end
end
