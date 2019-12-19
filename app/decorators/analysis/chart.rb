# frozen_string_literal: true

class Analysis::Chart
  include ChartHelper
  include ActionView::Helpers::AssetUrlHelper

  Y_AXIS_TICKS = [1, 3, 5, 10].freeze

  delegate :min_month, :oldest_code_set_time, :created_at, to: :@analysis

  private

  def series_and_range_data(default_options)
    series_data_map.each_with_index do |data, index|
      default_options['series'][index].merge!('data' => data)
    end
    default_options.merge range_selector
  end

  def first_ticks
    series.first.ticks
  end

  def min_month_as_ticks
    min_month.to_time(:utc).to_i * 1000
  end

  def range_selector
    buttons = first_ticks.present? ? y_axis_ticks : []
    buttons.push(type: 'all', text: 'All')
    { 'rangeSelector' => { 'inputEnabled' => false, 'buttons' => buttons, 'selected' => (buttons.size - 1) } }
  end

  def latest_date
    @latest_date ||= (oldest_code_set_time || created_at).at_beginning_of_month
  end

  def y_axis_ticks
    Y_AXIS_TICKS.each_with_object([]) do |y_axis, array|
      array << { type: 'year', count: y_axis, text: "#{y_axis}yr" } if first_ticks < y_axis.years.ago.to_i * 1000
    end
  end

  def series
    @series ||= months_to_ticks.drop_while { |date| date.ticks < min_month_as_ticks }
  end

  def months_to_ticks
    @history.each { |date| date.ticks = (date.month.utc.to_i * 1000) }
  end
end
