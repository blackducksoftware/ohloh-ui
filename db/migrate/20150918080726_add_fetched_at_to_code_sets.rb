class AddFetchedAtToCodeSets < ActiveRecord::Migration
  def change
    add_column :code_sets, :fetched_at, :datetime
  end
end
