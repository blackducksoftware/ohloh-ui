class Commit < FisBase
  belongs_to :code_set
  belongs_to :name
  has_many :fyle, primary_key: :code_set_id, foreign_key: :code_set_id
  has_many :diffs, dependent: :destroy
  has_many :analysis_aliases, foreign_key: :commit_name_id, primary_key: :name_id

  include EmailObfuscation

  filterable_by ['comment']

  scope :for_contributor_fact, lambda { |contributor_fact|
    commit_name_ids = AnalysisAlias.commit_name_ids(contributor_fact)
    by_analysis(contributor_fact.analysis).where(name_id: commit_name_ids)
  }

  scope :by_analysis, lambda { |analysis|
    joins(code_set: [sloc_sets: :analysis_sloc_sets])
      .joins('and commits.position <= analysis_sloc_sets.as_of')
      .where(analysis_sloc_sets: { analysis_id: analysis.id })
  }

  scope :last_30_days, ->(logged_at) { where('commits.time > ?', logged_at - 30.days) }
  scope :last_year, ->(logged_at) { where('commits.time > ?', logged_at - 12.months) }
  scope :within_timespan, lambda { |time_span, logged_at|
    return unless logged_at && TIME_SPANS.keys.include?(time_span)
    send(TIME_SPANS[time_span], logged_at)
  }

  def lines_added_and_removed(analysis_id)
    summaries = SlocMetric.commit_summaries(self, analysis_id)

    lines_added = lines_removed = 0
    summaries.each do |summary|
      lines_added += summary.code_added + summary.comments_added + summary.blanks_added
      lines_removed += summary.code_removed + summary.comments_removed + summary.blanks_removed
    end
    [lines_added, lines_removed]
  end

  def nice_id(params = {})
    case code_set.code_location.scm_type.to_s
    when /svn/
      "r#{sha1}"
    when 'git'
      git_sha1(params[:short])
    when 'hg'
      hg_sha1(params[:short])
    end
  end

  class << self
    def for_project(project)
      joins(:code_set).joins('join enlistments on enlistments.code_location_id = code_sets.code_location_id
                              join projects on project_id = projects.id')
                      .where(enlistments: { deleted: false })
                      .where(projects: { id: project.id })
    end
  end

  private

  def hg_sha1(short)
    short ? sha1.to_s.truncate(12, omission: '') : sha1
  end

  def git_sha1(short)
    short ? sha1.to_s.truncate(8, omission: '') : sha1
  end
end
