require 'test_helper'

class Job::BlockedTypeTest < ActiveSupport::TestCase
  describe 'allowed' do
    it 'must be empty when max_jobs count is reached' do
      Slave.stubs(:max_jobs).returns(3)

      create_list(:fetch_job, 2, status: Job::STATUS_RUNNING)
      create(:import_job, status: Job::STATUS_RUNNING)

      Job::BlockedType.new.allowed.must_be :empty?
    end

    it 'must avoid db_intensive jobs when load is too high' do
      ImportJob.must_be :db_intensive?
      LoadAverage.stubs(:too_high?).returns(true)

      Job::BlockedType.new.allowed.must_equal(Job.subclasses - [ImportJob])
    end

    it 'must avoid cpu_intensive jobs when slave is busy' do
      ImportJob.must_be :cpu_intensive?
      FetchJob.must_be :disk_intensive?
      Slave.any_instance.stubs(:too_busy_for_new_job?).returns(true)

      Job::BlockedType.new.allowed.must_equal(Job.subclasses - [ImportJob, FetchJob])
    end

    it 'must avoid job types that have reached max_jobs_per_type running limit' do
      create_list(:fetch_job, 2, status: Job::STATUS_RUNNING)
      Slave.stubs(:max_jobs_per_type).returns(2)

      Job::BlockedType.new.allowed.must_equal(Job.subclasses - [FetchJob])
    end

    it 'must avoid avoid jobs which consume disk when disk is full' do
      FetchJob.must_be :consumes_disk?
      Slave.any_instance.stubs(:disk_full?).returns(true)

      Job::BlockedType.new.allowed.must_equal(Job.subclasses - [FetchJob])
    end

    it 'must block permanently blocked types' do
      slave = Slave.where(hostname: Socket.gethostname).first_or_create!
      slave.update! blocked_types: 'OrganizationJob FetchJob'

      Job::BlockedType.new.allowed.must_equal(Job.subclasses - [OrganizationJob, FetchJob])
    end
  end
end
