class Clump < ActiveRecord::Base
  belongs_to :code_set

  DIRECTORY = '/var/spool/clumps'

  def scm_class
    OhlohScm::Adapters::GitAdapter
  end

  def path
    ClumpDirectory.path(code_set_id)
  end

  def branch_name
    code_set.repository.branch_name
  end

  def scm
    @scm ||= scm_class.new(url: path, branch_name: branch_name).normalize
  end

  def open
    yield self
    scm.clean_up_disk if scm.respond_to?(:clean_up_disk)
  end

  def update_fetched_at(newtime)
    update(fetched_at: newtime) unless fetched_at && fetched_at > newtime
  end

  class << self
    def oldest_fetchable(limit = 1)
      conditions = "COALESCE(code_sets.logged_at, '1970-01-01') + repositories.update_interval * INTERVAL '1 second'"\
                   " <= NOW() AT TIME ZONE 'utc'"\
                   " AND COALESCE(analyses.logged_at, '1970-01-01') >="\
                   " COALESCE(code_sets.logged_at, '1970-01-01') - INTERVAL '1 second'"
      joins(code_set: { best_repository: { enlistments: { project: :best_analysis } } })
        .where(projects: { deleted: false })
        .where(conditions)
        .where(Job.where('status != 5 AND jobs.repository_id = repositories.id').exists.not)
        .order('code_sets.logged_at nulls first')
        .limit(limit)
    end
  end
end
