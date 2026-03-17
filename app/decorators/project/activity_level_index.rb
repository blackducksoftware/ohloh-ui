# frozen_string_literal: true

class Project::ActivityLevelIndex
  INACTIVE_INDEX = 20
  ACTIVITY_LEVEL_INDEX = { 10 => :new, 20 => :inactive, 30 => :very_low, 40 => :low,
                           50 => :moderate, 60 => :high, 70 => :very_high }.freeze

  def initialize(level_index, count, total_count)
    @level_index = level_index
    @total_count = total_count
    @count = count
  end

  def demographic_chart_data
    { name: titleized_name, y: percentage, selected: selected, sliced: sliced }
  end

  private

  def name
    @name ||= ACTIVITY_LEVEL_INDEX[@level_index]
  end

  def titleized_name
    name.to_s.titleize
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
