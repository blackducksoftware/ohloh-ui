# frozen_string_literal: true

class AssociateProjectBadgeToEnlistment < ActiveRecord::Migration
  def change
    remove_column :project_badges, :project_id, :integer
    remove_column :project_badges, :repository_id, :integer
    add_reference :project_badges, :enlistment, index: true, foreign_key: true
  end
end
