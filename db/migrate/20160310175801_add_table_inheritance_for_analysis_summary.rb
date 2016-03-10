class AddTableInheritanceForAnalysisSummary < ActiveRecord::Migration
  def up
    %i(all_time_summaries previous_twelve_month_summaries twelve_month_summaries thirty_day_summaries).each do |table_name|
      create_table table_name do |t|
        t.integer :analysis_id, null: false
        t.integer :files_modified
        t.integer :lines_added
        t.integer :lines_removed
        t.text :type, null: false
        t.datetime :created_at
        t.text :recent_contributors, default: []
        t.integer :new_contributors_count
        t.integer :affiliated_committers_count
        t.integer :affiliated_commits_count
        t.integer :outside_committers_count
        t.integer :outside_commits_count
      end

      add_foreign_key table_name, :analyses
      add_index table_name, :analysis_id

      execute "ALTER TABLE #{table_name} INHERIT analysis_summaries"
    end
  end

  def down
    %w(all_time_summaries previous_twelve_month_summaries twelve_month_summaries thirty_day_summaries).each do |table_name|
      execute <<-SQL
        DROP TABLE #{table_name}
      SQL
    end
  end
end
