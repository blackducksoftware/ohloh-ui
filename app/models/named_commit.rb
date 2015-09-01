class NamedCommit < ActiveRecord::Base
  TIME_SPANS = { '30 days' => :last_30_days, '12 months' => :last_year }

  self.primary_key = :id
  self.per_page = 20

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
  scope :last_30_days, ->(logged_at) { where('commits.time > ?', logged_at - 30.days) }
  scope :last_year, ->(logged_at) { where('commits.time > ?', logged_at - 12.months) }
  scope :within_timespan, lambda { |time_span, logged_at|
    return unless logged_at && TIME_SPANS.keys.include?(time_span)
    send(TIME_SPANS[time_span], logged_at)
  }

  filterable_by ['effective_name', 'commits.comment', 'accounts.akas']
end
