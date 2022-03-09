# frozen_string_literal: true

class Alias < ApplicationRecord
  include AliasScopes
  belongs_to :project, optional: true
  belongs_to :commit_name, class_name: 'Name', optional: true
  belongs_to :preferred_name, class_name: 'Name', optional: true
  has_one :create_edit, as: :target
  has_many :edits, as: :target

  validates :commit_name_id, presence: true
  validates :preferred_name_id, presence: true

  after_update :remove_unclaimed_person

  after_update :move_name_facts_to_preferred_name, if: proc { |obj|
                                                         (obj.saved_changes.keys & %w[preferred_name_id]).present?
                                                       }
  after_save :update_unclaimed_person, if: proc { |obj| (obj.saved_changes.keys & %w[id deleted]).present? }
  after_save :schedule_project_analysis, if: proc { |obj|
                                               (obj.saved_changes.keys & %w[preferred_name_id deleted]).present?
                                             }

  acts_as_editable editable_attributes: [:preferred_name_id]
  acts_as_protected parent: :project

  def allow_undo_to_nil?(key)
    [:preferred_name_id].exclude?(key)
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

    def create_for_project(editor_account, project, commit_name_id, preferred_name_id, override_permissions: false)
      alias_obj = where(project_id: project.id, commit_name_id: commit_name_id).first_or_initialize
      alias_obj.editor_account = editor_account
      if alias_obj.persisted?
        update_pre_existing_alias(editor_account, alias_obj, commit_name_id, preferred_name_id)
      else
        alias_obj.assign_attributes(preferred_name_id: preferred_name_id)
        override_permissions ? alias_obj.save_without_validation! : alias_obj.save!
      end
      alias_obj
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

    def update_pre_existing_alias(editor_account, alias_obj, commit_name_id, preferred_name_id)
      if commit_name_id == preferred_name_id
        CreateEdit.find_by(target: alias_obj).undo!(editor_account) unless alias_obj.deleted
      else
        CreateEdit.find_by(target: alias_obj).redo!(editor_account) if alias_obj.deleted
        alias_obj.update(preferred_name_id: preferred_name_id)
      end
      alias_obj.reload
    end
  end

  def schedule_project_analysis
    project.schedule_delayed_analysis(10.minutes)
  end

  def remove_unclaimed_person
    return unless Person.exists?(name_id: commit_name_id, project_id: project_id)

    update_unclaimed_person if saved_change_to_preferred_name_id?
  end

  def update_unclaimed_person
    person = Person.where(name_id: commit_name_id, project_id: project_id).first_or_create
    contributor_fact = ContributorFact.find_by(name_id: preferred_name_id, analysis_id: project.best_analysis_id)
    return unless contributor_fact

    if deleted?
      contributor_fact.remove_name_fact(person.name_fact)
    elsif person
      contributor_fact.append_name_fact(person.name_fact)
      person.destroy
    end
  end

  def move_name_facts_to_preferred_name
    name_fact = contributor_fact_for_commit
    ContributorFact.find_by(name_id: preferred_name_id, analysis_id: project.best_analysis_id)
                   .try(:append_name_fact, name_fact)
    ContributorFact.find_by(name_id: saved_changes[:preferred_name_id][0], analysis_id: project.best_analysis_id)
                   .try(:remove_name_fact, name_fact)
  end

  def contributor_fact_for_commit
    ContributorFact.find_by(name_id: commit_name_id, analysis_id: project.best_analysis_id)
  end
end
