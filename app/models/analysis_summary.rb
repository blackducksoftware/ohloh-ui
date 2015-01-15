class AnalysisSummary < ActiveRecord::Base
  belongs_to :analysis

  scope :by_popularity, -> { where.not(commit_count: 0).order(commit_count: :desc) }
  scope :thirty_day_summaries, -> { where(type: 'ThirtyDaySummary') }
end
