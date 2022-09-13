# frozen_string_literal: true

class CreateScanAnalytics < ActiveRecord::Migration[5.2]
  def change
    create_table :scan_analytics do |t|
      t.string :data_type
      t.bigint :analysis_id
      t.bigint :code_set_id
      t.jsonb :data
      t.timestamps
    end
    add_index :scan_analytics, :data, using: :gin
  end
end
