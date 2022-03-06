# frozen_string_literal: true

class CreateMonthlyCommitHistories < ActiveRecord::Migration[4.2]
  def change
    create_table :monthly_commit_histories do |t|
      t.references :analysis, index: true
      t.text :json
    end
  end
end
