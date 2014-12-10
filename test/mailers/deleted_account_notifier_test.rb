require 'test_helper'

class DeletedAccountNotifierTest < ActiveSupport::TestCase
  test 'email should be sent out when account is deleted' do
    assert_difference -> { ActionMailer::Base.deliveries.count } do
      create(:deleted_account, created_at: 4.days.ago)
    end
  end
end
