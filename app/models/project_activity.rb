class ProjectActivity
  NEW      = :new
  NA       = :na
  INACTIVE = :inactive
  VERY_LOW  = :very_low
  LOW      = :low
  MODERATE = :moderate
  HIGH     = :high
  VERY_HIGH = :very_high

  SIZES = [:fifteen, :twenty, :twentyfive, :thirtyfive]

  LEVEL_INDEX_MAP = {
    NA => 0, NEW => 10, INACTIVE => 20, VERY_LOW => 30, LOW => 40, MODERATE => 50, HIGH => 60, VERY_HIGH => 70
  }

  LEVEL_COLOR_MAP = {
    NEW => '#F27A3F', INACTIVE => '#2369C8', VERY_LOW => '#0A1929', LOW => '#75B134', MODERATE => '#81000A',
    HIGH => '#149FC0', VERY_HIGH => '#391B59'
  }

  LEVEL_STRING_MAP = {
    NA => 'na', NEW => 'new', INACTIVE => 'i', VERY_LOW => 'vl', LOW => 'l', MODERATE => 'm',
    HIGH => 'h', VERY_HIGH => 'vh'
  }

  MULTIPLIER = [100000, 70711, 50000, 35355, 25000, 17678, 12500, 8839, 6250, 4419, 3125, 2210]

  delegate :first_commit_time, :updated_on, :last_commit_time, :headcount, :project, to: :@analysis

  def initialize(analysis = NilAnalysis.new)
    @analysis = analysis
  end

  def generate_score
    return if no_analysis?
    @contributor_history = contributor_history(search_period).reverse
    @commit_history = commit_history(search_period).reverse
    calculate_commits_and_contributors_score
  end

  #NOTE: Replcases activity_level
  def level
    case
    when no_analysis?, @analysis.nil?, old_analysis?
      NA
    when new_first_commit?
      NEW
    when old_last_commit?
      INACTIVE
    when too_small_team?
      VERY_LOW
    else
      convert_score
    end
  end

  #NOTE: Replaces css_class
  def level_css(size)
    fail ArgumentError, "Project cannot be blank" if project.blank?
    fail ArgumentError, "Invalid size parameter" unless SIZES.include?(size)
    "#{size.to_s}_project_activity_level_#{LEVEL_STRING_MAP[level]}"
  end

  #NOTE: Replaces activity_level_text
  def level_text(append_activity)
    case level
    when NA then (append_activity ? 'Activity ' : '') + 'Not Available'
    when NEW then "New Project"
    when INACTIVE then "Inactive"
    else
      level.to_s.titleize + (append_activity ? ' Activity' : '')
    end
  end

  #NOTE: Replaces activity_level_index
  def level_index
    LEVEL_INDEX_MAP[level]
  end

  #NOTE: Replaces activity_level_text_class
  def level_text_class(image_size)
    "#{image_size.to_s}_project_activity_text"
  end

  class << self
    #NOTE: Replaces get_activity_name
    def find_name_by_index(level_index)
      @inverted_level_index_map ||= LEVEL_INDEX_MAP.invert
      @inverted_level_index_map[level_index].to_s
    end

    #NOTE: Replaces color
    def find_level_color_by_name(name)
      LEVEL_COLOR_MAP[name.to_sym]
    end
  end

  private

  def no_analysis?
    updated_on.nil? || first_commit_time.nil? || last_commit_time.nil? || headcount.nil?
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

  def convert_score
    case generate_score
    when 0..204_933
      VERY_LOW
    when 204_934..875_012
      LOW
    when 875_013..4_686_315
      MODERATE
    when 4_686_316..13_305_163
      HIGH
    else
      VERY_HIGH
    end
  end

  def calculate_commits_and_contributors_score
    scores = { 'commits' => 0, "contributors" => 0 }
    @contributor_history.each_with_object({}) do |scores, (v, i)|
      scores['contributor'] += v['contributors'].to_i * MULTIPLIER[i]
    end
    @commit_history.each_with_object({}) do |scores, (v, i)|
      scores['commit'] += v['commits'].to_i * MULTIPLIER[i]
    end

    ((scores['contributor'].to_f * 2/3) + (scores['commit'].to_f * 1/3)).round
  end

  def search_period
    { start_date: Date.today.prev_year, end_date: Date.today.prev_month }
  end
end
