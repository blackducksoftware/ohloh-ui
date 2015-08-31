class NamedCommit < ActiveRecord::Base
  ALLOWED_TIME_SPAN = { '30 days' => :last_30_days, '12 months' => :last_year }

  self.primary_key = :id

  belongs_to :commit
  belongs_to :analysis
  belongs_to :code_set
  belongs_to :project
  belongs_to :position
  belongs_to :account
  belongs_to :person
  belongs_to :contribution

  has_many :commit_flags, class_name: CommitFlag, foreign_key: :commit_id

  scope :by_newest, -> { order('commits.time desc') }
  scope :by_oldest, -> { order('commits.time asc') }
  scope :last_30_days, -> { where('commits.time BETWEEN ? AND ?', Time.current - 30.days, Time.current) }
  scope :last_year, -> { where('commits.time BETWEEN ? AND ?', Time.current - 12.months, Time.current) }
  scope :within_timespan, lambda { |timespan|
    send(ALLOWED_TIME_SPAN[timespan]) if ALLOWED_TIME_SPAN.keys.include?(timespan)
  }

  filterable_by ['effective_name', 'commits.comment', 'accounts.akas']
end
