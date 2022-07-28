# frozen_string_literal: true

class CreateReviewedNonSpammer < ActiveRecord::Migration[5.2]
  def up
    create_table :reviewed_non_spammers do |t|
      t.references :account, foreign_key: true, unique: true
      t.timestamps
    end

    execute <<-SQL.squish
      CREATE VIEW potential_spammers AS
      SELECT ac.id
      FROM oh.markups
      JOIN oh.accounts AS ac ON ac.about_markup_id = markups.id
      WHERE raw ~ 'http' AND ac.level = 0
         AND ac.id NOT IN (SELECT account_id FROM oh.reviewed_non_spammers);
    SQL
  end

  def down
    execute <<-SQL.squish
      DROP VIEW IF EXISTS potential_spammers
    SQL
    drop_table :reviewed_non_spammers
  end
end
