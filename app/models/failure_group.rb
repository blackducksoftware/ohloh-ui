class FailureGroup < ActiveRecord::Base
  has_many :jobs, -> { where(status: Job::STATUS_FAILED) }

  validates :name, :pattern, presence: true
end
