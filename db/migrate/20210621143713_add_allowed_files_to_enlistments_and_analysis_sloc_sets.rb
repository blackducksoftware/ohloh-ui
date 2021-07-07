# frozen_string_literal: true

class AddAllowedFilesToEnlistmentsAndAnalysisSlocSets < ActiveRecord::Migration
  def change
    add_column :analysis_sloc_sets, :allowed_fyles, :text
    add_column :analysis_sloc_sets, :allowed_fyle_count, :integer
    add_column :enlistments, :allowed_fyles, :text
  end
end
