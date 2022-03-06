# frozen_string_literal: true

class ChangeScoreDataType < ActiveRecord::Migration[4.2]
  def change
    change_column :analyses, :activity_score, :bigint
  end
end
