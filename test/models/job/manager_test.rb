require 'test_helper'

class Job::ManagerTest < ActiveSupport::TestCase
  let(:account) { create(:account) }
  let(:job) { create(:fetch_job) }
  before do
    def job.work
      yield 1, 2
    end
  end

  describe 'run' do
    it 'must update the status to running and current_step to 0' do
      job_manager = Job::Manager.new(job)
      job_manager.stubs(:inactive_projects?).returns(true)
      job_manager.stubs(:update_completed_status).returns(true)

      job_manager.run

      job.reload
      job.must_be :running?
      job.current_step.must_equal 0
      job.started_at.must_be :present?
      job.current_step_at.must_be :present?
    end

    it 'wont execute the job if project is deleted' do
      project = create(:project, deleted: true)
      job.update!(project: project)

      job_manager = Job::Manager.new(job)
      job_manager.expects(:execute).never
      job_manager.run
    end

    it 'must set job status to completed when project is deleted' do
      project = create(:project, deleted: true)
      job.update!(project: project)

      job_manager = Job::Manager.new(job)
      assert_difference 'SlaveLog.count' do
        job_manager.run
      end

      job.reload
      job.must_be :completed?
    end

    it 'wont execute the job if repository has any deleted projects' do
      repository = create(:repository)
      repository.enlistments.first.project.update! deleted: true, editor_account: account
      job.update!(repository: repository)

      job_manager = Job::Manager.new(job)
      job_manager.expects(:execute).never
      job_manager.run
    end

    it 'will execute the job if repository has any non deleted projects' do
      repository = create(:repository)
      repository.enlistments.first.project.update! deleted: true, editor_account: account
      create(:enlistment, repository: repository)
      job.update!(repository: repository)

      job_manager = Job::Manager.new(job)
      job_manager.stubs(:mark_as_complete)
      job_manager.expects(:execute)
      job_manager.run
    end

    it 'must mark the job as completed' do
      job.stubs(:after_completed)
      job_manager = Job::Manager.new(job)
      job_manager.stubs(:execute)

      job_manager.run

      job.reload
      job.must_be :completed?
      SlaveLog.find_by(message: I18n.t('slaves.job_completed'), job: job).must_be :present?
    end

    it 'must handle JobTooLongException' do
      job.update!(code_set: create(:code_set))
      job.stubs(:started_at).returns(9.hours.ago)
      CodeSet.any_instance.stubs(:fetch)

      Job::Manager.new(job).run

      job.reload
      job.must_be :scheduled?
      job.wait_until.must_be :>, Time.now.utc + 15.hours
      SlaveLog.find_by(message: I18n.t('slaves.runtime_exceeded_job_rescheduled'), job: job).must_be :present?
    end

    it 'must handle exception' do
      job.update!(code_set: create(:code_set))
      CodeSet.any_instance.stubs(:fetch)

      job_manager = Job::Manager.new(job)

      def job_manager.execute
        fail RuntimeError
      end

      job.expects(:categorize_on_failure)
      job_manager.run
      job.reload
      job.exception.must_equal 'RuntimeError'
      job.backtrace.must_be :present?
      SlaveLog.find_by(message: I18n.t('slaves.job_failed'), job: job).must_be :present?
    end
  end

  describe 'execute' do
    it 'must update steps in job' do
      job_manager = Job::Manager.new(job)
      job_manager.stubs(:kill_long_running_job)
      job_manager.send(:execute)

      job.reload
      job.current_step.must_equal 1
      job.max_steps.must_equal 2
    end

    it 'must fail if it is running for too long' do
      FetchJob.must_be :can_have_too_long_exception?
      job.update!(started_at: 8.hours.ago)

      -> { Job::Manager.new(job).send(:execute) }.must_raise(JobTooLongException)
    end
  end
end
