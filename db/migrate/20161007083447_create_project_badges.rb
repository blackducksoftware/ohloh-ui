class CreateProjectBadges < ActiveRecord::Migration
  def change
    create_table :project_badges do |t|
      t.references :repository, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
      t.string :identifier
      t.string :type
      t.integer :status, default: 1
      t.timestamps null: false
    end
  end
end
