class Analysis < ActiveRecord::Base
  belongs_to :project
  has_one :thirty_day_summary
  has_one :twelve_month_summary
  has_one :previous_twelve_month_summary
  has_many :analysis_summaries
  has_many :analysis_aliases
  belongs_to :main_language, class_name: 'Language', foreign_key: :main_language_id

  scope :fresh, -> { where(Analysis.arel_table[:created_at].gt(Time.now - 2.days)) }
  scope :hot, -> { where.not(hotness_score: nil).order(hotness_score: :desc) }
  scope :for_lang, ->(lang_id) { where(main_language_id: lang_id) }

  alias_method :original_twelve_month_summary, :twelve_month_summary
  alias_method :original_previous_twelve_month_summary, :previous_twelve_month_summary

  def twelve_month_summary
    original_twelve_month_summary || NilTwelveMonthSummary.new
  end

  def previous_twelve_month_summary
    original_previous_twelve_month_summary || NilPreviousTwelveMonthSummary.new
  end

  def activity_level
    return :na if no_analysis? || old_analysis?
    return :new if new_first_commit?
    return :inactive if old_last_commit?
    return :very_low if too_small_team?
    convert_activity_score
  end

  class << self
    def fresh_and_hot(lang_id = nil)
      fnh = Analysis.fresh.hot
      fnh = fnh.for_lang(lang_id) unless lang_id.nil?
      fnh
    end
  end

  private

  def code_total
    logic_total.to_i + markup_total.to_i + build_total.to_i
  end

  def empty?
    min_month.nil? || (code_total == 0)
  end

  def no_analysis?
    (updated_on.nil? || first_commit_time.nil? || last_commit_time.nil? || headcount.nil? || empty?)
  end

  def old_analysis?
    updated_on < Time.now - 30.days
  end

  def new_first_commit?
    first_commit_time > Time.now - 12.months
  end

  def old_last_commit?
    last_commit_time < Time.now - 24.months
  end

  def too_small_team?
    headcount == 1
  end

  def convert_activity_score
    case activity_score
    when 0..204_933            then :very_low
    when 204_934..875_012      then :low
    when 875_013..4_686_315    then :moderate
    when 4_686_316..13_305_163 then :high
    else :very_high
    end
  end
end
