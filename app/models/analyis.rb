class Analysis < ActiveRecord::Base
  has_many :analysis_summaries
  has_many :analysis_aliases

  scope :fresh, -> { where(Analysis.arel_table[:created_at].gt(Time.now - 2.days)) }
  scope :hot, -> { where.not(hotness_score: nil).order(hotness_score: :desc) }
  scope :for_lang, ->(lang_id) { where(main_language_id: lang_id) }
end
