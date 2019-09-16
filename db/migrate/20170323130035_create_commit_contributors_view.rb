# frozen_string_literal: true

class CreateCommitContributorsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW commit_contributors as SELECT analysis_aliases.commit_name_id AS id,
      sloc_sets.code_set_id AS code_set_id,
      analysis_aliases.commit_name_id AS name_id,
      analysis_sloc_sets.analysis_id,
      projects.id AS project_id,
      positions.id AS position_id,
      positions.account_id,
        CASE
            WHEN positions.account_id IS NULL THEN (projects.id::bigint << 32) + analysis_aliases.preferred_name_id::bigint + B'10000000000000000000000000000000'::"bit"::bigint
            ELSE (projects.id::bigint << 32) + positions.account_id::bigint
        END AS contribution_id,
        CASE
            WHEN positions.account_id IS NULL THEN (projects.id::bigint << 32) + analysis_aliases.preferred_name_id::bigint + B'10000000000000000000000000000000'::"bit"::bigint
            ELSE positions.account_id::bigint
        END AS person_id
      FROM analysis_sloc_sets
      JOIN sloc_sets ON analysis_sloc_sets.sloc_set_id = sloc_sets.id
      JOIN projects ON analysis_sloc_sets.analysis_id = projects.best_analysis_id
      JOIN analysis_aliases ON analysis_aliases.analysis_id = analysis_sloc_sets.analysis_id
      LEFT JOIN positions ON positions.project_id = projects.id AND positions.name_id = analysis_aliases.preferred_name_id;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW commit_contributors;
    SQL
  end
end
