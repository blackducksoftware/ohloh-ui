class Contribution < ActiveRecord::Base
  include ContributionAssociations
  include ContributionScopes

  SORT_OPTIONS = [:name, :kudo_position, :commits, :twelve_month_commits,
                  :language, :latest_commit, :newest, :oldest]
  self.primary_key = :id

  filterable_by ['effective_name', 'accounts.akas', 'languages.nice_name', 'languages.name']

  def contributor_fact
    super || NilContributorFact.new
  end

  def position
    super || NilPosition.new
  end

  def kudoable
    (person && person.account) || self
  end

  def recent_kudos(limit = 3)
    kudos.limit(limit)
  end

  def analysis_aliases
    AnalysisAlias.for_contribution(self)
  end

  def scm_names
    analysis_aliases.collect(&:commit_name).uniq.compact
  end

  def committer_name
    name_fact_id ? contributor_fact.name.name : person.effective_name
  end

  class << self
    def sort(key)
      key = :commits unless key && SORT_OPTIONS.include?(key.to_sym)
      send("sort_by_#{key}")
    end

    def generate_id_from_project_id_and_name_id(project_id, name_id)
      ((project_id << 32) + name_id + 0x80000000)
    end

    def generate_id_from_project_id_and_account_id(project_id, account_id)
      (project_id << 32) + account_id
    end

    def generate_project_id_and_name_id_from_id(id)
      [id >> 32, id & 0x7FFFFFFF]
    end

    def find_indirectly(contribution_id:, project:)
      aka = find_alias_from_name_id(contribution_id, project)
      return unless aka
      find_from_generated_id(project, aka) || find_from_positions(project, aka)
    end

    def refresh
      ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW CONCURRENTLY contributions')
    end

    private

    def find_alias_from_name_id(contribution_id, project)
      _, name_id = generate_project_id_and_name_id_from_id(contribution_id)
      project.aliases.find_by(commit_name_id: name_id)
    end

    def find_from_generated_id(project, aka)
      generated_id = generate_id_from_project_id_and_name_id(project.id, aka.preferred_name_id)
      project.contributions.find_by(id: generated_id)
    end

    def find_from_positions(project, aka)
      position = project.positions.find_by(name_id: aka.preferred_name_id)
      return unless position
      contribution_id = generate_id_from_project_id_and_account_id(project.id, position.account_id)
      project.contributions.find_by(id: contribution_id)
    end
  end
end
