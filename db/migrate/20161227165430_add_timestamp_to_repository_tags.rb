# frozen_string_literal: true

class AddTimestampToRepositoryTags < ActiveRecord::Migration[4.2]
  def change
    add_column :repository_tags, :timestamp, :datetime
  end
end
