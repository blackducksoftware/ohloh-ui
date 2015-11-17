class Job < ActiveRecord::Base
  belongs_to :project
  belongs_to :repository
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
    self.repository_id ||= code_set.repository_id if code_set_id
  end

  scope :incomplete, -> { where.not(status: STATUS_COMPLETED) }
  scope :failed, -> { where(status: STATUS_FAILED) }
  scope :scheduled, -> { where(status: STATUS_SCHEDULED) }
  scope :complete, -> { where(status: STATUS_COMPLETED) }
  scope :scheduled_or_failed, -> { where(status: [STATUS_SCHEDULED, STATUS_FAILED]) }
  scope :since, ->(time) { where(current_step_at: time...Time.now) }
  scope :incomplete_or_since, ->(time) { incomplete || since(time) }

  belongs_to :project
  belongs_to :repository
  belongs_to :code_set
  belongs_to :sloc_set
  belongs_to :account
  belongs_to :organization

  def categorize_failure
    failure_group = FailureGroup.where('pattern ILIKE ?', exception).first
    update_column(failure_group_id: failure_group.id) if failure_group
  end

  class << self
    def incomplete_project_job(project_ids)
      where(project_id: project_ids).where.not(status: STATUS_COMPLETED).first
    end
  end
end
