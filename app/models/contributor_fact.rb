class ContributorFact < NameFact
  fix_string_column_encodings!

  belongs_to :analysis
  belongs_to :name

  def name_language_facts
    NameLanguageFact.where(name_id: name_id, analysis_id: analysis_id)
      .order(total_months: :desc, total_commits: :desc, total_activity_lines: :desc)
  end

  def person
    Person.where(['name_id = ? AND project_id = ?', name_id, analysis.project_id]).first
  end

  def kudo_rank
    person && person.kudo_rank
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
      .where('commits.position <= analysis_sloc_sets.as_of')
      .group("date_trunc('day', commits.time)")
      .order("date_trunc('day', commits.time) desc")
      .limit(300)
  end

  def commits_within(from, to)
    Commit.for_contributor_fact(self)
      .where(time: from..to)
      .order(:time)
  end

  def monthly_commits(years = 5)
    options = { analysis: analysis, name_id: name_id, start_date: Time.now.utc - years.years, end_date: Time.now.utc }
    Analysis::CommitHistory.new(options).execute
  end

  class << self
    def unclaimed_for_project(project)
      ContributorFact.where.not(name_id: nil)
        .where(analysis_id: project.best_analysis_id)
        .where.not(name_id: Position.where.not(name_id: nil).where(project_id: project.id).select(:name_id))
    end

    def first_for_name_id_and_project_id(name_id, project_id)
      ContributorFact.joins(:project).where(projects: { id: project_id })
        .where('name_id = ? or name_id in (?)', name_id,
               AnalysisAlias.select(:preferred_name_id).joins(:project).where(commit_name_id: name_id)).first
    end
  end

  private

  def daily_commits_select_clause
    commit_arel = Commit.arel_table
    [commit_arel[:time].minimum.as('time'), commit_arel[:comment].minimum.as('comment'),
     commit_arel[Arel.star].count.as('count')]
  end
end
