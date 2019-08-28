# frozen_string_literal: true

require 'test_helper'

class DeletedAccountNotifierTest < ActiveSupport::TestCase
  it 'email should be sent out when account is deleted' do
    project_id = create(:project).id
    assert_difference -> { ActionMailer::Base.deliveries.count } do
      create(:deleted_account, created_at: 4.days.ago, claimed_project_ids: [project_id])
    end
  end
end
