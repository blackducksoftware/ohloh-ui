class Alias < ActiveRecord::Base
  belongs_to :project
  belongs_to :commit_name, class_name: 'Name', foreign_key: :commit_name_id
  belongs_to :preferred_name, class_name: 'Name', foreign_key: :preferred_name_id
  has_one :create_edit, as: :target

  validates :commit_name_id, presence: true
  validates :preferred_name_id, presence: true

  after_save :schedule_project_analysis, if: :preferred_name_or_deleted_changed?
  after_save :update_unclaimed_person, if: :created_or_deleted?
  after_update :move_name_facts_to_preferred_name, if: :preferred_name_changed?

  # TODO: Figure out explain_yourself
  acts_as_editable editable_attributes: [:preferred_name_id]
  acts_as_protected parent: :project

  scope :for_project, lambda {|project|
    where(project_id: project.id)
      .where(deleted: false)
      .where.not(preferred_name_id: nil)
  }
  scope :committer_names, lambda { |project|
    Name.where(id: Commit.for_project(project).select(:name_id))
      .where.not(id: for_project(project).select(:commit_name_id))
      .where.not(id: for_project(project).select(:preferred_name_id))
      .where.not(id: Position.for_project(project).where.not(name_id: nil).select(:name_id))
      .order('lower(name)')
  }
  scope :preferred_names, lambda { |project, name_id = nil|
    Name.where(id: Commit.for_project(project).select(:name_id))
      .where.not(id: for_project(project).select(:commit_name_id))
      .where.not(id: name_id)
      .order('lower(name)')
  }

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

    def create_for_project(editor_account, project, commit_name_id, preferred_name_id, override_permissions = false)
      a = where(project_id: project.id, commit_name_id: commit_name_id).first_or_initialize
      a.editor_account = editor_account
      if a.persisted?
        update_pre_existing_alias(editor_account, a, commit_name_id, preferred_name_id)
      else
        a.assign_attributes(preferred_name_id: preferred_name_id)
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

    def update_pre_existing_alias(editor_account, a, commit_name_id, preferred_name_id)
      if commit_name_id == preferred_name_id
        CreateEdit.where(target: a).first.undo!(editor_account) unless a.deleted
      else
        CreateEdit.where(target: a).first.redo!(editor_account) if a.deleted
        a.update_attributes(preferred_name_id: preferred_name_id)
      end
      a.reload
    end
  end

  def schedule_project_analysis
    # TODO: project schedule_project_analysis
    # projects.schedule_delayed_analysis(10.minutes)
  end

  def update_unclaimed_person
    person = Person.where(name_id: commit_name_id, project_id: project_id).first_or_create
    contributor_fact = ContributorFact.find_by(name_id: preferred_name_id, analysis_id: project.best_analysis_id)
    if deleted?
      contributor_fact.try(:remove_name_fact, person.name_fact)
    elsif person
      contributor_fact.try(:append_name_fact, person.name_fact)
      person.destroy
    end
  end

  def move_name_facts_to_preferred_name
    name_fact = ContributorFact.find_by(name_id: commit_name_id, analysis_id: project.best_analysis_id)
    ContributorFact.find_by(name_id: preferred_name_id, analysis_id: project.best_analysis_id)
      .try(:append_name_fact, name_fact)
    ContributorFact.find_by(name_id: preferred_name_id_was, analysis_id: project.best_analysis_id)
      .try(:remove_name_fact, name_fact)
  end

  def preferred_name_or_deleted_changed?
    attribute_changed?(:preferred_name_id) || attribute_changed?(:deleted)
  end

  def preferred_name_changed?
    attribute_changed?(:preferred_name_id)
  end

  def created_or_deleted?
    attribute_changed?(:id) || attribute_changed?(:deleted)
  end
end
