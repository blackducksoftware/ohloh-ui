class ChangeAnalysisSummaryCountFields < ActiveRecord::Migration
  def change
    change_column_null(:analysis_summaries, :new_contributors_count, true, 0)
    change_column_null(:analysis_summaries, :affiliated_committers_count, true, 0)
    change_column_null(:analysis_summaries, :affiliated_commits_count, true, 0)
    change_column_null(:analysis_summaries, :outside_committers_count, true, 0)
    change_column_null(:analysis_summaries, :outside_commits_count, true, 0)
  end
end
