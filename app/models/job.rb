class Job < ActiveRecord::Base
  STATUS_SCHEDULED = 0
  STATUS_RUNNING   = 1
  STATUS_FAILED    = 3
  STATUS_COMPLETED = 5

  scope :incomplete, -> { where.not(status: STATUS_COMPLETED) }
end
