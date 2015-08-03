class Slave < ActiveRecord::Base
  MAX_DISK_USAGE = 98

  has_many :jobs
  has_many :logs, class_name: SlaveLog

  filterable_by ['hostname']


  class << self
    def from_param(param)
      where('id = ? or hostname = ?', param.to_i, param)
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
    output = `#{ cmd }`
    fail "#{ cmd } failed: #{ output }" unless $CHILD_STATUS == 0
    output
  end

  def run_on_clump_machine(cmd)
    run "ssh #{ ENV['CLUMP_MACHINE_ADDRESS'] } '#{ cmd }'"
  end

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

  def oldest_fetchable_clumps(limit = 1)
    Clump.joins(code_set: { best_repository: { enlistments: { project: :best_analysis } } })
      .where(project: { deleted: false })
      .where("COALESCE(CS.logged_at, '1970-01-01') + R.update_interval * INTERVAL '1 second'
              <= NOW() AT TIME ZONE 'utc'")
      .where("COALESCE(A.logged_at, '1970-01-01') >= COALESCE(CS.logged_at, '1970-01-01') - INTERVAL '1 second'")
      .where(Job.incomplete.where('jobs.repository_id = repositories.id').exists.not)
      .order('code_sets.logged_at nulls first')
      .limit(limit)
  end
end
