class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :rating
      t.integer :more_info
      t.string :uuid
      t.string :project_name

      t.timestamps null: false
    end
  end
end
