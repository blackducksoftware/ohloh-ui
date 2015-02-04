module ChartHelper
  def chart_default_time_span
    "#{7.years.ago.strftime('%b %Y')} - Present"
  end
end
