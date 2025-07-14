# frozen_string_literal: true

class ContributorFact < NameFact
  belongs_to :analysis, optional: true
  belongs_to :name, optional: true

  def name_language_facts
    NameLanguageFact.where(name_id: name_id, analysis_id: analysis_id)
                    .order(total_months: :desc, total_commits: :desc, total_activity_lines: :desc)
  end

  def person
    Person.find_by(['name_id = ? AND project_id = ?', name_id, analysis.project_id])
  end

  def kudo_rank
    person&.kudo_rank
  end

  def append_name_fact(name_fact)
    return if name_fact.nil?

    self.commits += name_fact.commits
    self.email_address_ids += name_fact.email_address_ids
    save
  end

  def remove_name_fact(name_fact)
    return if name_fact.nil?

    self.commits -= name_fact.commits
    self.email_address_ids -= name_fact.email_address_ids
    save
  end

  def daily_commits
    Commit.for_contributor_fact(self)
          .select(daily_commits_select_clause)
          .group("date_trunc('day', commits.time)")
          .order(Arel.sql("date_trunc('day', commits.time) desc"))
          .limit(300)
  end

  def commits_within(from, to)
    Commit.for_contributor_fact(self)
          .where(time: from..to)
          .order(:time)
  end

  def monthly_commits(years = 5)
    options = { analysis: analysis, name_id: name_id, start_date: Time.current - years.years, end_date: Time.current }
    Analysis::CommitHistory.new(**options).execute
  end

  class << self
    def unclaimed_for_project(project)
      ContributorFact.where.not(name_id: nil)
                     .where(analysis_id: project.best_analysis_id)
                     .where.not(name_id:
                        Position.where.not(name_id: nil)
                                .where(project_id: project.id).select(:name_id))
    end

    def first_for_name_id_and_project_id(name_id, project_id)
      analysis_id = Project.find(project_id).best_analysis_id
      ContributorFact.where(analysis_id: analysis_id).find_by('name_id = ?', name_id) if analysis_id
    end
  end

  private

  def daily_commits_select_clause
    commit_arel = Commit.arel_table
    [commit_arel[:time].minimum.as('time'), commit_arel[:comment].minimum.as('comment'),
     commit_arel[Arel.star].count.as('count')]
  end
end
