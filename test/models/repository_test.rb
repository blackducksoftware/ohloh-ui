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

  describe 'validations' do
    describe 'url' do
      it 'wont allow blank url' do
        repository = build(:repository, url: '')

        repository.wont_be :valid?
        repository.errors.messages[:url].first.must_equal i18n_activerecord(:repository, :url)[:blank]
      end
    end

    describe 'branch_name' do
      it 'wont allow longer than 80 chars' do
        branch_name = 'x' * 81

        repository = build(:repository, branch_name: branch_name)

        repository.wont_be :valid?

        error_message = i18n_activerecord(:repository, :branch_name)[:too_long]
        repository.errors.messages[:branch_name].first.must_equal error_message
      end

      it 'wont allow invalid branch_name format' do
        branch_name = '^some$'

        repository = build(:repository, branch_name: branch_name)

        repository.wont_be :valid?
        repository.errors.messages[:branch_name].first.must_equal i18n_activerecord(:repository, :branch_name)[:invalid]
      end
    end

    describe 'username' do
      it 'wont allow longer than 32 chars' do
        username = 'x' * 33

        repository = build(:repository, username: username)

        repository.wont_be :valid?
        repository.errors.messages[:username].first.must_equal i18n_activerecord(:repository, :username)[:too_long]
      end

      it 'wont allow invalid username format' do
        username = '-invalid-'

        repository = build(:repository, username: username)

        repository.wont_be :valid?
        repository.errors.messages[:username].first.must_equal i18n_activerecord(:repository, :username)[:invalid]
      end
    end

    describe 'password' do
      it 'wont allow longer than 32 chars' do
        password = 'x' * 33

        repository = build(:repository, password: password)

        repository.wont_be :valid?
        repository.errors.messages[:password].first.must_equal i18n_activerecord(:repository, :password)[:too_long]
      end

      it 'wont allow invalid password format' do
        password = '<invalid>'

        repository = build(:repository, password: password)

        repository.wont_be :valid?
        repository.errors.messages[:password].first.must_equal i18n_activerecord(:repository, :password)[:invalid]
      end
    end
  end
end
