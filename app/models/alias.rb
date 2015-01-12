class Alias < ActiveRecord::Base
  def allow_undo?(key)
    ![:preferred_name_id].include?(key)
  end

  class << self
    # Returns the entries from the aliases table which resulted in the current best_analysis.
    # !!! Note that these entries may have been modified since the analysis ran !!!
    # This method is here to help determine which aliases are active and which are still pending.
    def best_analysis_aliases(project)
      aliases = Alias.arel_table
      aas = AnalysisAlias.arel_table
      projects = Project.arel_table
      Alias.joins([analysis_alias_join_sql(aas, aliases), project_join_sql(aas, aliases, projects)])
        .where(aliases[:project_id].eq(projects[:id]).and(projects[:id].eq(project.id)))
    end

    private

    def analysis_alias_join_sql(aas, aliases)
      aliases.join(aas)
        .on(aas[:commit_name_id].eq(aliases[:commit_name_id])
        .and(aas[:preferred_name_id].not_eq(aas[:commit_name_id]))).join_sources[0].to_sql
    end

    def project_join_sql(aas, aliases, projects)
      aliases.join(projects).on(projects[:best_analysis_id].eq(aas[:analysis_id])).join_sources[0].to_sql
    end
  end
end
