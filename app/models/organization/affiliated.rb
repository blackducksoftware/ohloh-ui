class Organization::Affiliated < Organization::AccountFacts
  def initialize(organization)
    @organization = organization
  end

  def stats
    Organization.connection.select_one <<-SQL
      SELECT #{Organization.send(:sanitize_sql, selects)}
      FROM accounts A #{Organization.send(:sanitize_sql, account_facts_joins)}
      WHERE A.organization_id = #{@organization.id};
    SQL
  end

  def committers(page = 1, limit = 10)
    accounts = @organization.accounts.joins(%i[person positions])
    accounts = accounts.group('accounts.id, people.kudo_position').order('kudo_position nulls last')
    accounts.paginate(per_page: limit, page: page)
    Account.paginate_by_sql(accounts.to_sql, per_page: limit, page: page)
  end

  def projects(page = 1, limit = 10)
    @organization.projects.order('projects.user_count DESC')
                 .includes([:logo, best_analysis: %i[twelve_month_summary
                                                     previous_twelve_month_summary main_language]])
                 .paginate(per_page: limit, page: page)
  end

  private

  def selects
    <<-SQL
      #{affl_committers} AS affl_committers,
      #{affl_commits} AS affl_commits,
      #{affl_projects} AS affl_projects,
      #{affl_committers_out} AS affl_committers_out,
      #{affl_commits_out} AS affl_commits_out,
      #{affl_projects_out} AS affl_projects_out
      SQL
  end

  def affl_committers
    "COUNT(DISTINCT CASE WHEN P.organization_id = #{@organization.id} THEN A.id END)"
  end

  def affl_commits
    "COALESCE(SUM(CASE WHEN P.organization_id = #{@organization.id} THEN NF.commits ELSE 0 END), 0)"
  end

  def affl_projects
    "COUNT(DISTINCT CASE WHEN P.organization_id = #{@organization.id} THEN P.id END)"
  end

  def affl_committers_out
    "COUNT(DISTINCT CASE WHEN COALESCE(P.organization_id,0) <> #{@organization.id} THEN A.id END)"
  end

  def affl_commits_out
    "COALESCE(SUM(CASE WHEN COALESCE(P.organization_id,0) <> #{@organization.id} THEN NF.commits ELSE 0 END), 0)"
  end

  def affl_projects_out
    "COUNT(DISTINCT CASE WHEN COALESCE(P.organization_id,0) <> #{@organization.id} THEN P.id END)"
  end
end
