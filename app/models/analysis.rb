class Analysis < ActiveRecord::Base
  belongs_to :project
  has_many :analysis_summaries
  has_many :analysis_aliases
  belongs_to :main_language, class_name: 'Language', foreign_key: :main_language_id

  scope :fresh, -> { where(Analysis.arel_table[:created_at].gt(Time.now - 2.days)) }
  scope :hot, -> { where.not(hotness_score: nil).order(hotness_score: :desc) }
  scope :for_lang, ->(lang_id) { where(main_language_id: lang_id) }

  class << self
    def fresh_and_hot(lang_id = nil)
      fnh = Analysis.fresh.hot
      fnh = fnh.for_lang(lang_id) unless lang_id.nil?
      fnh
    end
  end
end
