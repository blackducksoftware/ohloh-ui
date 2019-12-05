# frozen_string_literal: true

class SlocMetric < FisBase
  belongs_to :diff
  belongs_to :language
  belongs_to :sloc_set
  belongs_to :analysis_sloc_set, primary_key: :sloc_set_id, foreign_key: :sloc_set_id

  # FDW: joins several FDW tables(sloc_metrics, analysis_sloc_sets, diffs, commits, fyles) with non FDW table languages.
  scope :commit_summaries, lambda { |commit, analysis_id|
    return none unless analysis_id

    SlocMetric.select_summary_attributes
              .select('languages.nice_name as language_name, languages.name as name')
              .joins([[diff: [commit: :fyle]], :language])
              .where(diffs: { commit_id: commit })
              .where('diffs.fyle_id = fyles.id')
              .where(sloc_set_id: AnalysisSlocSet.for_analysis(analysis_id).select(:sloc_set_id))
              .ignored_files(analysis_id)
              .group([:language_id, 'languages.nice_name', 'languages.name'])
  }

  # FDW: joins several FDW tables(sloc_metrics, analysis_sloc_sets) with non FDW table languages.
  scope :diff_summaries, lambda { |diff, analysis_id|
    SlocMetric.select_summary_attributes.select('languages.nice_name as language_name')
              .joins(:analysis_sloc_set, :language)
              .where(analysis_sloc_sets: { analysis_id: analysis_id })
              .where(diff_id: diff.id)
              .group([:language_id, 'languages.nice_name'])
  }

  class << self
    def ignored_files(analysis_id)
      tuples = Analysis.find(analysis_id).ignore_tuples
      tuples.blank? ? where(nil) : where.not(tuples)
    end

    def select_summary_attributes
      sloc_metrics_arel = SlocMetric.arel_table
      attributes = %i[code_added code_removed comments_added comments_removed blanks_added blanks_removed]
      select([:language_id,
              attributes.map { |x| sloc_metrics_arel[x].sum.as(x.to_s) }])
        .order('code_added desc, code_removed desc, comments_added desc, comments_removed desc,
                blanks_added desc, blanks_removed desc')
    end
  end
end
