require 'test_helper'

class SlaveTest < ActiveSupport::TestCase
  let(:slave) { Slave.where(hostname: Socket.gethostname).first_or_create }

  describe 'from_param' do
    it 'must find by id when param is an integer' do
      Slave.from_param(slave.id).take.must_equal slave
    end

    it 'must find by hostname when param is a string' do
      Slave.from_param(slave.hostname).take.must_equal slave
    end
  end

  it 'max_jobs: must return the value from environment' do
    ENV['MAX_SLAVE_JOBS'] = '8'
    Slave.max_jobs.must_equal 8
  end

  it 'max_jobs_per_type: must return the value from environment' do
    ENV['MAX_SLAVE_JOBS_PER_TYPE'] = '5'
    Slave.max_jobs_per_type.must_equal 5
  end

  it 'local: must return the slave record for local hostname' do
    Slave.local.must_equal slave
  end

  describe 'local?' do
    it 'must be true when slave.hostname matches local_hostname' do
      slave.must_be :local?
    end
  end

  describe 'allowed?' do
    it 'must be true when allow_deny is set to allow' do
      slave.update!(allow_deny: :allow)
      slave.must_be :allowed?
    end
  end

  describe 'too_busy_for_new_job?' do
    it 'must be true when load_average is greater than preset load_average limit' do
      slave.update! load_average: 15
      ENV['MAX_NEW_JOB_LOAD_AVERAGE'] = '10'

      slave.must_be :too_busy_for_new_job?
    end
  end

  describe 'run' do
    it 'must run the given command on the system' do
      command = 'ls -l'

      slave.stubs(:command_failed?)
      slave.expects(:`).with(command)
      slave.run(command)
    end

    it 'must raise exception when command fails' do
      command = 'ls -l'

      slave.stubs(:command_failed?).returns(true)
      slave.expects(:`).with(command)
      -> { slave.run(command) }.must_raise(Exception)
    end
  end

  it 'run_on_clump_machine: must ssh into clump machine to run the command' do
    ENV['CLUMP_MACHINE_ADDRESS'] = '127.0.0.1'
    command = 'ls -l'

    slave.expects(:run).with("ssh #{ ENV['CLUMP_MACHINE_ADDRESS'] } '#{ command }'")
    slave.run_on_clump_machine(command)
  end

  it 'update_used_percent: must update the disk usage correctly' do
    slave.expects(:run_on_clump_machine).returns('/dev/sda1              461365 356399     81508      82% /')
    slave.update_used_percent
    slave.used_percent.must_equal 82
  end

  it 'update_load_average: must update the load correctly' do
    slave.expects(:run).returns('15:58:25 up 17 days, 2:18, 5 users, load average: 0.46, 0.30, 0.29')
    slave.update_load_average
    slave.load_average.must_equal 0.46
  end

  describe 'disk_full?' do
    it 'must be true when used_percent is greater than MAX_DISK_USAGE' do
      slave.used_percent = Slave::MAX_DISK_USAGE + 1
      slave.must_be :disk_full?
    end
  end
end
