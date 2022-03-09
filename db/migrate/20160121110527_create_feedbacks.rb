# frozen_string_literal: true

class CreateFeedbacks < ActiveRecord::Migration[4.2]
  def change
    create_table :feedbacks do |t|
      t.integer :rating
      t.integer :more_info
      t.string :uuid
      t.inet :ip_address
      t.integer :project_id
      t.timestamps null: false
    end
  end
end
