class ChangeColumnTypeInAnalysesSummaries < ActiveRecord::Migration[5.2]
  def change
    change_column :analysis_summaries, :lines_added, :bigint
  end
end
