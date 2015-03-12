module ChartHelper
  def chart_default_time_span
    "#{7.years.ago.strftime('%b %Y')} - Present"
  end

  # TODO: Switch all of this to chart decorator once that is merged in.
  def chart_options(opts)
    enabled_false = '{ "enabled": false }'
    options = {
      'data-scrollbar' => opts['data-scrollbar'] ? opts['data-scrollbar'] : enabled_false,
      'data-navigator' => opts['data-navigator'] ? opts['data-navigator'] : enabled_false,
      'data-range-selector' => opts['data-range-selector'] ? opts['data-range-selector'] : enabled_false,
      'data-legend' =>  opts['data-legend'] ? opts['data-legend'] : enabled_false
    }
    options.merge opts
  end

  def chart_interactive_tag(url, width, height, opts)
    result = "<div id='loc_chart' class='chart #{opts[:class]}' style='width:#{width}px; height:#{height}px;'"

    opts.each_pair do |k, v|
      result << "#{k}='#{v}'" if k =~ /^data-/
    end

    result << " datasrc='#{url}'></div>"
    result
  end

  def chart_watermark(img)
    chart_watermark_hash(img).to_json
  end

  def chart_watermark_hash(img, new_positions = {})
    position = { x: '50%', y: '50%' }.merge!(new_positions)
    {
      backgroundColor: 'transparent',
      style: {
        'background-image' => "url(\"/images/#{img}.png\")",
        'background-repeat' => 'no-repeat',
        'background-position' => "#{position[:x]} #{position[:y]}"
      }
    }
  end
end
