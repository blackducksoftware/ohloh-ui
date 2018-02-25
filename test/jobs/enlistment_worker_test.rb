require 'test_helper'

class EnlistmentWorkerTest < ActiveSupport::TestCase
  it 'should create a enlistment for a project' do
    VCR.use_cassette('find_by_and_create_code_locations') do
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      project = create(:project)
      project.enlistments.count.must_equal 0
      account = create(:account)
      stub_github_user_repositories_call do
        EnlistmentWorker.new.perform('stan', account.id, project.id)
      end
      project.enlistments.where('code_location_id is not null').count.must_equal 4
    end
  end
end
