class AnalysisSummary < ActiveRecord::Base
  serialize :recent_contributors

  belongs_to :analysis

  scope :by_popularity, -> { where.not(commit_count: 0).order(commit_count: :desc) }
  scope :thirty_day_summaries, -> { where(type: 'ThirtyDaySummary') }

  def commits_count
    affiliated_commits_count.to_i + outside_commits_count.to_i
  end

  def committer_count
    affiliated_committers_count.to_i + outside_committers_count.to_i
  end

  def recent_contribution_persons
    return [] if recent_contributors.empty?
    @recent_contribution_persons ||= find_recent_contribution_persons(recent_contributors.first.to_s == 'name_ids')
  end

  private

  def find_recent_contribution_persons(has_name_ids)
    if has_name_ids
      pid, name_ids = analysis.project_id, recent_contributors[1..-1].join(',')
      Person.find_by_sql AnalysisSummary.send :sanitize_sql, <<-SQL
        SELECT P.* FROM people P
        WHERE (P.name_id IN (#{name_ids}) AND P.project_id = #{pid}) OR P.account_id IN
        (SELECT account_id FROM positions where project_id = #{pid} AND name_id IN (#{name_ids}))
      SQL
    else
      Person.where(id: recent_contributors)
    end
  end
end
