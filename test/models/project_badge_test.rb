require 'test_helper'

describe ProjectBadge do
  describe 'project_name' do
    it 'should create a project badge' do
      ProjectBadge.count.must_equal 0
      project = create(:project)
      repository = create(:repository)
      project.project_badges.create(repository: repository, url: '45')
      ProjectBadge.count.must_equal 1
    end
    it 'should create a project badge' do
      ProjectBadge.count.must_equal 0
      project = create(:project)
      repository = create(:repository)
      badge = project.project_badges.create(repository: repository, url: '')
      ProjectBadge.count.must_equal 0
      badge.errors[:url].must_be :present?
    end
  end
end
