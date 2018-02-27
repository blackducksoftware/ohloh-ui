class Job < ActiveRecord::Base
  belongs_to :project
  belongs_to :slave
  belongs_to :job_status, foreign_key: 'status'
  belongs_to :failure_group
  has_many :slave_logs

  STATUS_SCHEDULED = 0
  STATUS_RUNNING   = 1
  STATUS_FAILED    = 3
  STATUS_COMPLETED = 5

  def initialize(attributes = {})
    super(attributes)
    self.code_set_id ||= sloc_set.code_set_id if sloc_set
    self.code_location_id ||= code_set.code_location_id if code_set_id
  end

  scope :incomplete, -> { where.not(status: STATUS_COMPLETED) }
  scope :failed, -> { where(status: STATUS_FAILED) }
  scope :scheduled, -> { where(status: STATUS_SCHEDULED) }
  scope :complete, -> { where(status: STATUS_COMPLETED) }
  scope :running, -> { where(status: STATUS_RUNNING) }

  scope :slave_recent_jobs, lambda {|count = 20|
    rankings = 'select id, RANK() OVER (PARTITION BY slave_id, status ORDER BY id ASC) rank FROM jobs'
    joins("INNER JOIN (#{rankings}) rankings ON rankings.id = jobs.id")
      .where('rankings.rank < :count', count: count.next)
      .order(id: :asc)
  }
  scope :scheduled_or_failed, -> { where(status: [STATUS_SCHEDULED, STATUS_FAILED]) }
  scope :since, ->(time) { where(current_step_at: time...Time.current) }
  scope :incomplete_or_since, ->(time) { incomplete || since(time) }
  scope :uncategorized_failure_group, -> { where(failure_group_id: nil).failed.with_exception }
  scope :categorized_failure_group, -> { where.not(failure_group_id: nil).failed.with_exception }
  scope :with_exception, -> { where.not(exception: nil) }

  belongs_to :code_set
  belongs_to :sloc_set
  belongs_to :account
  belongs_to :organization

  def categorize_failure
    failure_group = FailureGroup.find_by('pattern ILIKE ?', exception)
    update_column(failure_group_id: failure_group.id) if failure_group
    # Used by admin
    code_location.update(do_not_fetch: true) if failure_group.present? && !failure_group.auto_reschedule
  end

  def running?
    status == STATUS_RUNNING
  end

  def failed?
    status == STATUS_FAILED
  end

  def code_location
    @code_location ||= CodeLocation.find(code_location_id)
  end

  class << self
    def incomplete_project_job(project_ids)
      where(project_id: project_ids).where.not(status: STATUS_COMPLETED).first
    end
  end
end
