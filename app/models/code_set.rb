class CodeSet < ActiveRecord::Base
  belongs_to :repository
  belongs_to :best_sloc_set, foreign_key: :best_sloc_set_id, class_name: SlocSet
  has_many :commits, -> { order(:position) }, dependent: :destroy
  has_many :fyles, dependent: :delete_all
  has_many :sloc_sets, dependent: :destroy
  has_many :clumps
  has_many :jobs

  def ignore_prefixes(project)
    enlistment = project.enlistments.find_by(repository_id: repository_id)
    return CodeSet.none if enlistment.nil?
    analysis_sloc_set = enlistment.analysis_sloc_set
    analysis_sloc_set.nil? ? CodeSet.none : analysis_sloc_set.ignore_prefixes
  end

  # impmentation that should be used when clumps are removed
  # def reimport
  #   ImportJob.create!(code_set: CodeSet.create!(repository_id: repository_id))
  # end

  # AFter clumps are remvoed, delete from here ....
  def reimport
    old_clump.slave.run_local_or_remote("mv #{old_clump.path} #{new_clump.path}")
    return ImportJob.create(code_set: new_code_set) if old_clump.delete
  end

  private

  def old_clump
    @old_clump ||= clumps.sort { |a, b| a.updated_at <=> b.updated_at }.last
  end

  def new_clump
    @new_clump ||= old_clump.class.create(code_set: new_code_set, slave: old_clump.slave)
  end

  def new_code_set
    @new_code_set ||= CodeSet.create!(repository_id: repository_id)
  end
  # .... to here
end
