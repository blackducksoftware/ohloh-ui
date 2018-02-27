class CodeSet < FisBase
  belongs_to :best_sloc_set, foreign_key: :best_sloc_set_id, class_name: SlocSet
  has_many :commits, -> { order(:position) }, dependent: :destroy
  has_many :fyles, dependent: :delete_all
  has_many :sloc_sets, dependent: :destroy
  has_many :clumps
  has_many :jobs

  attr_writer :code_location

  def code_location
    @code_location ||= CodeLocation.find(code_location_id)
  end

  def ignore_prefixes(project)
    enlistment = project.enlistments.find_by(code_location_id: code_location_id)
    return CodeSet.none if enlistment.nil?
    analysis_sloc_set = enlistment.analysis_sloc_set
    analysis_sloc_set.nil? ? CodeSet.none : analysis_sloc_set.ignore_prefixes
  end

  # Implementation that should be used when clumps are removed
  # def reimport
  #   ImportJob.create!(code_set: CodeSet.create!(repository_id: repository_id))
  # end

  # After clumps are removed, delete from here ....
  def reimport
    old_clump.slave.run_local_or_remote("mv #{old_clump.path} #{new_clump.path}")
    return ImportJob.create(code_set: new_code_set) if old_clump.delete
  end

  class << self
    # TODO: Remove this direct code_location table access once we stop using this method in activeadmin.
    def oldest_code_set
      joins('join code_locations on best_code_set_id = code_sets.id
             join enlistments on enlistments.code_location_id = code_locations.id
             join projects on enlistments.project_id = projects.id
             join analyses on best_analysis_id = analyses.id')
        .where(projects: { deleted: false })
        .where(code_set_conditions)
        .where(Job.where("status != #{Job::STATUS_COMPLETED} AND jobs.code_location_id = code_locations.id").exists.not)
        .order('code_sets.logged_at nulls first')
        .limit(1)
    end

    def code_set_conditions
      "COALESCE(code_sets.logged_at, '1970-01-01') + "\
      "code_locations.update_interval * INTERVAL '1 second' <= NOW() AT TIME ZONE 'utc'"\
      " AND COALESCE(analyses.oldest_code_set_time, '1970-01-01') >="\
      " COALESCE(code_sets.logged_at, '1970-01-01') - INTERVAL '1 second'"
    end
  end

  private

  def old_clump
    @old_clump ||= clumps.sort_by(&:updated_at).last
  end

  def new_clump
    @new_clump ||= old_clump.class.create(code_set: new_code_set, slave: old_clump.slave)
  end

  def new_code_set
    @new_code_set ||= CodeSet.create!(code_location_id: code_location_id)
  end
  # .... to here
end
