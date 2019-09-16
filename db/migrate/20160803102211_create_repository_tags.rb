# frozen_string_literal: true

class CreateRepositoryTags < ActiveRecord::Migration
  def change
    create_table :repository_tags do |t|
      t.references :repository, index: true, foreign_key: true
      t.text :name
      t.text :commit_sha1
      t.text :message
    end
  end
end
