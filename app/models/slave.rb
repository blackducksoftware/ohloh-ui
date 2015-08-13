class Slave < ActiveRecord::Base
  MAX_DISK_USAGE = 98

  has_many :jobs
  has_many :logs, class_name: SlaveLog

  filterable_by ['hostname']

  class << self
    def from_param(param)
      where('id = ? or hostname = ?', param.to_i, param.to_s)
    end

    def max_jobs
      ENV['MAX_SLAVE_JOBS'].to_i
    end

    def max_jobs_per_type
      ENV['MAX_SLAVE_JOBS_PER_TYPE'].to_i
    end

    def local_hostname
      Socket.gethostname
    end

    def local
      order(:id).find_by(hostname: local_hostname)
    end
  end

  def too_busy_for_new_job?
    load_average.to_f > ENV['MAX_NEW_JOB_LOAD_AVERAGE'].to_f
  end

  def allowed?
    allow_deny == 'allow'
  end

  def local?
    hostname == Slave.local_hostname
  end

  def run(cmd)
    _stdin, stdout, stderr = Open3.popen3('bash', '-c', cmd)
    fail "#{ cmd } failed: #{ stderr.read }" if stderr.any?
    stdout.read
  end

  def run_on_clump_machine(cmd)
    run "ssh #{ ENV['CLUMP_MACHINE_ADDRESS'] } '#{ cmd }'"
  end

  # NOTE: Replaces get_disk_space.
  # The columns used_blocks and available_blocks are useful only in the views.
  def update_used_percent
    disk_info = run_on_clump_machine("df -P -m '#{Clump::DIRECTORY}' | tail -1").strip
    self.used_percent = disk_info.slice(/\d+(?=%)/)
  end

  def update_load_average
    system_uptime = run('uptime')
    self.load_average = system_uptime.slice(/(?<=load average: )[\d.]+/)
  end

  def disk_full?
    used_percent && (used_percent >= MAX_DISK_USAGE)
  end
end
