# frozen_string_literal: true

class DropDomainBlacklistTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :domain_blacklists
  end

  def down
    create_table :domain_blacklists do |t|
      t.string :domain
      t.timestamps
    end
  end
end
