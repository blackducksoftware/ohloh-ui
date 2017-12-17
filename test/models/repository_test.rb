require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  describe 'name_in_english' do
    it 'should return value base on repository type' do
      repo1 = create(:git_repository)
      repo2 = create(:svn_repository)
      repo3 = create(:bzr_repository)
      repo4 = create(:hg_repository)
      repo5 = create(:svn_sync_repository)
      repo6 = create(:cvs_repository)

      repo1.name_in_english.must_equal 'Git'
      repo2.name_in_english.must_equal 'Subversion'
      repo3.name_in_english.must_equal 'Bazaar'
      repo4.name_in_english.must_equal 'Mercurial'
      repo5.name_in_english.must_equal 'Subversion (via SvnSync)'
      repo6.name_in_english.must_equal 'CVS'
    end
  end

  describe '#matching' do
    before do
      @forge = Forge.find_by(name: 'Github')
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
    before { Repository.any_instance.stubs(:bypass_url_validation).returns(true) }

    describe 'url' do
      it 'wont allow blank url' do
        repository = build(:repository, url: '')

        repository.wont_be :valid?
        repository.errors.messages[:url].first.must_equal i18n_activerecord(:repository, :url)[:blank]
      end

      it 'must create only a single error message for presence' do
        repository = build(:repository, url: '')

        repository.wont_be :valid?
        repository.errors.messages[:url].grep(/can't be blank/).count.must_equal 1
      end
    end

    describe 'username' do
      it 'wont allow longer than 32 chars' do
        username = 'x' * 33

        repository = build(:repository, username: username)
        code_location = build(:code_location, :validate, repository: repository)

        code_location.wont_be :valid?
        code_location.repository.errors.messages[:username]
          .first.must_equal i18n_activerecord(:repository, :username)[:too_long]
      end

      it 'wont allow invalid username format' do
        username = '-invalid-'

        repository = build(:repository, username: username)
        code_location = build(:code_location, :validate, repository: repository)

        code_location.wont_be :valid?
        code_location.repository.errors.messages[:username]
          .first.must_equal i18n_activerecord(:repository, :username)[:invalid]
      end
    end

    describe 'password' do
      it 'wont allow longer than 32 chars' do
        password = 'x' * 33

        repository = build(:repository, password: password)
        code_location = build(:code_location, :validate, repository: repository)

        code_location.wont_be :valid?
        code_location.repository.errors.messages[:password]
          .first.must_equal i18n_activerecord(:repository, :password)[:too_long]
      end

      it 'wont allow invalid password format' do
        password = '<invalid>'

        repository = build(:repository, password: password)
        code_location = build(:code_location, :validate, repository: repository)

        code_location.wont_be :valid?
        code_location.repository.errors.messages[:password]
          .first.must_equal i18n_activerecord(:repository, :password)[:invalid]
      end
    end
  end

  describe 'hooks' do
    describe 'url' do
      it 'must remove trailing backslash' do
        repository_attributes = build(:repository, url: 'test.example.com/').attributes
        repository = Repository.create!(repository_attributes)
        repository.url.must_equal repository_attributes['url'].chomp('/')
      end
    end
  end
end
