require 'ostruct'

class ActivityFactsByMonthData
  COMMITS = [5, 42, 7, 20, 19, 18, 24, 16, 39, 0, 20, 65, 22, 24, 23, 30, 54, 6, 9].freeze

  def initialize(with_intitial_value = false)
    @with_intitial_value = with_intitial_value
    @first_date = Time.parse('2010-04-01 00:00:00 UTC').in_time_zone
    @commits = commits_for_first_29_months + COMMITS + [0] * 13
  end

  def commits_for_first_29_months
    @with_intitial_value == false ? [0] * 29 : [1] * 29
  end

  def data
    array = (0..60).to_a.map do |index|
      { 'month' => @first_date + index.months, 'commits' => @commits[index] }
    end

    array.map do |month_data|
      OpenStruct.new(month_data)
    end
  end
end
