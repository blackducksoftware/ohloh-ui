module ChartHelper
  def chart_default_time_span
    "#{7.years.ago.strftime('%b %Y')} - Present"
  end

  def chart_watermark(image, x: '50%', y: '50%')
    image_url = image_path("charts/#{image}.png")
    style = { 'background-image' => "url('#{image_url}')", 'background-repeat' => 'no-repeat',
              'background-position' => "#{x} #{y}" }
    { chart: { backgroundColor: 'transparent', style: style } }
  end
end
