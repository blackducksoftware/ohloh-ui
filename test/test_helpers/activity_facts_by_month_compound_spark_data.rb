# frozen_string_literal: true

require 'ostruct'

class ActivityFactsByMonthCompounSparkData
  COMMITS = [5, 42, 7, 20, 19, 18, 24, 16, 39, 0, 20, 65, 22, 24, 23, 30, 54, 6, 9].freeze

  def initialize
    @first_date = Time.parse('2004-04-01 00:00:00 UTC').in_time_zone
    @commits = [0] * 101 + COMMITS + [0] * 13
  end

  def data
    array = (0..132).to_a.map do |index|
      { 'month' => @first_date + index.months, 'commits' => @commits[index] }
    end

    array.map do |month_data|
      OpenStruct.new(month_data)
    end
  end
end
