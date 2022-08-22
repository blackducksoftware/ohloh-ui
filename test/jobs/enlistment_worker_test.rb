# frozen_string_literal: true

require 'test_helper'

class EnlistmentWorkerTest < ActiveSupport::TestCase
  it 'should create a enlistment for a project' do
    VCR.use_cassette('find_by_and_create_code_locations', record: :new_episodes) do
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      project = create(:project)
      _(project.enlistments.count).must_equal 0
      account = create(:account)
      EnlistmentWorker.new.perform('stan', account.id, project.id)
      # 3 out of 5 repos in the captured response have `"fork": true`.
      _(project.enlistments.where.not(code_location_id: nil).count).must_equal 2
    end
  end
end
