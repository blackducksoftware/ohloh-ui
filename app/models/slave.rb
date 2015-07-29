class Slave < ActiveRecord::Base
  has_many :jobs
  has_many :logs, class_name: SlaveLog

  filterable_by ['hostname']

  MAX_DISK_USAGE = 98

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

    def per_page
      50
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

  # Finds the oldest clump on this slave, and schedules its project(s) for a fetch.
  # A slave can do this for itself whenever it finds itself idle.

  # Basically, finds the oldest clump on this slave that needs updating.
  # The following rules apply:
  #    1. Don't pick a clump that already has a job scheduled
  #    2. Don't pick the same clump twice within its repository update_interval
  #    3. Don't pick a clump that hasn't been analyzed since the last fetch
  #
  # Rule 2 allows us to fetch busy repositories more often, and idle repositories less often.
  #
  # Rule 3 deserves some explanation. It basically limits the number of fetches on a
  # repository to once per analysis, for couple of reasons:
  #
  # First, some large projects like GNOME have 500 clumps irregularly distributed
  # across the slave farm, and not all slaves update their clumps at the same pace.
  # This means that a fast slave will try to reschedule GNOME over and over while
  # a slow slave struggles to update it even once. The result of this is that the slow slave
  # spends all of its time updating GNOME and never makes any forward progress on any other project.
  # Ironically, GNOME itself never gets an analysis because there is always a job scheduled.
  # Therefore, we prevent the fast slave from rescheduling a project until all of the slow slaves
  # are finished and the project is analyzed.
  #
  # Also, Rule 3 has the effect of not scheduling a project for update if it has one or more
  # repositories with failed jobs. This prevents slaves from wasting time updating
  # the good repositories -- that time is wasted because the project as a whole can't be
  # analyzed anyway.
  def oldest_fetchable_clumps(limit=1)
    clumps = Clump.find_by_sql <<-SQL
      SELECT C.* FROM clumps C
      INNER JOIN code_sets CS ON C.code_set_id = CS.id
      INNER JOIN repositories R ON R.best_code_set_id = CS.id
      INNER JOIN enlistments E ON E.repository_id = R.id AND E.deleted IS FALSE
      INNER JOIN projects P on E.project_id = P.id AND P.deleted IS FALSE
      INNER JOIN analyses A ON A.id = P.best_analysis_id
      WHERE COALESCE(CS.logged_at, '1970-01-01') + R.update_interval * INTERVAL '1 second' <= NOW() AT TIME ZONE 'utc'
      /* 1 second slop factor because evidently there is occasionally one microsecond error in timestamps */
      AND COALESCE(A.logged_at, '1970-01-01') >= COALESCE(CS.logged_at, '1970-01-01') - INTERVAL '1 second'
      AND NOT EXISTS (
        SELECT * FROM jobs WHERE jobs.repository_id = R.id AND jobs.status != #{Job::STATUS_COMPLETED}
      )
      AND C.slave_id = #{self.id}
      ORDER BY COALESCE(CS.logged_at,'1970-01-01') ASC LIMIT #{limit.to_i}
    SQL
  end
end
