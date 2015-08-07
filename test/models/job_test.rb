require 'test_helper'

class JobTest < ActiveSupport::TestCase
  before do
    Process.instance_eval do
      def fork(&block)
        block.call
      end
    end
  end

  let(:repository) { create(:git_repository) }
  let(:code_set) { create(:code_set, repository: repository) }
  let(:slave) { Slave.where(hostname: Socket.gethostname).first_or_create }

  describe 'slow?' do
    it 'must be true when current_step_at is older than an hour' do
      job = Job.new(current_step_at: 2.hours.ago)
      job.must_be :slow?
    end

    it 'must be false when current_step_at is within the last hour' do
      job = Job.new(current_step_at: 59.minutes.ago)
      job.wont_be :slow?
    end
  end

  describe 'initial_letter' do
    it 'must return the initial part of class name' do
      FetchJob.new.initial_letter.must_equal 'F'
    end
  end

  describe 'fork!' do
    let(:job) { create(:fetch_job, slave: slave, code_set: code_set) }

    before do
      ActiveRecord::Base.stubs(:establish_connection)
      Job::Manager.any_instance.stubs(:run)
    end

    it 'must set LC_CTYPE for non BzrRepository' do
      job.repository.must_be_instance_of(GitRepository)
      job.fork!
      ENV['LC_CTYPE'].must_equal 'en_US.UTF-8'
    end

    it 'must set LANG for BzrRepository' do
      job.update! repository: create(:bzr_repository)
      job.fork!
      ENV['LANG'].must_equal 'en_US.UTF-8'
    end

    describe 'handling exit event' do
      before do
        Job.class_eval do
          def trap(_type, &block)
            block.call
          end
        end

        job.update! status: Job::STATUS_RUNNING
      end

      it 'must set status to failed' do
        job.fork!
        job.must_be :failed?
      end

      it 'must call categorize_on_failure' do
        job.expects(:categorize_on_failure)
        job.fork!
      end

      it 'must create a slave error log' do
        assert_difference -> { SlaveLog.where(level: SlaveLog::ERROR).count } do
          job.fork!
        end
      end
    end
  end

  describe 'categorize_on_failure' do
    let(:job) { create(:fetch_job, slave: slave, code_set: code_set) }

    it 'must set the correct failure_group' do
      failure_message = 'Host process killed.'
      failure_group = FailureGroup.create!(pattern: failure_message, name: Faker::Name.first_name)

      job.failure_group_id.must_be_nil
      job.update!(exception: failure_message)
      job.categorize_on_failure

      job.reload.failure_group_id.must_equal failure_group.id
    end
  end

  describe 'clean' do
    it 'must delete all jobs where status is completed' do
      completed_job = create(:fetch_job, status: Job::STATUS_COMPLETED)
      incomplete_job = create(:fetch_job, status: Job::STATUS_FAILED)

      Job.clean

      Job.find_by(id: completed_job.id).must_be_nil
      incomplete_job.reload.wont_be_nil
    end

    it 'must clean jobs after the given date' do
      older_job = create(:fetch_job, status: Job::STATUS_COMPLETED, current_step_at: 3.days.ago)
      newer_job = create(:fetch_job, status: Job::STATUS_COMPLETED, current_step_at: 1.day.ago)

      Job.clean(2.days.ago)

      Job.find_by(id: older_job.id).must_be_nil
      newer_job.reload.wont_be_nil
    end
  end

  describe 'schedule!' do
    it 'must fail if job is already running' do
      job = create(:fetch_job, status: Job::STATUS_RUNNING)

      -> { job.schedule! }.must_raise(Exception)
    end

    it 'must update status and reset values' do
      job = create(:fetch_job)

      job.schedule!

      job.reload
      job.must_be :scheduled?
      job.exception.must_be_nil
      job.backtrace.must_be_nil
    end
  end

  it 'progress_message: must be blank' do
    Job.new.progress_message.must_be :blank?
  end

  it 'all_types: must return subclasses' do
    Job.all_types.must_equal Job.subclasses
  end

  it 'incomplete_project_job: must return the first incomplete job' do
    project = create(:project)
    incomplete_job = create(:fetch_job, status: Job::STATUS_FAILED, project: project)

    Job.incomplete_project_job([project.id]).must_equal(incomplete_job)
  end
end
