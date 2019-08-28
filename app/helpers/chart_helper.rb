# frozen_string_literal: true

module ChartHelper
  def chart_default_time_span
    "#{7.years.ago.strftime('%b %Y')} - Present"
  end

  def chart_watermark(x_axis: '50%', y_axis: '50%')
    style = { 'background-repeat' => 'no-repeat', 'background-position' => "#{x_axis} #{y_axis}" }
    { 'chart' => { 'backgroundColor' => 'transparent', 'style' => style } }
  end
end
