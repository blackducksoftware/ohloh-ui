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

  describe 'bypass_url_validation=' do
    it 'must set value to false for 0' do
      repository = Repository.new(bypass_url_validation: '0')
      repository.bypass_url_validation.must_equal false
    end

    it 'must set value to false for nil' do
      repository = Repository.new(bypass_url_validation: nil)
      repository.bypass_url_validation.must_equal false
    end

    it 'must set value to true for 1' do
      repository = Repository.new(bypass_url_validation: '1')
      repository.bypass_url_validation.must_equal true
    end

    it 'must set value to true for any other value' do
      repository = Repository.new(bypass_url_validation: 'any value')
      repository.bypass_url_validation.must_equal true
    end
  end

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
    before { Repository.any_instance.stubs(:bypass_url_validation) }

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

    describe 'ensure_job' do
      it 'should not create a new job if one already exists' do
        repository = create(:repository)

        repository.jobs.count.must_equal 1
        repository.ensure_job
        repository.jobs.count.must_equal 1
      end

      it 'should create a new fetch job if best code set is not present' do
        repository = create(:repository)
        repository.jobs.delete_all

        repository.jobs.count.must_equal 0
        repository.ensure_job.class.must_equal FetchJob
      end

      it 'should create a new import job if best code set does not have a best sloc set' do
        repository = create(:repository, best_code_set: create(:code_set))

        repository.jobs.count.must_equal 0
        repository.ensure_job.class.must_equal ImportJob
      end

      it 'should create a new sloc job if best code set as_of < best sloc set as_of' do
        sloc_set = create(:sloc_set, as_of: 1)
        code_set = create(:code_set, as_of: 2, best_sloc_set: sloc_set)
        repository = create(:repository, best_code_set: code_set)

        repository.jobs.count.must_equal 0
        repository.ensure_job.class.must_equal SlocJob
      end
    end
  end

  describe 'schedule_fetch' do
    it 'must try creating a CompleteJob when best_code_set' do
      code_set = create(:code_set)
      repository = create(:repository, best_code_set: code_set)

      CompleteJob.expects(:try_create)
      repository.schedule_fetch
    end

    it 'must ensure a job when no best_code_set' do
      repository = create(:repository)

      repository.expects(:ensure_job)
      repository.schedule_fetch
    end
  end
end
