class Commit < ActiveRecord::Base
  belongs_to :code_set
  belongs_to :name
  has_many :fyle, primary_key: :code_set_id, foreign_key: :code_set_id
  has_many :diffs, dependent: :destroy
  has_many :analysis_aliases, foreign_key: :commit_name_id, primary_key: :name_id

  include EmailObfuscation

  filterable_by ['comment']

  scope :for_project, lambda { |project|
    joins(code_set: { code_location: { enlistments: :project } })
      .where(enlistments: { deleted: false })
      .where(projects: { id: project.id })
  }

  scope :for_contributor_fact, lambda { |contributor_fact|
    commit_name_ids = AnalysisAlias.commit_name_ids(contributor_fact)
    by_analysis(contributor_fact.analysis).where(name_id: commit_name_ids)
  }

  scope :by_analysis, lambda { |analysis|
    analysis_sloc_sets = analysis.analysis_sloc_sets
    query = analysis_sloc_sets.collect do |analysis_sloc_set|
      code_set_id = analysis_sloc_set.sloc_set.code_set_id
      "(commits.code_set_id = #{code_set_id} and commits.position <= #{analysis_sloc_set.as_of.to_i})"
    end.join(' or ')
    where(query)
  }
  scope :last_30_days, ->(logged_at) { where('commits.time > ?', logged_at - 30.days) }
  scope :last_year, ->(logged_at) { where('commits.time > ?', logged_at - 12.months) }
  scope :within_timespan, lambda { |time_span, logged_at|
    return unless logged_at && TIME_SPANS.keys.include?(time_span)
    send(TIME_SPANS[time_span], logged_at)
  }

  # def lines_added_and_removed(analysis_id)
  #   summaries = get_summaries(analysis_id)

  #   lines_added = lines_removed = 0
  #   summaries.each do |summary|
  #     lines_added += summary.code_added + summary.comments_added + summary.blanks_added
  #     lines_removed += summary.code_removed + summary.comments_removed + summary.blanks_removed
  #   end
  #   [lines_added, lines_removed]
  # end

  def lines_added_and_removed(sloc_set_ids, analysis_id)
    summaries = get_summaries(sloc_set_ids, analysis_id)
    
    lines_added = lines_removed = 0
    
    summaries.each do |summary|
      # byebug
      lines_added += summary[0] + summary[1] + summary[2]
      lines_removed += summary[3] + summary[4] + summary[5]
    end
    # byebug
    [lines_added, lines_removed]
  end

  def nice_id(params = {})
    case code_set.repository
    when SvnSyncRepository
      "r#{sha1}"
    when GitRepository
      params[:short] ? sha1.to_s.truncate(8, omission: '') : sha1
    when HgRepository
      params[:short] ? sha1.to_s.truncate(12, omission: '') : sha1
    end
  end

  private

  # def get_summaries(analysis_id)
  #   SlocMetric.by_commit_id_and_analysis_id(id, analysis_id)
  # end

  def get_summaries(sloc_set_ids, analysis_id)
    SlocMetric.by_commit_id_sloc_set_ids_and_analysis_id(id, sloc_set_ids, analysis_id).pluck(:code_added, :comments_added, :blanks_added, :code_removed, :comments_removed, :blanks_removed)
  end
end
