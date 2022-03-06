# frozen_string_literal: true

class DropNamedCommitsView < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL.squish
      DROP VIEW IF EXISTS named_commits;
    SQL
  end

  def down
    execute <<-SQL.squish
      CREATE VIEW named_commits as SELECT commits.id,
      commits.id AS commit_id,
      analysis_sloc_sets.analysis_id,
      projects.id AS project_id,
      analysis_sloc_sets.sloc_set_id,
      sloc_sets.code_set_id,
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
      JOIN projects ON analysis_sloc_sets.analysis_id = projects.best_analysis_id
      JOIN sloc_sets ON sloc_sets.id = analysis_sloc_sets.sloc_set_id
      JOIN commits ON commits.code_set_id = sloc_sets.code_set_id AND commits."position" <= analysis_sloc_sets.as_of
      JOIN analysis_aliases ON analysis_aliases.analysis_id = analysis_sloc_sets.analysis_id AND analysis_aliases.commit_name_id = commits.name_id
      LEFT JOIN positions ON positions.project_id = projects.id AND positions.name_id = analysis_aliases.preferred_name_id;
    SQL
  end
end
