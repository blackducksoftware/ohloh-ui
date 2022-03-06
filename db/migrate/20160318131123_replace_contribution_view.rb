# frozen_string_literal: true

class ReplaceContributionView < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL.squish
      CREATE OR REPLACE VIEW contributions AS (
        (
          SELECT id,
            id AS person_id,
            project_id AS project_id,
            name_fact_id AS name_fact_id,
            null AS position_id
          FROM people
          WHERE project_id IS NOT NULL
        )
        UNION
        (
          SELECT (positions.project_id::bigint << 32) + positions.account_id::bigint AS id,
            people.id AS person_id,
            positions.project_id,
            name_facts.id as name_fact_id,
            positions.id AS position_id
          FROM people
          INNER JOIN positions ON positions.account_id = people.account_id
          LEFT OUTER JOIN projects ON projects.id = positions.project_id
          LEFT OUTER JOIN name_facts ON name_facts.analysis_id = projects.best_analysis_id
            AND name_facts.name_id = positions.name_id
        )
      );

      CREATE INDEX index_name_facts_on_analysis_id_and_name_id ON name_facts(analysis_id, name_id);
    SQL
  end

  def down
    execute <<-SQL.squish
      CREATE OR REPLACE VIEW contributions AS
       SELECT
              CASE
                  WHEN (pos.id IS NULL) THEN
                    ((((per.project_id)::bigint << 32) + (per.name_id)::bigint) +
                      (B'10000000000000000000000000000000'::"bit")::bigint)
                  ELSE (((pos.project_id)::bigint << 32) + (pos.account_id)::bigint)
              END AS id,
          per.id AS person_id,
          COALESCE(pos.project_id, per.project_id) AS project_id,
              CASE
                  WHEN (pos.id IS NULL) THEN per.name_fact_id
                  ELSE ( SELECT name_facts.id
                     FROM name_facts
                    WHERE ((name_facts.analysis_id = p.best_analysis_id) AND (name_facts.name_id = pos.name_id)))
              END AS name_fact_id,
          pos.id AS position_id
         FROM ((people per
           LEFT JOIN positions pos ON ((per.account_id = pos.account_id)))
           JOIN projects p ON ((p.id = COALESCE(pos.project_id, per.project_id))));

      DROP INDEX index_name_facts_on_analysis_id_and_name_id;
    SQL
  end
end
