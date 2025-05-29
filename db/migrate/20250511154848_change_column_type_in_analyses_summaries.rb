# frozen_string_literal: true

class ChangeColumnTypeInAnalysesSummaries < ActiveRecord::Migration[5.2]
  def up
    change_column :analysis_summaries, :lines_added, :bigint
  end

  def down
    change_column :analysis_summaries, :lines_added, :integer
  end
end
