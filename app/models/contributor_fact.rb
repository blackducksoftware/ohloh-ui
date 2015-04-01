class ContributorFact < NameFact
  belongs_to :analysis
  belongs_to :name

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

  def monthly_commits(years = 5)
    AnalysisCommitHistoryQuery.new(analysis, name_id, Time.now.utc, Time.now.utc - years.years).execute
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
end
