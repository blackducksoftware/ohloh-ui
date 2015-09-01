class Job < ActiveRecord::Base
  include StatusAccessors

  before_validation :set_code_set_id, if: :sloc_set, on: :create
  before_validation :set_repository_id, if: :code_set_id, on: :create

  has_many :clumps
  belongs_to :project
  belongs_to :repository
  belongs_to :code_set
  belongs_to :sloc_set
  belongs_to :account
  belongs_to :organization
  belongs_to :slave

  attr_reader :after_completed
  boolean_attr_accessor :db_intensive?, :cpu_intensive?, :disk_intensive?, :consumes_disk?,
                        :can_have_too_long_exception?, value: false

  def slow?
    current_step_at && current_step_at < Time.now.utc - 1.hour
  end

  def initial_letter
    self.class.to_s[0..0]
  end

  def progress_message
    '' # Override in derived classes
  end

  def set_process_title(status = '')
    $0 = "#{ initial_letter } Job #{ id } (#{ current_step || '-' }/#{ max_steps || '-' }) #{ status }"
  end

  def fork!
    pid = fork_daemonized_subprocess
    ActiveRecord::Base.establish_connection
    pid
  end

  def schedule!
    fail I18n.t('slaves.cant_schedule_running_job') if running?
    update(status: STATUS_SCHEDULED, slave: nil, exception: nil, backtrace: nil)
  end

  def categorize_on_failure
    update(failure_group_id: nil)
    failure_group = FailureGroup.where(FailureGroup.arel_table[:pattern].matches(exception)).first
    update(failure_group_id: failure_group.id) if failure_group
  end

  class << self
    def incomplete_project_job(project_ids)
      incomplete.where(project_id: project_ids).take
    end

    def clean(older_than = nil)
      jobs = Job.completed
      jobs = jobs.where('current_step_at < ?', older_than) if older_than
      jobs.delete_all
    end

    def all_types
      subclasses
    end
  end

  private

  def setup_environment
    # I can't figure out a set of environment variables that simultaneously pleases both
    # Subversion and Bazaar, so here comes the hack:
    if repository && repository.is_a?(BzrRepository)
      # Set LANG for benefit of Bazaar
      ENV['LANG'] = 'en_US.UTF-8'
    else
      # Set LC_TYPE for benefit of Subversion
      # see http://www.juretta.com/log/2007/05/09/svn_can_t_convert_string_from_utf-8_to_native_encoding_/
      ENV['LC_CTYPE'] = 'en_US.UTF-8'
    end
  end

  def run!
    Job::Manager.new(self).run
  end

  def set_code_set_id
    self.code_set_id ||= sloc_set.code_set_id
  end

  def set_repository_id
    self.repository_id ||= code_set.repository_id
  end

  def trap_exit
    trap 'EXIT' do
      if running?
        update(status: Job::STATUS_FAILED, exception: I18n.t('slaves.host_process_killed'))
        categorize_on_failure
        slave.logs.create!(message: I18n.t('slaves.host_process_killed'), job_id: id, code_set_id: code_set_id,
                           level: SlaveLog::ERROR)
      end
    end
  end

  def fork_daemonized_subprocess
    Process.fork do
      require 'daemons'
      Daemons.daemonize(DAEMONIZATION_OPTIONS)

      ActiveRecord::Base.establish_connection
      set_process_title(I18n.t('slaves.starting'))
      create_spawned_log

      trap_exit
      setup_environment
      run!
    end
  end

  def create_spawned_log
    slave.logs.create!(message: I18n.t('slaves.spawned_job', id: id, pid: Process.pid),
                       job_id: id, code_set_id: code_set_id)
  end
end
