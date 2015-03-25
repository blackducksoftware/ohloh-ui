require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  describe '#matching' do
    before do
      @forge = forges(:github)
      @repo1 = create(:repository, forge_id: @forge.id, name_at_forge: 'github_1')
      @repo2 = create(:repository, forge_id: @forge.id, name_at_forge: 'github_2', owner_at_forge: 'github_owner')
    end

    it 'matches without owner_at_forge' do
      match = Forge::Match.new(@forge, nil, 'github_1')
      repos = Repository.matching(match).to_a
      repos.length.must_equal 1
      repos[0].id.must_equal @repo1.id
    end

    it 'matches with owner_at_forge' do
      match = Forge::Match.new(@forge, 'github_owner', 'github_2')
      repos = Repository.matching(match).to_a
      repos.length.must_equal 1
      repos[0].id.must_equal @repo2.id
    end
  end
end
