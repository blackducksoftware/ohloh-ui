require 'open4'
require 'socket'

class Slave < ActiveRecord::Base
  has_many :clumps
  has_many :jobs
  has_many :slave_logs

  filterable_by ['hostname']

  MAX_DISK_USAGE = 98

  DEFAULT_JOB_PRIORITY = -10 # the initial priority of a auto-scheduled complete job
  CLUMPS_TO_SCHEDULE = 50 # number of clumps to schedule in one go when auto-scheduling

  class << self
    def from_param(param)
      where('id = ? or hostname = ?', param.to_i, param)
    end

    def max_jobs
      ENV['MAX_SLAVE_JOBS'].to_i
    end

    # Keeping this number slightly below max_jobs prevents the cluster from being monopolized
    # by a single job type. For example, if 20,000 SlocJobs are in the queue, we want to make sure
    # that we continue to do some amount of background fetching, analyzing, etc.
    def max_jobs_per_type
      ENV['MAX_SLAVE_JOBS_PER_TYPE'].to_i
    end
  end

  # Allows us to put the hostname in the URL, which disallows some characters
  def safe_hostname
    hostname.gsub(/\W/,'_')
  end

  def too_busy_for_git?
    load_average.to_f > ENV['MAX_GIT_LOAD_AVERAGE'].to_f
  end

  def too_busy_for_new_job?
    load_average.to_f > ENV['MAX_NEW_JOB_LOAD_AVERAGE'].to_f
  end

  def too_busy_for_fetch?
    load_average.to_f > ENV['MAX_FETCH_LOAD_AVERAGE'].to_f
  end

  # Puts the process to sleep until the load average on this
  # slave falls below the specified threshold.
  #
  # After waiting about an hour, an exception will be raised
  # to kill the process.
  def sleep_while_busy
    minutes = 1
    while self.reload.too_busy_for_fetch?
      if minutes < 64
        self.log_warning("Local slave too busy. Sleeping for #{minutes} minute(s).")
        sleep minutes * 60
        minutes *= 2
      else
        msg = "Local slave still too busy after long wait. Committing suicide."
        self.log_fatal(msg)
        raise RuntimeError.new(msg)
      end
    end
    self.load_average
  end

  def allowed?
    return false if self.allow_deny != "allow"
    true
  end

  def denied?
    return true if self.allow_deny != "allow"
    false
  end

  def allow!
    self.update_attribute('allow_deny','allow')
    self.log_info("Job permissions allowed.")
  end

  def deny!
    self.update_attribute('allow_deny','deny')
    self.log_info("Job permissions denied.")
  end

  def self.allow_all!
    Slave.all.each { |s| s.allow! }
  end

  def self.deny_all!
    Slave.all.each { |s| s.deny! }
  end

  def offline!
    self.update_attribute('clump_status', '')
    self.log_info("Clump storage at #{self.clump_dir} taken offline")
  end

  def online!
    self.update_attribute('clump_status', 'RW')
    self.log_info("Clump storage at #{self.clump_dir} is now online")
  end

  def read_only!
    self.update_attribute('clump_status', 'R')
    self.log_info("Clump storage at #{self.clump_dir} is now online")
  end

  def offline?
    self.clump_status.to_s == ''
  end

  def online?
    self.clump_status == 'RW'
  end

  def read_only?
    self.clump_status == 'R'
  end

  def self.local_hostname
    @@hostname ||= begin
      SECURE_TREE["sys_name"] || Socket.gethostname
    end
  end

  def self.local
    Slave.order(:id).find_by(hostname: self.local_hostname)
  end

  # Generates helper methods to access slaves by name: Slave.congo, Slave.kenya, etc.
  def self.method_missing(name, *params)
    if name != :find_by_hostname
      Slave.find_by_hostname(name.to_s) || super(name, *params)
    else
      super(name, *params)
    end
  end

  def local?
    self.hostname == Slave.local_hostname
  end

  def run(cmd)
    out = nil
    err = nil
    logger.debug { cmd }
    status = Open4::popen4("sh") do | pid, stdin, stdout, stderr |
      stdin.puts cmd
      stdin.close
      out = stdout.read
      err = stderr.read
    end
    raise RuntimeError.new("#{cmd} failed: #{out}\n#{err}") if status.exitstatus != 0
    out
  end

  def run_local_or_remote(cmd)
    if local?
      run cmd
    else
      run "ssh #{self.hostname} '#{cmd}'"
    end
  end

  # Read the free disk space available for clumps
  # Works locally or on a remote machine
  def get_disk_space
    unless (self.clump_dir and self.clump_dir.length > 1)
      raise RuntimeError.new("Cannot determine disk space because slave.clump_dir is not set.")
    end
    self.used_blocks      = nil
    self.available_blocks = nil
    self.used_percent     = nil
    if self.clump_dir and !self.clump_dir.empty?
      df = self.run_local_or_remote("df -P -m '#{self.clump_dir}' | tail -1").strip
      if df =~ /^.+\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)%\s+/
        self.used_blocks      = $2.to_i
        self.available_blocks = $3.to_i
        self.used_percent     = $4.to_i
      end
    else
    end
  end

  def disk_full?
    (self.used_percent and self.used_percent >= Slave::MAX_DISK_USAGE)
  end

  # Reads the host load average.
  # Works locally or on a remote machine.
  def get_load_average
    self.run_local_or_remote("uptime").strip =~ /([\.\d]+)\,?\s([\.\d]+)\,?\s([\.\d]+)$/
    self.load_average = $1.to_f
  end

  def human_blocks(blocks)
    if blocks.nil?
      nil
    elsif blocks < 1000
      "#{blocks} MB"
    elsif blocks < 1e4
      "#{blocks.to_s[0..0]}.#{blocks.to_s[1..1]} GB"
    elsif blocks < 1e6
      "#{blocks.to_s[0..-4]} GB"
    elsif blocks < 1e7
      "#{blocks.to_s[0..0]}.#{blocks.to_s[1..1]} TB"
    elsif blocks < 1e9
      "#{blocks.to_s[0..-7]} TB"
    end
  end

  def self.per_page
    50
  end

  def human_used_blocks
    human_blocks(self.used_blocks)
  end
  def human_available_blocks
    human_blocks(self.available_blocks)
  end

  # Reconcile the database to match the state on disk.
  # Works locally or on a remote machine
  def sync!
    self.log_warning("Synchronizing database to match clumps found in #{self.clump_dir}.")
    code_set_ids = self.find_code_sets_on_disk

    # Delete database rows that point to non-existent clumps
    self.clumps.each do |clump|
      i = code_set_ids.index(clump.code_set_id)
      if i
        code_set_ids[i] = nil
      else
        SlaveLog.create(:message => "#{clump.path} not found. Deleted from database.", :slave => self, :code_set_id => clump.code_set_id)
        Clump.delete_all(["slave_id=? AND code_set_id=?", self.id, clump.code_set_id])
      end
    end

    # Add database rows for clumps not already in the database
    code_set_ids.compact.each do |code_set_id|
      cs = CodeSet.find_by(id: code_set_id)
      if cs
        clump = cs.create_clump(self)
        self.log_warning("#{clump.path} found. Added to database.", cs)
      else
        # We have a clump on disk for a code_set that doesn't exist.
        FileUtils.rm_rf path_from_code_set_id(code_set_id)
        SlaveLog.create(:message => "Clump for code_set #{code_set_id} found, but no such code_set exists. Deleted from disk.", :slave => self)
      end
    end
  end

  def code_set_id_from_path(path)
    if path =~ /\/(\d\d\d)\/(\d\d\d)\/(\d\d\d)\/?$/
      $3.to_i + $2.to_i * 1000 + $1.to_i * 1000000
    else
      nil
    end
  end

  # Returns an array of code_set_ids for the clump directories actually on disk
  def find_code_sets_on_disk
    return [] unless File.exist?(self.clump_dir + '/000')
    self.run("find #{self.clump_dir}/000 -maxdepth 3 -mindepth 3"
            ).split.collect { |path| self.code_set_id_from_path(path) }.compact
  end

  # The list of slaves we could potentially create a new clump on.
  # Those are slaves who are (1) someone else, (2) are online, (3) have free disk space,
  # and (4) not already hosting the code_set in question.
  # They are ordered by the lag time of the slave fetch queue, fastest slave first.
  def eligible_target_slaves(code_set_id)
    raise RuntimeError.new("code_set_id required") unless code_set_id
    Slave.find_by_sql <<-SQL
      SELECT slaves.* FROM slaves
      WHERE id != #{self.id}
      AND UPPER(clump_status) LIKE '%W%'
      AND (used_percent IS NULL OR used_percent < #{Slave::MAX_DISK_USAGE})
      AND id NOT IN (SELECT slave_id FROM clumps WHERE code_set_id=#{code_set_id})
      ORDER BY (COALESCE(oldest_clump_timestamp,'1970-01-01')) DESC
              ,(COALESCE(used_percent,100)) ASC
    SQL
  end

  def log(message, obj=nil, level=SlaveLog::DEBUG)
    log = SlaveLog.new(:message => message, :level => level, :slave => self)
    if obj.is_a?(CodeSet)
      log.code_set_id = obj.id
    elsif obj.is_a?(Job)
      log.job_id = obj.id
      log.code_set_id = obj.code_set_id
    end
    log.save!
  end

  def log_debug(message, obj=nil)   ; self.log(message, obj, SlaveLog::DEBUG)   ; end
  def log_info(message, obj=nil)    ; self.log(message, obj, SlaveLog::INFO)    ; end
  def log_warning(message, obj=nil) ; self.log(message, obj, SlaveLog::WARNING) ; end
  def log_error(message, obj=nil)   ; self.log(message, obj, SlaveLog::ERROR)   ; end
  def log_fatal(message, obj=nil)   ; self.log(message, obj, SlaveLog::FATAL)   ; end

  # Finds the oldest clump on this slave, and schedules its project(s) for a fetch.
  # A slave can do this for itself whenever it finds itself idle.
  def schedule_fetch(priority=DEFAULT_JOB_PRIORITY, count=1)
    clumps = self.oldest_fetchable_clumps(count)
    if clumps
      clumps.each do |clump|
        clump.code_set.repository.enlistments.each do |e|
          e.project.schedule_fetch(priority)
          self.log_info "Auto-scheduled fetch for Project #{e.project_id} (#{e.project.name})"
        end
        self.update_attributes(:oldest_clump_timestamp => clump.code_set.logged_at)
      end
    end
    clumps
  end

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

  # The infamous job picker.
  def pick_job(job_types = Job.send(:subclasses))
    return nil unless self.allowed? # The slave is specifically denied by the Admin UI

    # Determine the types of jobs that are currently desired and permitted
    job_types = [job_types] unless job_types.is_a? Array
    job_types = job_types - self.currently_blocked_types
    unless job_types.any? # All requested job types are blocked
      self.log_debug("All job types are blocked due to high load.")
      return nil
    end

    job = pick_scheduled_job(job_types)

    if !job && job_types.include?(CompleteJob)
      # If no job was available, try auto-scheduling a fetch
      self.schedule_fetch(DEFAULT_JOB_PRIORITY, CLUMPS_TO_SCHEDULE)
      job = self.pick_scheduled_job(job_types)
    end

    job
  end

  def pick_scheduled_job(job_types)
    loop do
      # First try to pick a job for a code_set held locally
      candidate = job_candidate(job_types, false)

      # If no job found that way, pick a job that requires pulling a code_set
      if self.fast? && !self.disk_full?
        candidate = job_candidate(job_types, true) unless candidate
      end

      # If still no job, give up
      return nil unless candidate

      # try to reserve the candidate
      rows_affected = Job.connection.update <<-SQL
        UPDATE jobs SET slave_id=#{ self.id }, status=#{ Job::STATUS_RUNNING }
        #{ where_clause(job_types) } AND id=#{ candidate.id }
      SQL
      return candidate.reload if rows_affected > 0
    end
  end

  def job_candidate(job_types, ok_to_create_clump=false)
    or_create = ok_to_create_clump ? 'OR TRUE' : 'OR clumps.slave_id IS NULL'

    # The left join conditions here confirm that either (a) job does not require a code set (like an analysis)
    # or that (b) we already have a clump for this code_set locally.
    #
    # The 'or_create' clause allows us to run a job even if we do not have a local clump.
    # This can happen by request or if no one at all has a clump (someone has to go first for a new fetch).
    candidates = Job.find_by_sql <<-SQL
      SELECT   jobs.* FROM jobs
      LEFT OUTER JOIN clumps ON jobs.code_set_id = clumps.code_set_id
      #{ where_clause(job_types) }
      AND      (jobs.code_set_id IS NULL OR clumps.slave_id=#{self.id} #{or_create})
      ORDER BY priority DESC, slave_id LIMIT 1
    SQL
    candidates.first
  end

  def where_clause(job_types)
    where = <<-SQL
      WHERE    status = #{Job::STATUS_SCHEDULED}
      AND      ( jobs.slave_id IS NULL OR jobs.slave_id=#{self.id} )
      AND      ( #{ job_type_clause(job_types) } )
      AND      COALESCE(wait_until, '1980-01-01') <= now() at time zone 'utc'
    SQL
  end

  def job_type_clause(job_types)
    job_types.empty? ? 'FALSE' : "jobs.type IN (#{ [job_types].flatten.collect{ |t| "'#{t.to_s}'"}.join(",")})"
  end

  # Hydrates the 'blocked_types' string into an array of Classes
  #  'CompleteJob, VitaJob' => [CompleteJob, VitaJob]
  def permanently_blocked_types
    blocked_types.to_s.strip.split(/\W+/).compact.map do |t|
      Kernel.const_get(t)
    end.sort_by(&:to_s).uniq
  end

  # Based on the load averages of the slave and database,
  # returns a list of job types that should not be started.
  def currently_blocked_types
    all_types = Job.send(:subclasses)

    running_job_counts = self.running_job_counts
    return all_types if running_job_counts.values.sum >= Slave.max_jobs

    result = permanently_blocked_types

    # Block database-intensive jobs when the database is busy
    all_types.each { |c| result << c if c.db_intensive? } if LoadAverage.too_high?

    # Block slave-intensive jobs when the slave is busy
    all_types.each { |c| result << c if c.cpu_intensive? || c.disk_intensive? } if self.too_busy_for_new_job?

    # Block disk-consuming jobs when disk is full
    all_types.each { |c| result << c if c.consumes_disk? } if self.disk_full?

    all_types.each do |c|
      result << c if (running_job_counts[c.to_s] || 0) >= Slave.max_jobs_per_type
    end

    result.sort_by(&:to_s).uniq
  end

  def running_job_counts
    counts = {}
    results = ActiveRecord::Base.connection.select_all <<-SQL
      SELECT type, count(*) AS count FROM jobs WHERE status=1 AND slave_id = #{self.id} GROUP BY type
    SQL
    results.each { |r| counts[r['type']] = r['count'].to_i }
    counts
  end

  def recent_jobs(time_span='1 hour')
    self.jobs.where("((status=?) OR ((status=?) AND (current_step_at IS NULL OR current_step_at > now() at time zone 'utc' - interval ?)))", Job::STATUS_RUNNING, Job::STATUS_FAILED, time_span).order("status, id").limit(20)
  end

  def rescheduled_slow_jobs
    self.jobs.where("type='FetchJob' AND status=0 AND wait_until > now() at time zone 'utc' AND exception='Runtime limit exceeded.'")
  end

  def self.median_slave
    conditions = "clump_status='RW' AND oldest_clump_timestamp IS NOT NULL"
    count = Slave.where(conditions).count
    Slave.where(conditions).order('oldest_clump_timestamp').offset(count/2).first
  end

  # Slaves with a lag time 50% lower than the median
  def self.fast_slaves
    median = self.median_slave
    return [] unless median
    Slave.where("clump_status='RW' AND oldest_clump_timestamp IS NOT NULL and oldest_clump_timestamp > ?", Time.now.utc - (Time.now.utc - median.oldest_clump_timestamp) / 2).order('oldest_clump_timestamp')
  end

  # Slaves with a lag time 50% higher than the median
  def self.slow_slaves
    median = self.median_slave
    return [] unless median
    Slave.where("clump_status='RW' AND oldest_clump_timestamp IS NOT NULL and oldest_clump_timestamp < ?", Time.now.utc - (Time.now.utc - median.oldest_clump_timestamp) * 1.5).order('oldest_clump_timestamp DESC')
  end

  def fast?
    Slave.fast_slaves.include? self
  end

  def slow?
    Slave.slow_slaves.include? self
  end

  def load_balance
    if self.slow?
      self.log_debug "Load balancer reducing clump load on #{self.hostname}"
      clump = oldest_deletable_clump
      clump.hard_delete if clump
    end
  end

  # It's old, it doesn't have a job pending, and it has too many backup copies
  def oldest_deletable_clump
    self.clumps.where('code_set_id NOT IN (SELECT code_set_id FROM jobs WHERE status != ? AND code_set_id IS NOT NULL) AND code_set_id IN (SELECT code_set_id FROM clumps GROUP BY code_set_id HAVING COUNT(*) > 1 AND COUNT(*) > ?)', Job::STATUS_COMPLETED, BACKUP_CLUMPS+1).order('fetched_at').first
  end

  # Moves one clump from this machine to another.
  # Returns the new clump, or nil if a clone could not be made.
  #
  # If you specify a target slave, clumps will be moved to that slave,
  # otherwise one will be chosen.
  def free_disk_space!(slave=nil)
    clump = oldest_fetchable_clumps(1).first
    return nil unless clump

    if slave
      new_clump = clump.move_to(slave)
      return new_clump if new_clump
    else
      self.eligible_target_slaves(clump.code_set_id).each do |slave|
        new_clump = clump.move_to(slave)
        return new_clump if new_clump
      end
    end

    return nil
  end

  # If both hostnames end with a number, sort numerically, rather than alphabetically
  def self.numeric_hostname_sort(a,b)
    na = $1.to_i if a.hostname =~ /\D*(\d+)$/
    nb = $1.to_i if b.hostname =~ /\D*(\d+)$/
    if na && nb
      na <=> nb
    else
      a.hostname <=> b.hostname
    end
  end
end
