class AnalysisSummary < ActiveRecord::Base
  belongs_to :analysis

  scope :by_popularity, -> { where.not(commit_count: 0).order(commit_count: :desc) }
  scope :thirty_day_summaries, -> { where(type: 'ThirtyDaySummary') }

  def commits_count
    affiliated_commits_count.to_i + outside_commits_count.to_i
  end

  def committer_count
    affiliated_committers_count.to_i + outside_committers_count.to_i
  end
end
