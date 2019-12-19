# frozen_string_literal: true

class AddRepositoryIdToCodeLocationEvents < ActiveRecord::Migration
  def change
    add_reference :code_location_events, :repository, index: true, foreign_key: true
  end
end
