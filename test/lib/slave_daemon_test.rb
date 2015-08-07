require 'test_helper'

class SlaveDaemonTest < ActiveSupport::TestCase
  let(:slave) { Slave.where(hostname: Socket.gethostname).first_or_create }

  before do
    slave.update!(allow_deny: :allow)
    SlaveDaemon.stubs(:sleep)
  end

  describe 'run' do
    it 'must change the directory to application root' do
      SlaveDaemon.stubs(:trap_exit)
      SlaveDaemon.stubs(:run_job_loop)

      Dir.expects(:chdir).with(Rails.root)
      SlaveDaemon.run
    end

    it 'must create a log record on exit' do
      SlaveDaemon.instance_eval do
        def trap(_type, &block)
          block.call
        end
      end

      SlaveDaemon.stubs(:run_job_loop)
      assert_difference 'slave.logs.count' do
        SlaveDaemon.run
      end
    end

    describe 'job_loop' do
      before do
        Slave::Sync.any_instance.stubs(:execute)
        SlaveDaemon.stubs(:trap_exit)

        SlaveDaemon.instance_eval do
          def loop(&block)
            block.call
          end
        end
      end

      it 'must update hardware statistics' do
        SlaveDaemon.stubs(:wait_for_jobs_to_complete)
        SlaveDaemon.stubs(:sync_running_jobs_count_with_db)
        SlaveDaemon.stubs(:fork_jobs)

        Slave.any_instance.expects(:update_used_percent)
        Slave.any_instance.expects(:update_load_average)
        SlaveDaemon.run
      end

      it 'must wait for existing jobs to complete' do
        SlaveDaemon.stubs(:update_hardware_stats)
        SlaveDaemon.stubs(:sync_running_jobs_count_with_db)
        SlaveDaemon.instance_eval do
          def fork_jobs
            @pids = [1]
          end
        end

        Process.expects(:waitpid).returns(true)
        SlaveDaemon.run
      end

      describe 'sync_running_jobs_count_with_db' do
        before do
          SlaveDaemon.stubs(:update_hardware_stats)
          SlaveDaemon.stubs(:fork_jobs)

          @job = create(:fetch_job, slave: slave, status: Job::STATUS_RUNNING)
        end

        it 'must increment count of running jobs correctly' do
          # rubocop:disable Style/GlobalVars
          $job_id = @job.id
          SlaveDaemon.instance_eval do
            def `(_other)
              "2516 pts/48   Sl     0:00 F Job #{ $job_id } (0/2) Running"
            end
          end
          # rubocop:enable Style/GlobalVars

          SlaveDaemon.run
          SlaveDaemon.instance_variable_get('@jobs_count').must_equal 1
        end

        it 'must mark jobs as failed if they are not running as a process' do
          SlaveDaemon.stubs(:running_job_ids).returns([])
          SlaveDaemon.run

          @job.reload.must_be :failed?
        end
      end

      describe 'fork_jobs' do
        before do
          SlaveDaemon.stubs(:update_hardware_stats)
          SlaveDaemon.stubs(:sync_running_jobs_count_with_db)
          SlaveDaemon.stubs(:wait_for_jobs_to_complete)
          SlaveDaemon.instance_variable_set('@jobs_count', 1)

          job = create(:fetch_job, slave: slave)
          Slave::JobPicker.any_instance.stubs(:execute).returns(job)
        end

        it 'wont fork a job when jobs are maxed out' do
          Slave.stubs(:max_jobs).returns(0)
          Job.any_instance.expects(:fork!).never

          SlaveDaemon.run
        end

        it 'must call fork! on the picked job' do
          Job.any_instance.expects(:fork!)
          SlaveDaemon.run
        end

        it 'must increment the job count' do
          Job.any_instance.stubs(:fork!)
          SlaveDaemon.run

          SlaveDaemon.instance_variable_get('@jobs_count').must_equal 2
        end
      end
    end
  end
end
