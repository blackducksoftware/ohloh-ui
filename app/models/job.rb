class Job < ActiveRecord::Base
  STATUS_SCHEDULED = 0
  STATUS_RUNNING   = 1
  STATUS_FAILED    = 3
  STATUS_COMPLETED = 5

  def initialize(attributes = {})
    super(attributes)
    self.code_set_id ||= sloc_set.code_set_id if sloc_set
    self.repository_id ||= code_set.repository_id if code_set_id
  end

  scope :incomplete, -> { where.not(status: STATUS_COMPLETED) }

  belongs_to :project
  belongs_to :repository
  belongs_to :code_set
  belongs_to :sloc_set
  belongs_to :account
  belongs_to :organization
  belongs_to :slave

  class << self
    def incomplete_project_job(project_ids)
      where(project_id: project_ids).where.not(status: STATUS_COMPLETED).first
    end
  end

  def self.db_intensive?()   false; end # Set to true if job class stresses the database
  def self.cpu_intensive?()  false; end # Set to true if job class stresses the local CPU or RAM
  def self.disk_intensive?() false; end # Set to true if job class stresses the local disk
  def self.consumes_disk?()  false; end # Set to true if job class permanently increases local disk consumption

  unless defined?(STATUS_SCHEDULED)
    STATUS_SCHEDULED = 0
    STATUS_RUNNING   = 1
    STATUS_FAILED    = 3
    STATUS_COMPLETED = 5
  end

  def scheduled?()    self.status == STATUS_SCHEDULED; end
  def running?()      self.status == STATUS_RUNNING;   end
  def failed?()       self.status == STATUS_FAILED;    end
  def completed?()    self.status == STATUS_COMPLETED; end
        def slow?() self.current_step_at and self.current_step_at < Time.now.utc - 1.hour end

  scope :scheduled,  -> { where(status: Job::STATUS_SCHEDULED) }
  scope :running,    -> { where(status: Job::STATUS_RUNNING) }
  scope :failed,     -> { where(status: Job::STATUS_FAILED) }
  scope :complete,   -> { where(status: Job::STATUS_COMPLETED) }
  scope :incomplete, -> { where.not(status: Job::STATUS_COMPLETED) }

  # Removes completed jobs from the queue
  def self.clean(older_than = nil) # All completed jobs by default
    if older_than
      Job.delete_all("status = #{STATUS_COMPLETED} and current_step_at < '#{older_than}'")
    else
      Job.delete_all("status = #{STATUS_COMPLETED}")
    end
  end

  def initialize(attributes={})
    super(attributes)
    self.code_set_id ||= self.sloc_set.code_set_id if self.sloc_set
    self.repository_id ||= self.code_set.repository_id if self.code_set_id
  end

  def initial_letter
    self.class.to_s[0..0]
  end

  def tool_tip
    tip = "(#{current_step || '-'}/#{max_steps || '-'})"
    tip << " (#{time_ago_in_words(current_step_at)})" if current_step_at
    tip << "\n#{project.name}" if project
    tip << "\n#{account.name}" if account
    tip << "\n#{repository.url} #{repository.module_name}" if repository
    tip << "\n\n#{exception}" if failed?
    tip
  end

  def set_process_title(status='')
    $0 = "#{initial_letter} Job #{ self.id } (#{current_step || '-'}/#{max_steps || '-'}) #{status}"
  end

  def insert_profiling_results
    Profile.insert_profiling_results(:job_id => self.id)
  end

  def fork!
    ActiveRecord::Base.remove_connection
    pid = Process.fork do
      # daemonize :stdout => "/tmp/out_#{self.id}", :stderr => "/tmp/err_#{self.id}", :chdir => Dir.pwd

      ActiveRecord::Base.establish_connection
      set_process_title("Starting")
      slave.log_info("Spawned Job #{self.id} in process #{ Process.pid }", self)

      init_profiling if slave.enable_profiling

      trap 0 do
        # If the process is exiting for any reason, mark running job as failed.
        if self.status == Job::STATUS_RUNNING
          self.update_attributes(:status => Job::STATUS_FAILED, :exception => "Host process killed.")
          self.slave.log_error("Host process killed.", self)
          FailureGroup.categorize({:job_id => self.id, :force => true})
          insert_profiling_results if slave.enable_profiling
        end
      end

      setup_environment
      run!
      insert_profiling_results if slave.enable_profiling
      ActiveRecord::Base.remove_connection
    end
    ActiveRecord::Base.establish_connection
    pid
  end

  def setup_environment
    # I can't figure out a set of environment variables that simultaneously pleases both
    # Subversion and Bazaar, so here comes the hack:
    if repository && repository.is_a?(BzrRepository)
      # Set LANG for benefit of Bazaar
      ENV['LANG']='en_US.UTF-8'
    else
      # Set LC_TYPE for benefit of Subversion
      # see http://www.juretta.com/log/2007/05/09/svn_can_t_convert_string_from_utf-8_to_native_encoding_/
      ENV['LC_CTYPE']='en_US.UTF-8'
    end
  end

  def run!
    begin
      self.update_attributes(:status => STATUS_RUNNING, :current_step => 0, :started_at => Time.now.utc,
                             :current_step_at => Time.now.utc, :slave => Slave.local)

      # OTWO-2569 Don't run jobs for a deleted project or
      # for a repo that has no active projects
      stop_run = if self.project
        self.project.deleted?
      elsif self.repository
        !self.repository.projects.any? { |p| !p.deleted? }
      end

      if stop_run
        # mark the job as completed, leave a log message and return
        self.update_attributes(:status => STATUS_COMPLETED)
        self.slave.log_info("Skipping Job: Inactive project or repo.", self)
        return set_process_title("Completed")
      end

      work do |step, max_steps|
        t = Time.now.utc
        self.update_attributes(:max_steps => max_steps,
          :current_step => step,
          :current_step_at => Time.now.utc,
          :exception => nil,
          :backtrace => nil
        )
        set_process_title("Running")

        # Kill this job if it has been running too long.
        # High-priority jobs are exempt from this check.
        # Note check of current_step < max_steps so that we don't kill a job just as it finishes :-)
        if self.priority <= 0 and (self.started_at < Time.now.utc - 8.hours) and ((current_step || 0) < (max_steps || 0)) and (self.is_a? FetchJob or self.is_a? TestingJob)
          raise JobTooLongException.new("Runtime limit exceeded.")
        end
      end
      # succeeded, we're done
      self.update_attributes(:status => STATUS_COMPLETED)
      self.after_completed
      self.slave.log_info("Job completed", self)
      set_process_title("Completed")
    rescue JobTooLongException
      self.slave.log_info("Runtime limit exceeded. Job rescheduled.", self)
      self.status = STATUS_SCHEDULED
      self.wait_until = Time.now.utc + 16.hours
      self.exception = $!.message
      self.backtrace = $!.backtrace.join("\n")
      self.save
    rescue
      self.slave.log_error("Job failed", self)
      self.status = STATUS_FAILED
      self.exception = $!.message
      self.backtrace = $!.backtrace.join("\n")
      self.save
      FailureGroup.categorize({:job_id => self.id, :force => true})
    end
  end

  # A hook to allow a finished job to trigger the next job in the chain
  def after_completed
  end

  def delete!
    if self.running?
      self.pause!
    end
    Job.delete(self.id)
  end

  def progress
    return nil unless self.max_steps && self.current_step
    return self.current_step.to_f / self.max_steps.to_f
  end

  def schedule!
    Job.transaction do
      self.reload
      raise RuntimeError.new("Cannot schedule a running job.") if self.running?
      update_attributes(:status => STATUS_SCHEDULED, :slave => nil, :exception => nil, :backtrace => nil)
    end
  end

  def progress_message
    "" # Override in derived classes
  end

  def stdout_filename
    "/tmp/job_#{self.id}.out"
  end

  def stderr_filename
    "/tmp/job_#{self.id}.err"
  end

  def self.all_types
    subclasses
    #[AnalyzeJob, CompleteJob, FetchJob, ImportJob, PlatformJob, RubyEvalJob, ShellExecuteJob, SlocJob, TestingJob, VitaJob]
  end

  # Reschedules jobs that failed for reasons that we understand and can be safely rescheduled.
  # For instance, a job that committed suicide due to high load can be rescheduled.
  def self.reschedule_well_known_failures
    error_messages = []

    pattern_rows = ActiveRecord::Base.connection.select_all("SELECT pattern FROM failure_groups WHERE auto_reschedule = true ORDER BY id ASC")
    pattern_rows.each do |pattern_row|
      error_messages.push(pattern_row["pattern"])
    end

    retry_delays = [ 3.hours, 12.hours, 1.day, 2.days, 4.days, 1.week, 2.weeks, 1.month, 2.months ]

    error_messages.each do |error_message|
      Job.where('status=3 AND exception ILIKE ? AND do_not_retry IS FALSE AND retry_count < ?',
               error_message, retry_delays.size).each do |job|
        job.status = Job::STATUS_SCHEDULED
        job.slave = nil
        job.wait_until = (job.current_step_at || Time.now.utc) + retry_delays[job.retry_count]
        job.retry_count += 1
        job.notes = job.notes.to_s + "Auto-rescheduled #{Time.now.utc}\n"
        job.save!
      end
    end
  end

  def self.try_svn_repository_if_svn_sync_repository_fails
    error_messages = [
      '%svnsync: % is out of date%'
    ]
    error_messages.each do |error_message|
      Job.where('status=3 AND exception LIKE ? AND do_not_retry IS FALSE', error_message).each do |job|
        if job.repository.is_a? SvnSyncRepository
          job.repository.convert_to_svn_repository_and_refetch
        end
      end
    end
  end

  def self.try_refetch_after_rebase
    Job.where('status=? AND exception LIKE ? AND do_not_retry IS FALSE', Job::STATUS_FAILED, '%git fetch%rejected%non-fast-forward%').each do |job|
      job.repository.refetch if job.repository.is_a?(GitRepository)
    end
  end

  def init_profiling
    APL::reset

    CodeSet.class_eval do
      add_profiling :fetch
      add_profiling :import
    end

    SlocSet.class_eval do
      add_profiling :sloc
    end

    Clump.class_eval do
      add_profiling :push
      add_profiling :pull
    end

    Project.class_eval do
      add_profiling :analyze
    end

    Organization.class_eval do
      add_profiling :analyze
    end

    Job.class_eval do
      add_profiling :run!, 'job'
    end

    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
      add_profiling :execute, 'db'
      add_profiling :query, 'db'
    end

    Shellout.class_eval do
      add_profiling :run, 'shell'
    end

    Object.class_eval do
      add_profiling :sleep
    end
  end
end

# ActiveRecord::Base.subclasses only returns the subclasses that have already been loaded,
# making its return value unpredictable and possibly incomplete. Rails ticket #11269.
#
# This bit of glue ensures that every possible job type is loaded so we can rely on #subclasses.
# Dir.glob(File.join(RAILS_ROOT,'app','models','**','*_job.rb')).each do |file|
  # require_dependency file
# end

class JobTooLongException < RuntimeError
end
