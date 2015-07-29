class CodeSet < ActiveRecord::Base
  belongs_to :repository
  belongs_to :best_repository, foreign_key: :best_code_set_id, class_name: CodeSet
  belongs_to :best_sloc_set, foreign_key: :best_sloc_set_id, class_name: SlocSet
  has_many :commits, -> { order(:position) }, dependent: :destroy
  has_one :clump
  has_many :fyles, dependent: :delete_all
  has_many :sloc_sets, dependent: :destroy

  def ignore_prefixes(project)
    enlistment = project.enlistments.find_by(repository_id: repository_id)
    return CodeSet.none if enlistment.nil?
    analysis_sloc_set = enlistment.analysis_sloc_set
    analysis_sloc_set.nil? ? CodeSet.none : analysis_sloc_set.ignore_prefixes
  end

  def fetch(&block)
    saved_max_steps = nil
    yield(0, 1) if block_given?

    find_or_create_clump
    scm_pull(&block)

    yield(saved_max_steps || 1, saved_max_steps || 1) if block_given?

    Time.now.utc
  end

  def import(&block)
    find_or_create_clump
    CodeSet::Import.new(self).perform(&block)
  end

  def find_or_create_clump
    clump || create_clump(type: repository.clump_class.name)
  end

  private

  def scm_pull
    clump.scm.pull(repository.source_scm) do |step, inner_max_step|
      # As each rev completes, do some housekeeping and progress notification
      clump.update_fetched_at(Time.now.utc) if step > 0

      saved_max_steps = [saved_max_steps || 0, inner_max_step + 1].max
      yield(step, saved_max_steps) if block_given?
    end
  end
end
