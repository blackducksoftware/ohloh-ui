require 'test_helper'

class CodeLocationTest < ActiveSupport::TestCase
  let(:project) { create(:project) }
  let(:code_location) { code_location_stub_with_id }

  describe 'create_enlistment_for_project' do
    it 'must create an enlistment' do
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      r = code_location.create_enlistment_for_project(create(:account), project, 'stop ignoring me!')
      r.project_id.must_equal project.id
      r.code_location_id.must_equal code_location.id
      r.ignore.must_equal 'stop ignoring me!'
    end

    it 'must undelete old enlistment' do
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      r1 = code_location.create_enlistment_for_project(create(:account), project)
      WebMocker.delete_subscription(code_location.id, project.id)
      r1.destroy
      r1.reload
      r1.deleted.must_equal true
      WebMocker.create_subscription
      r2 = code_location.create_enlistment_for_project(create(:account), project)
      r2.deleted.must_equal false
      r1.id.must_equal r2.id
    end
  end

  describe 'failed?' do
    it 'show be true when the most recent job has failed' do
      clear_jobs
      create(:failed_job, code_location_id: code_location.id, current_step_at: 5.minutes.ago)
      code_location.failed?.must_equal true
    end

    it 'must be false when all jobs have completed' do
      create(:complete_job, code_location_id: code_location.id, current_step_at: 5.minutes.ago)
      code_location.failed?.must_equal false
    end

    it 'must be false when there is a scheduled job' do
      create(:complete_job, code_location_id: code_location.id)
      create(:fetch_job, code_location_id: code_location.id)
      code_location.failed?.must_equal false
    end
  end

  describe 'ensure_job' do
    it 'should not create a new job if one already exists' do
      code_location.jobs.count.must_equal 0
      code_location.ensure_job
      code_location.jobs.count.must_equal 1
      code_location.ensure_job
      code_location.jobs.count.must_equal 1
    end

    it 'should create a new fetch job if best code set is not present' do
      code_location.jobs.count.must_equal 0
      code_location.ensure_job.class.must_equal FetchJob
      code_location.jobs.count.must_equal 1
    end

    it 'should create a new sloc job if best code set as_of is greater than best sloc set as_of' do
      sloc_set = create(:sloc_set, as_of: 1)
      code_set = sloc_set.code_set
      code_set.update!(as_of: 99, best_sloc_set: sloc_set)
      code_location.best_code_set_id = code_set.id
      code_location.jobs.count.must_equal 0
      code_location.ensure_job.class.must_equal SlocJob
    end

    it 'should create a new import job if best code set does not have a best sloc set' do
      code_set = create(:code_set)
      code_location.best_code_set_id = code_set.id

      code_location.jobs.count.must_equal 0
      code_location.ensure_job.class.must_equal ImportJob
    end
  end

  describe 'schedule_fetch' do
    it 'should create complete job' do
      code_set = create(:code_set)
      code_location.best_code_set_id = code_set.id
      clear_jobs
      code_location.jobs.count.must_equal 0
      code_location.schedule_fetch
      code_location.jobs.count.must_equal 1
      code_location.jobs.first.class.must_equal CompleteJob
    end

    it 'should set the code_location.do_not_fetch to false' do
      Enlistment.any_instance.stubs(:ensure_forge_and_job)
      enlistment = create_enlistment_with_code_location
      WebMocker.get_code_location
      code_location = enlistment.code_location
      code_location.stubs(:best_code_set).returns(CodeSet.new)
      code_location.do_not_fetch = true
      clear_jobs
      code_location.jobs.count.must_equal 0
      VCR.use_cassette('code_location_update_do_not_fetch', erb: { id: code_location.id }) do
        code_location.schedule_fetch
      end
      code_location.do_not_fetch.must_equal false
    end

    it 'should schedule a complete job even if there is a failed TarballJob' do
      code_set = create(:code_set)
      code_location.best_code_set_id = code_set.id
      clear_jobs
      create(:failed_tarball_job, code_location_id: code_location.id, code_set: code_location.best_code_set)
      code_location.jobs.count.must_equal 1
      code_location.schedule_fetch
      code_location.jobs.count.must_equal 2
    end
  end

  private

  def clear_jobs
    Job.destroy_all
  end
end
