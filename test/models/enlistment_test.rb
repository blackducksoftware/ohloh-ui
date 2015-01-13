require 'test_helper'

class EnlistmentTest < ActiveSupport::TestCase
  it '#add_project_to_repository creates an enlistment' do
    proj = create(:project)
    repository = create(:repository)
    r = Enlistment.add_project_to_repository(create(:account), proj, repository, 'stop ignoring me!')
    r.project_id.must_equal proj.id
    r.repository_id.must_equal repository.id
    r.ignore.must_equal 'stop ignoring me!'
  end

  it '#add_project_to_repository undeletes old enlistment' do
    proj = create(:project)
    repository = create(:repository)
    r1 = Enlistment.add_project_to_repository(create(:account), proj, repository)
    r1.destroy
    r1.reload
    r1.deleted.must_equal true
    r2 = Enlistment.add_project_to_repository(create(:account), proj, repository)
    r2.deleted.must_equal false
    r1.id.must_equal r2.id
  end
end
