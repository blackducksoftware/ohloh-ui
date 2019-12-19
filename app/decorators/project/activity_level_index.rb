# frozen_string_literal: true

class Project::ActivityLevelIndex
  INACTIVE_INDEX = 20
  ACTIVITY_LEVEL_INDEX = { 10 => :new, 20 => :inactive, 30 => :very_low, 40 => :low,
                           50 => :moderate, 60 => :high, 70 => :very_high }.freeze
  ACTIVITY_LEVEL_COLOR = { new: '#F27A3F', inactive: '#2369C8', very_low: '#0A1929', low: '#75B134',
                           moderate: '#81000A', high: '#149FC0', very_high: '#391B59' }.freeze

  def initialize(level_index, count, total_count)
    @level_index = level_index
    @total_count = total_count
    @count = count
  end

  def demographic_chart_data
    { name: titleized_name, color: color, y: percentage, selected: selected, sliced: sliced }
  end

  private

  def name
    @name ||= ACTIVITY_LEVEL_INDEX[@level_index]
  end

  def titleized_name
    name.to_s.titleize
  end

  def color
    ACTIVITY_LEVEL_COLOR[name]
  end

  def percentage
    (@count.fdiv(@total_count) * 100).round(1)
  end

  def sliced
    @level_index == INACTIVE_INDEX
  end

  def selected
    name == ACTIVITY_LEVEL_INDEX[INACTIVE_INDEX]
  end
end
