module ChartHelper
  def chart_default_time_span
    "#{7.years.ago.strftime('%b %Y')} - Present"
  end

  def chart_watermark(x: '50%', y: '50%')
    style = { 'background-repeat' => 'no-repeat', 'background-position' => "#{x} #{y}" }
    { 'chart' => { 'backgroundColor' => 'transparent', 'style' => style } }
  end
end
