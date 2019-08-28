# frozen_string_literal: true

class Organization::Outside < Organization::AccountFacts
  def initialize(organization)
    @organization = organization
  end

  def stats
    Organization.connection.select_one <<-SQL
      SELECT
        COUNT(DISTINCT(A.id)) as out_committers,
        COALESCE(SUM(NF.commits), 0) as out_commits,
        COUNT(DISTINCT(P.id)) as out_projs
      FROM accounts A #{Organization.send(:sanitize_sql, account_facts_joins)}
      WHERE P.organization_id = #{Organization.send(:sanitize_sql, @organization.id)}
        AND COALESCE(A.organization_id,0) <> #{Organization.send(:sanitize_sql, @organization.id)};
    SQL
  end

  def committers(page = 1, limit = 10)
    Account.paginate_by_sql(outside_committers_sql, page: page, per_page: limit)
  end

  def projects(page = 1, limit = 10)
    Project.paginate_by_sql(outside_projects_sql, page: page, per_page: limit)
  end

  private

  def outside_committers_sql
    <<-SQL
      SELECT A.id, A.login, A.name, A.organization_id, A.email_md5, PER.kudo_rank, array_agg(P.id) as projs,
        COALESCE(SUM(NF.twelve_month_commits),0) as twelve_mo_commits, SUM(NF.commits) as all_time_commits
      FROM accounts A #{Organization.send(:sanitize_sql, account_facts_joins)}
      INNER JOIN people PER ON PER.account_id = A.id
      WHERE P.organization_id = #{Organization.send(:sanitize_sql, @organization.id)}
      AND COALESCE(A.organization_id,0) <> #{Organization.send(:sanitize_sql, @organization.id)}
      GROUP BY A.id, A.login, A.name, A.organization_id, PER.kudo_rank
      ORDER BY twelve_mo_commits DESC
    SQL
  end

  def outside_projects_sql
    <<-SQL
      SELECT #{project_select_clause},
        COUNT(DISTINCT(A.id)) as contribs_count, COALESCE(SUM(NF.commits),0) as commits
      FROM accounts A #{Organization.send(:sanitize_sql, account_facts_joins)}
      WHERE COALESCE(P.organization_id,0) <> #{Organization.send(:sanitize_sql, @organization.id)}
      AND A.organization_id = #{Organization.send(:sanitize_sql, @organization.id)}
      GROUP BY P.id, P.name, P.vanity_url, P.user_count, P.rating_average,
               P.logo_id, P.best_analysis_id, P.organization_id
      ORDER BY contribs_count DESC
    SQL
  end

  def project_select_clause
    'P.id, P.name, P.vanity_url, P.user_count, P.rating_average, P.logo_id, P.best_analysis_id, P.organization_id'
  end
end
