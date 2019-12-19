# frozen_string_literal: true

require 'test_helper'

class FeedbacksAdminTest < ActionDispatch::IntegrationTest
  it 'index loads' do
    create(:feedback)
    admin = create(:admin, password: TEST_PASSWORD)
    login_as admin
    get admin_feedbacks_path
    assert_response :success
  end
end
