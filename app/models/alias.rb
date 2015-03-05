class Alias < ActiveRecord::Base
  belongs_to :project
  belongs_to :commit_name, class_name: 'Name', foreign_key: :commit_name_id
  belongs_to :preferred_name, class_name: 'Name', foreign_key: :preferred_name_id

  acts_as_editable editable_attributes: [:preferred_name_id]
  acts_as_protected parent: :project

  def allow_undo_to_nil?(key)
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

    def create_for_project(editor_account, project, commit_name, preferred_name, override_permissions = false)
      a = where(project_id: project.id, commit_name_id: commit_name.id).first_or_initialize
      a.editor_account = editor_account
      if a.persisted?
        update_pre_existing_alias(editor_account, a, commit_name, preferred_name)
      else
        a.assign_attributes(preferred_name_id: preferred_name.id)
        override_permissions ? a.save_without_validation! : a.save!
      end
      a
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

    def update_pre_existing_alias(editor_account, a, commit_name, preferred_name)
      if commit_name.id == preferred_name.id
        CreateEdit.where(target: a).first.undo!(editor_account) unless a.deleted
      else
        CreateEdit.where(target: a).first.redo!(editor_account) if a.deleted
        a.update_attributes(preferred_name_id: preferred_name.id)
      end
      a.reload
    end
  end
end
