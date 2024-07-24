# frozen_string_literal: true

class AddUnaccentExtension < ActiveRecord::Migration[5.2]
  def up
    execute 'create extension unaccent;'
  end

  def down
    execute 'drop extension unaccent;'
  end
end
