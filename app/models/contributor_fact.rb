class ContributorFact < NameFact
  class << self
    def unclaimed_for_project(project)
      ContributorFact.where.not(name_id: nil)
        .where(analysis_id: project.best_analysis_id)
        .where.not(name_id: Position.where.not(name_id: nil).where(project_id: project.id).select(:name_id))
    end
  end
end
