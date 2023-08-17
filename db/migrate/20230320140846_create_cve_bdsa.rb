# frozen_string_literal: true

class CreateCveBdsa < ActiveRecord::Migration[5.2]
  def change
    create_table :cve_bdsa do |t|
      t.string :cve_id
      t.string :bdsa_id
    end
  end
end
