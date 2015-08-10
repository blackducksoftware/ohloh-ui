require 'test_helper'

class SlaveDaemonTest < ActiveSupport::TestCase
  let(:slave) { Slave.where(hostname: Socket.gethostname).first_or_create }
  let(:slave_daemon) { SlaveDaemon.new }

  before do
    slave.update!(allow_deny: :allow)
    slave_daemon.stubs(:sleep)

    slave_daemon.instance_eval do
      def trap(_type, &block)
        block.call
      end

      def loop(&block)
        block.call
      end

      def `(_other)
        "2516 pts/48   Sl     0:00 F Job #{ Job.last.id } (0/2) Running"
      end
    end
  end

  describe 'run' do
    it 'must change the directory to application root' do
      slave_daemon.stubs(:trap_exit)
      slave_daemon.stubs(:run_job_loop)

      Dir.expects(:chdir).with(Rails.root)
      slave_daemon.run
    end

    it 'must create a log record on exit' do
      slave_daemon.stubs(:run_job_loop)
      assert_difference 'slave.logs.count' do
        slave_daemon.run
      end
    end

    describe 'job_loop' do
      before do
        Slave::Sync.any_instance.stubs(:execute)
        slave_daemon.stubs(:trap_exit)
      end

      it 'must update hardware statistics' do
        slave_daemon.stubs(:wait_for_jobs_to_complete)
        slave_daemon.stubs(:sync_running_jobs_count_with_db)
        slave_daemon.stubs(:fork_jobs)

        Slave.any_instance.expects(:update_used_percent)
        Slave.any_instance.expects(:update_load_average)
        slave_daemon.run
      end

      it 'must wait for existing jobs to complete' do
        slave_daemon.stubs(:update_hardware_stats)
        slave_daemon.stubs(:sync_running_jobs_count_with_db)
        slave_daemon.stubs(:fork_jobs)
        slave_daemon.stubs(:pids).returns([1])

        Process.expects(:waitpid).returns(true)
        slave_daemon.run
      end

      describe 'sync_running_jobs_count_with_db' do
        before do
          slave_daemon.stubs(:update_hardware_stats)
          slave_daemon.stubs(:fork_jobs)

          @job = create(:fetch_job, slave: slave, status: Job::STATUS_RUNNING)
        end

        it 'must increment count of running jobs correctly' do
          slave_daemon.run
          slave_daemon.instance_variable_get('@jobs_count').must_equal 1
        end

        it 'must mark jobs as failed if they are not running as a process' do
          slave_daemon.stubs(:running_job_ids).returns([])
          slave_daemon.run

          @job.reload.must_be :failed?
        end
      end

      describe 'fork_jobs' do
        before do
          slave_daemon.stubs(:update_hardware_stats)
          slave_daemon.stubs(:sync_running_jobs_count_with_db)
          slave_daemon.stubs(:wait_for_jobs_to_complete)
          slave_daemon.instance_variable_set('@jobs_count', 1)

          job = create(:fetch_job, slave: slave)
          Slave::JobPicker.any_instance.stubs(:execute).returns(job)
        end

        it 'wont fork a job when jobs are maxed out' do
          Slave.stubs(:max_jobs).returns(0)
          Job.any_instance.expects(:fork!).never

          slave_daemon.run
        end

        it 'must call fork! on the picked job' do
          Job.any_instance.expects(:fork!)
          slave_daemon.run
        end

        it 'must increment the job count' do
          Job.any_instance.stubs(:fork!)
          slave_daemon.run

          slave_daemon.instance_variable_get('@jobs_count').must_equal 2
        end
      end
    end
  end
end
