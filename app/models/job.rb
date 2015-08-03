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

  def fork!
    pid = Process.fork do
      ActiveRecord::Base.establish_connection
      set_process_title('Starting')
      slave.log_info("Spawned Job #{ id } in process #{ Process.pid }", self)

      trap_exit
      setup_environment
      run!
    end

    ActiveRecord::Base.establish_connection
    pid
  end

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

  def schedule!
    Job.transaction do
      reload
      fail 'Cannot schedule a running job.' if running?
      update(status: STATUS_SCHEDULED, slave: nil, exception: nil, backtrace: nil)
    end
  end

  def progress_message
    '' # Override in derived classes
  end

  def set_process_title(status = '')
    $0 = "#{ initial_letter } Job #{ id } (#{ current_step || '-' }/#{ max_steps || '-' }) #{ status }"
  end

  class << self
    def incomplete_project_job(project_ids)
      where(project_id: project_ids).where.not(status: STATUS_COMPLETED).first
    end

    def clean(older_than = nil)
      jobs = Job.where(status: STATUS_COMPLETED)
      jobs = jobs.where('current_step_at < ?', older_than) if older_than
      jobs.delete_all
    end

    def all_types
      subclasses
    end
  end

  private

  def set_code_set_id
    self.code_set_id ||= sloc_set.code_set_id
  end

  def set_repository_id
    self.repository_id ||= code_set.repository_id
  end

  def trap_exit
    trap 'EXIT' do
      if running?
        update(status: Job::STATUS_FAILED, exception: 'Host process killed.')
        FailureGroup.categorize(@job.id)
        slave.log_error('Host process killed.', self)
      end
    end
  end
end
