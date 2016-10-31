require 'test_helper'

describe ProjectBadge do
  describe 'project_name' do
    it 'should create a project badge' do
      ProjectBadge.count.must_equal 0
      project = create(:project)
      repository = create(:repository)
      project.project_badges.create(repository: repository, identifier: '45')
      ProjectBadge.count.must_equal 1
    end
    it 'should not create a project badge if params is invalid' do
      ProjectBadge.count.must_equal 0
      project = create(:project)
      repository = create(:repository)
      badge = project.project_badges.create(repository: repository, identifier: '')
      ProjectBadge.count.must_equal 0
      badge.errors[:identifier].must_be :present?
    end
  end
end
