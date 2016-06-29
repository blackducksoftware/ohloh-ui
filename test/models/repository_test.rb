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

  describe 'code_locations' do
    it 'must assign prime_code_location correctly' do
      branch_name = Faker::Name.first_name
      repository = create(:repository, prime_code_location_attributes: { branch_name: branch_name })

      repository.code_locations.count.must_equal 1
      repository.code_locations.first.must_equal repository.prime_code_location
    end
  end

  describe 'create_enlistment_for_project' do
    let(:project) { create(:project) }
    let(:repository) { create(:repository) }

    it 'must create an enlistment' do
      r = repository.create_enlistment_for_project(create(:account), project, 'stop ignoring me!')
      r.project_id.must_equal project.id
      r.repository_id.must_equal repository.id
      r.ignore.must_equal 'stop ignoring me!'
    end

    it 'must undelete old enlistment' do
      r1 = repository.create_enlistment_for_project(create(:account), project)
      r1.destroy
      r1.reload
      r1.deleted.must_equal true
      r2 = repository.create_enlistment_for_project(create(:account), project)
      r2.deleted.must_equal false
      r1.id.must_equal r2.id
    end
  end

  describe 'failed?' do
    before do
      @repository = create(:repository)
      @repository.jobs.clear
      @job1 = create(:complete_job)
      @job2 = create(:complete_job)
    end

    it 'show be true when the most recent job has failed' do
      @job1.update(repository: @repository, current_step_at: 2.days.ago, status: Job::STATUS_COMPLETED)
      @job2.update(repository: @repository, current_step_at: 5.minutes.ago, status: Job::STATUS_FAILED)
      @repository.failed?.must_equal true
    end

    it 'must be false when all jobs have completed' do
      @job1.update(repository: @repository, current_step_at: 2.days.ago, status: Job::STATUS_COMPLETED)
      @job2.update(repository: @repository, current_step_at: 5.minutes.ago, status: Job::STATUS_COMPLETED)
      @repository.failed?.must_equal false
    end

    it 'must be false when there is a scheduled job' do
      @job1.update(repository: @repository, current_step_at: 2.days.ago, status: Job::STATUS_COMPLETED)
      @job2.update(repository: @repository, current_step_at: nil, status: Job::STATUS_SCHEDULED)
      @repository.failed?.must_equal false
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
    before { Repository.any_instance.stubs(:bypass_url_validation) }

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

      it 'must detect non responding server' do
        repository = build(:repository)

        repository.stubs(:timeout_interval).returns(1)
        repository.source_scm.stubs(:validate_server_connection).with { sleep(2) }

        repository.wont_be :valid?
        repository.errors.messages[:url].first.must_equal I18n.t('repositories.timeout')
      end
    end

    describe 'branch_name' do
      it 'wont allow longer than 80 chars' do
        branch_name = 'x' * 81

        repository = build(:repository, prime_code_location_attributes: { branch_name: branch_name })

        repository.wont_be :valid?

        error_message = i18n_activerecord(:code_location, :branch_name)[:too_long]
        repository.prime_code_location.errors.messages[:branch_name].first.must_equal error_message
      end

      it 'wont allow invalid branch_name format' do
        branch_name = '^some$'

        repository = build(:repository, prime_code_location_attributes: { branch_name: branch_name })

        repository.wont_be :valid?
        error_message = i18n_activerecord(:code_location, :branch_name)[:invalid]
        repository.prime_code_location.errors.messages[:branch_name].first.must_equal error_message
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
    it 'should create complete job' do
      code_set = create(:code_set)
      repository = create(:repository, best_code_set_id: code_set.id)
      code_set.jobs.update_all(status: Job::STATUS_COMPLETED, current_step_at: 1.day.ago)
      repository.schedule_fetch
    end
  end
end
