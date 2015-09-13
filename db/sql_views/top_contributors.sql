CREATE OR REPLACE VIEW top_contributors_view AS
  SELECT
    CASE WHEN (pos.id IS NULL)
    THEN ((((per.project_id)::bigint << 32) + (per.name_id)::bigint) + (B'10000000000000000000000000000000'::"bit")::bigint)
    ELSE (((pos.project_id)::bigint << 32) + (pos.account_id)::bigint)
    END
  AS id, per.id AS person_id, COALESCE(pos.project_id, per.project_id) AS project_id,
  CASE WHEN (pos.id IS NULL) THEN per.name_fact_id
  ELSE (SELECT name_facts.id
  FROM name_facts WHERE ((name_facts.analysis_id = p.best_analysis_id) AND (name_facts.name_id = pos.name_id)))
  END AS name_fact_id, pos.id AS position_id
  FROM ((people per
    LEFT JOIN positions pos ON ((per.account_id = pos.account_id)))
    JOIN projects p ON (p.id = COALESCE(pos.project_id, per.project_id)))
    WHERE per.name_id IN (SELECT name_id from name_facts where type = 'ContributorFact' and analysis_id = p.best_analysis_id)
    OR per.account_id IN ( select account_id from positions where name_id IN (
      select name_id from name_facts where type = 'ContributorFact' and analysis_id = p.best_analysis_id )
    and project_id = p.id);
