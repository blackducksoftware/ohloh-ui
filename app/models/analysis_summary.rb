# frozen_string_literal: true

class AnalysisSummary < ApplicationRecord
  serialize :recent_contributors

  belongs_to :analysis, optional: true

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
      project_id = analysis.project_id
      name_ids = recent_contributors[1..]
      person_with_name_sql = Person.where(project_id: project_id, name_id: name_ids).to_sql
      person_with_account_sql = Person.where(account_id: Position.select(:account_id)
                                .where(project_id: project_id, name_id: name_ids)).to_sql
      Person.from("(#{person_with_name_sql} union #{person_with_account_sql}) people")
    else
      Person.where(id: recent_contributors)
    end
  end
end
