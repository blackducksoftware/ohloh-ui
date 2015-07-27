module Job::StatusAccessors
  extend ActiveSupport::Concern

  included do
    STATUS_SCHEDULED = 0
    STATUS_RUNNING   = 1
    STATUS_FAILED    = 3
    STATUS_COMPLETED = 5

    scope :scheduled,  -> { where(status: STATUS_SCHEDULED) }
    scope :running,    -> { where(status: STATUS_RUNNING) }
    scope :failed,     -> { where(status: STATUS_FAILED) }
    scope :complete,   -> { where(status: STATUS_COMPLETED) }
    scope :incomplete, -> { where.not(status: STATUS_COMPLETED) }
  end

  def scheduled?
    status == STATUS_SCHEDULED
  end

  def running?
    status == STATUS_RUNNING
  end

  def failed?
    status == STATUS_FAILED
  end

  def completed?
    status == STATUS_COMPLETED
  end
end
