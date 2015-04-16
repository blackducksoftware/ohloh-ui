class SlocMetric < ActiveRecord::Base
  belongs_to :diff
  belongs_to :language
  has_many :analysis_sloc_sets, primary_key: :sloc_set_id, foreign_key: :sloc_set_id

  scope :commit_summaries, lambda { |commit, analysis_id|
    return none unless analysis_id

    SlocMetric.select_summary_attributes.select('languages.nice_name as language_name, languages.name as name')
      .joins([[diff: [commit: :fyle]], :language])
      .where(diffs: { commit_id: commit.id })
      .where('diffs.fyle_id = fyles.id')
      .where(sloc_set_id: AnalysisSlocSet.for_analysis(analysis_id).select(:sloc_set_id))
      .ignored_files(analysis_id)
      .group([:language_id, 'languages.nice_name', 'languages.name'])
  }

  scope :diff_summaries, lambda { |diff, analysis_id|
    SlocMetric.select_summary_attributes.select('languages.nice_name as language_name')
      .joins(:analysis_sloc_sets, :language)
      .where(analysis_sloc_sets: { analysis_id: analysis_id })
      .where(diff_id: diff.id)
      .group([:language_id, 'languages.nice_name'])
  }

  class << self
    def ignored_files(analysis_id)
      tuples = Analysis.find(analysis_id).ignore_tuples
      tuples.blank? ? where(nil) : where.not(tuples)
    end

    # rubocop:disable Metrics/AbcSize
    def select_summary_attributes
      sloc_metrics_arel = SlocMetric.arel_table
      select([:language_id,
              sloc_metrics_arel[:code_added].sum.as('code_added'),
              sloc_metrics_arel[:code_removed].sum.as('code_removed'),
              sloc_metrics_arel[:comments_added].sum.as('comments_added'),
              sloc_metrics_arel[:comments_removed].sum.as('comments_removed'),
              sloc_metrics_arel[:blanks_added].sum.as('blanks_added'),
              sloc_metrics_arel[:blanks_removed].sum.as('blanks_removed')])
        .order('code_added desc, code_removed desc, comments_added desc, comments_removed desc,
                blanks_added desc, blanks_removed desc')
    end
  end
end
