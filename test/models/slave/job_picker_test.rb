require 'test_helper'

class Slave::JobPickerTest < ActiveSupport::TestCase
  let(:slave) { Slave.where(hostname: Socket.gethostname).first_or_create }
  let(:job_picker) { Slave::JobPicker.new }
  let(:code_set) { create(:code_set) }

  before do
    slave.update!(allow_deny: :allow)
    Job::BlockedType.any_instance.stubs(:allowed).returns(Job.subclasses)
  end

  describe 'execute' do
    it 'must return and create a slave log when no jobs are allowed' do
      Job::BlockedType.any_instance.stubs(:allowed).returns([])

      job_picker.execute
      slave.logs.find_by(message: I18n.t('slaves.jobs_blocked')).must_be :present?
    end

    describe 'scheduled_job' do
      before do
        Job.destroy_all
      end

      it 'must fetch the job which was created first' do
        job = create(:vita_job, account: create(:account))
        create(:fetch_job, code_set: code_set)

        job_picker.execute.must_equal job
      end

      it 'must fetch the job that has higher priority' do
        create(:vita_job, account: create(:account))
        job = create(:fetch_job, code_set: code_set, priority: 1)

        job_picker.execute.must_equal job
      end

      it 'must avoid jobs that are not in allowed types' do
        Job::BlockedType.any_instance.stubs(:allowed).returns(Job.subclasses - [VitaJob, CompleteJob])

        create(:vita_job, account: create(:account))
        job = create(:fetch_job, code_set: code_set)

        job_picker.execute.must_equal job
      end

      it 'must pick up a job which has a slave_id first' do
        vita_job = create(:vita_job, account: create(:account))
        vita_job.update! slave_id: nil
        job = create(:fetch_job, code_set: code_set)

        job_picker.execute.must_equal job
      end

      it 'must avoid jobs with wait_until exceeding current time' do
        create(:vita_job, account: create(:account), wait_until: 1.hour.since)
        job = create(:fetch_job, code_set: code_set)

        job_picker.execute.must_equal job
      end
    end

    describe 'create_new_repository_jobs' do
      let(:clump) { create(:git_clump) }

      before do
        Clump.stubs(:oldest_fetchable).returns([clump])
        Job.destroy_all
      end

      it 'wont create new repository jobs if allowed_types excludes CompleteJob' do
        Job::BlockedType.any_instance.stubs(:allowed).returns(Job.subclasses - [CompleteJob])

        Clump.any_instance.expects(:create_new_repository_jobs).never
        job_picker.execute.must_be_nil
      end

      it 'must ask clump to create new repository jobs' do
        Clump.any_instance.expects(:create_new_repository_jobs)
        job_picker.execute
      end
    end
  end
end
