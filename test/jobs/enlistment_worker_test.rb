require 'test_helper'
class EnlistmentWorkerTest < ActiveSupport::TestCase
  it 'should create a enlistment for a project' do
    CodeLocation.any_instance.stubs(:bypass_url_validation).returns(true)
    project = create(:project)
    project.enlistments.count.must_equal 0
    Repository.count.must_equal 0
    account = create(:account)
    stub_github_user_repositories_call do
      EnlistmentWorker.new.perform('stan', account.id, project.id)
    end
    project.enlistments.count.must_equal 4
    Repository.count.must_equal 4
  end
end
