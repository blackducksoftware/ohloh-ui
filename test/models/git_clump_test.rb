require 'test_helper'

class GitClumpTest < ActiveSupport::TestCase
  describe 'branch_name' do
    it 'must return master when not git adapter' do
      svn_repository = create(:svn_repository)
      code_set = create(:code_set, repository: svn_repository)

      git_clump = GitClump.new(code_set: code_set)
      git_clump.branch_name.must_equal 'master'
    end

    it 'must return the branch_name from repository for GitAdapter' do
      branch_name = Faker::Name.first_name
      repository = create(:git_repository, branch_name: branch_name)
      code_set = create(:code_set, repository: repository)

      git_clump = GitClump.new(code_set: code_set)
      git_clump.branch_name.must_equal branch_name
    end
  end
end
