# frozen_string_literal: true

class ChangeScoreDataType < ActiveRecord::Migration
  def change
    change_column :analyses, :activity_score, :bigint
  end
end
