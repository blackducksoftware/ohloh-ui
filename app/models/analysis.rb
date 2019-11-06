# frozen_string_literal: true

# rubocop:disable HasManyOrHasOneDependent
# rubocop:disable InverseOf

class Analysis < ActiveRecord::Base
  include Analysis::Report
  AVG_SALARY = 55_000
  EARLIEST_DATE = Time.utc(1971, 1, 1)
  EARLIEST_DATE_SQL_STRING = "TIMESTAMP '#{EARLIEST_DATE.strftime('%Y-%m-%d')}'"
  ACTIVITY_LEVEL_INDEX_MAP = {
    na: 0, new: 10, inactive: 20, very_low: 30, low: 40, moderate: 50, high: 60, very_high: 70
  }.freeze

  has_one :all_time_summary
  has_one :thirty_day_summary
  has_one :twelve_month_summary
  has_one :previous_twelve_month_summary
  has_many :analysis_summaries
  has_many :analysis_aliases
  has_many :contributor_facts, class_name: 'ContributorFact'
  has_many :analysis_sloc_sets, dependent: :delete_all
  has_many :sloc_sets, through: :analysis_sloc_sets
  has_many :factoids, -> { order('severity DESC') }, dependent: :delete_all
  has_many :activity_facts, dependent: :delete_all

  belongs_to :project
  belongs_to :main_language, class_name: 'Language', foreign_key: :main_language_id

  scope :fresh, -> { where(Analysis.arel_table[:created_at].gt(Time.current - 2.days)) }
  scope :hot, -> { where.not(hotness_score: nil).order(hotness_score: :desc) }
  scope :for_lang, ->(lang_id) { where(main_language_id: lang_id) }

  attr_accessor :ticks

  def twelve_month_summary
    super || NilAnalysisSummary.new
  end

  def previous_twelve_month_summary
    super || NilAnalysisSummary.new
  end

  def activity_level
    return :na if no_analysis? || old_analysis?
    return :new if new_first_commit?
    return :inactive if old_last_commit?
    return :very_low if too_small_team?

    convert_activity_score
  end

  def code_total
    logic_total.to_i + markup_total.to_i + build_total.to_i
  end

  def man_years
    man_years_from_loc(markup_total) + man_years_from_loc(logic_total) + man_years_from_loc(build_total)
  end

  def empty?
    min_month.nil? || code_total.zero?
  end

  def cocomo_value(avg_salary = AVG_SALARY)
    (man_years * avg_salary).to_i
  end

  def man_years_from_loc(loc = 0)
    loc.positive? ? 2.4 * ((loc.to_f / 1000.0)**1.05) / 12.0 : 0
  end

  def ignore_tuples
    [].tap do |tuples|
      analysis_sloc_sets.each do |analysis_sloc_set|
        tuples << analysis_sloc_set.ignore_tuples
      end
    end.compact.join(' AND ')
  end

  def angle
    (Math.atan(hotness_score) * 180 / Math::PI).round(3)
  end

  class << self
    def fresh_and_hot(lang_id = nil)
      fnh = Analysis.fresh.hot
      fnh = fnh.for_lang(lang_id) unless lang_id.nil?
      fnh
    end
  end

  private

  def no_analysis?
    (updated_on.nil? || first_commit_time.nil? || last_commit_time.nil? || headcount.nil? || empty?)
  end

  def old_analysis?
    updated_on < Time.current - 30.days
  end

  def new_first_commit?
    first_commit_time > Time.current - 12.months
  end

  def old_last_commit?
    last_commit_time < Time.current - 24.months
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

# rubocop:enable InverseOf
# rubocop:enable HasManyOrHasOneDependent
