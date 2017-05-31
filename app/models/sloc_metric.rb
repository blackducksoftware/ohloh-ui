class SlocMetric < SecondBase
  belongs_to :diff
  belongs_to :language
  belongs_to :sloc_set
  belongs_to :analysis_sloc_set, primary_key: :sloc_set_id, foreign_key: :sloc_set_id

  scope :commit_summaries, lambda { |commit, analysis_id|
    return none unless analysis_id
    # summaries = SlocMetric.where(diff_id: diff_ids, sloc_set_id: sloc_set_id).joins(:language)

    SlocMetric.select_summary_attributes.select('languages.nice_name as language_name, languages.name as name')
              .joins(:language)
              .by_commit_id_and_analysis_id(commit, analysis_id)
              .group([:language_id, 'languages.nice_name', 'languages.name'])
  }

  scope :by_commit_id_and_analysis_id, lambda { |commit_id, analysis_id|
    where(diff_id: diff_ids(commit_id, analysis_id), sloc_set_id: sloc_set_ids(analysis_id))
  }

  scope :diff_summaries, lambda { |diff, analysis_id|
    SlocMetric.select_summary_attributes.select('languages.nice_name as language_name')
              .joins(:analysis_sloc_set, :language)
              .where(analysis_sloc_sets: { analysis_id: analysis_id })
              .where(diff_id: diff.id)
              .group([:language_id, 'languages.nice_name'])
  }

  class << self
    def select_summary_attributes
      sloc_metrics_arel = SlocMetric.arel_table
      attributes = [:code_added, :code_removed, :comments_added, :comments_removed, :blanks_added, :blanks_removed]
      select([:language_id,
              attributes.map { |x| sloc_metrics_arel[x].sum.as(x.to_s) }])
        .order('code_added desc, code_removed desc, comments_added desc, comments_removed desc,
                blanks_added desc, blanks_removed desc')
    end

    private

    def diff_ids(commit_id, analysis_id)
      Diff.where(commit_id: commit_id, fyle_id: file_ids(analysis_id)).ids
    end

    def file_ids(analysis_id)
      code_set_ids = SlocSet.where(id: sloc_set_ids(analysis_id)).pluck(:code_set_id)
      tuples = Analysis.find(analysis_id).ignore_tuples
      files = Fyle.where(code_set_id: code_set_ids)
      files = files.where.not(tuples) unless tuples.blank?
      files.ids
    end

    def sloc_set_ids(analysis_id)
      AnalysisSlocSet.where(analysis_id: analysis_id).pluck(:sloc_set_id)
    end
  end
end
