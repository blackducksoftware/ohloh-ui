# frozen_string_literal: true

class AddFetchedAtToCodeSets < ActiveRecord::Migration[4.2]
  def change
    add_column :code_sets, :fetched_at, :datetime
  end
end
