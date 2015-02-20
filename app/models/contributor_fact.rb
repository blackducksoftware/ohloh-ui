class ContributorFact < NameFact
  class << self
    def unclaimed_for_project(project)
      ContributorFact.where.not(name_id: nil)
        .where(analysis_id: project.best_analysis_id)
        .where.not(name_id: Position.where.not(name_id: nil).where(project_id: project.id).select(:name_id))
    end

    def first_for_name_id_and_project_id(name_id, project_id)
      sql = <<-SQL
        SELECT name_facts.* FROM name_facts
          INNER JOIN projects ON projects.best_analysis_id = name_facts.analysis_id
          WHERE ( name_facts.name_id = #{name_id.to_i} OR name_facts.name_id IN (
            SELECT AA.preferred_name_id FROM analysis_aliases AA
            WHERE AA.analysis_id = projects.best_analysis_id AND AA.commit_name_id = #{name_id.to_i}))
          AND projects.id = #{project_id.to_i} AND type='ContributorFact'
        SQL
      ContributorFact.find_by_sql(sql).first
    end
  end
end
