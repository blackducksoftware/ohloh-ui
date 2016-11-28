require 'test_helper'

class CodeLocationTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:code_location) { create(:code_location) }

  describe 'create_enlistment_for_project' do
    it 'must create an enlistment' do
      r = code_location.create_enlistment_for_project(create(:account), project, 'stop ignoring me!')
      r.project_id.must_equal project.id
      r.code_location_id.must_equal code_location.id
      r.ignore.must_equal 'stop ignoring me!'
    end

    it 'must undelete old enlistment' do
      r1 = code_location.create_enlistment_for_project(create(:account), project)
      r1.destroy
      r1.reload
      r1.deleted.must_equal true
      r2 = code_location.create_enlistment_for_project(create(:account), project)
      r2.deleted.must_equal false
      r1.id.must_equal r2.id
    end
  end

  describe 'failed?' do
    it 'show be true when the most recent job has failed' do
      code_location = create(:code_location)
      clear_jobs
      create(:failed_job, code_location: code_location, current_step_at: 5.minutes.ago)
      code_location.failed?.must_equal true
    end

    it 'must be false when all jobs have completed' do
      create(:complete_job, code_location: code_location, current_step_at: 5.minutes.ago)
      code_location.failed?.must_equal false
    end

    it 'must be false when there is a scheduled job' do
      create(:complete_job, code_location: code_location)
      create(:fetch_job, code_location: code_location)
      code_location.failed?.must_equal false
    end
  end

  describe 'bypass_url_validation=' do
    it 'must set value to false for 0' do
      repository = CodeLocation.new(bypass_url_validation: '0')
      repository.bypass_url_validation.must_equal false
    end

    it 'must set value to false for nil' do
      repository = CodeLocation.new(bypass_url_validation: nil)
      repository.bypass_url_validation.must_equal false
    end

    it 'must set value to true for 1' do
      repository = CodeLocation.new(bypass_url_validation: '1')
      repository.bypass_url_validation.must_equal true
    end

    it 'must set value to true for any other value' do
      repository = CodeLocation.new(bypass_url_validation: 'any value')
      repository.bypass_url_validation.must_equal true
    end
  end

  describe 'validations' do
    let(:code_location) { build(:code_location, :validate) }

    describe 'url' do
      it 'must detect non responding server' do
        repository = code_location.repository
        code_location.stubs(:timeout_interval).returns(1)
        repository.source_scm.stubs(:validate_server_connection).with { sleep(2) }
        code_location.wont_be :valid?
        code_location.errors.messages[:base].compact.must_be_empty
        code_location.repository.errors.messages[:url].first.must_equal I18n.t('repositories.timeout')
      end
    end

    describe 'branch_name' do
      it 'wont allow longer than 80 chars' do
        branch_name = 'x' * 81

        code_location = build(:code_location, :validate, module_branch_name: branch_name)

        code_location.wont_be :valid?

        error_message = i18n_activerecord(:repository, :branch_name)[:too_long]
        code_location.errors.messages[:module_branch_name].first.must_equal error_message
      end

      it 'wont allow invalid branch_name format' do
        branch_name = '^some$'

        code_location = build(:code_location, :validate, module_branch_name: branch_name)

        code_location.wont_be :valid?
        code_location.errors.messages[:module_branch_name]
          .first.must_equal i18n_activerecord(:repository, :branch_name)[:invalid]
      end
    end
  end

  describe 'ensure_job' do
    it 'should not create a new job if one already exists' do
      code_location = create(:code_location)

      code_location.jobs.count.must_equal 1
      code_location.ensure_job
      code_location.jobs.count.must_equal 1
    end

    it 'should create a new fetch job if best code set is not present' do
      code_location = create(:code_location)
      clear_jobs

      code_location.jobs.count.must_equal 0
      code_location.ensure_job.class.must_equal FetchJob
      code_location.jobs.count.must_equal 1
    end

    it 'should create a new sloc job if best code set as_of < best sloc set as_of' do
      code_location = create(:code_location, :with_code_set_and_sloc_set)
      clear_jobs
      code_location.jobs.count.must_equal 0
      code_location.ensure_job.class.must_equal SlocJob
    end

    it 'should create a new import job if best code set does not have a best sloc set' do
      code_location = create(:code_location, :with_code_set)

      clear_jobs
      code_location.jobs.count.must_equal 0
      code_location.ensure_job.class.must_equal ImportJob
    end
  end

  describe 'schedule_fetch' do
    it 'should create complete job' do
      code_location = create(:code_location, :with_code_set)
      clear_jobs
      code_location.jobs.count.must_equal 0
      code_location.schedule_fetch
      code_location.jobs.count.must_equal 1
      code_location.jobs.first.class.must_equal CompleteJob
    end
  end

  private

  def clear_jobs
    Job.destroy_all
  end
end
