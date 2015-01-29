# TODO: Refactor this
module ChartingHelper
  def account_graph_time_span
    7.years.ago.strftime('%b %Y').concat(' - Present')
  end

  def chart_img_tag(url, width, height, params=nil)
    encoded_params = (params.nil?) ? nil : "?" + params.to_a.collect { |k, v| k.to_s + "=" + v.to_s }.join("&")
    result = "<img src='#{url}#{encoded_params}'"
    result += ( " width='#{width.to_s}'" ) unless width.nil?
    result += ( " height='#{height.to_s}'" ) unless height.nil?
    result += "alt='Chart' />"
    return result
  end

  def chart_options(opts = nil)
    opts ||= {}
    options = {
      "data-scrollbar" => opts && opts['data-scrollbar'] ? opts['data-scrollbar'] : '{ "enabled": false }',
      "data-navigator" => opts && opts['data-navigator'] ? opts['data-navigator'] : '{ "enabled": false }',
      "data-range-selector" => opts && opts['data-range-selector'] ? opts['data-range-selector'] : '{ "enabled": false }',
      "data-legend" => opts && opts['data-legend'] ? opts['data-legend'] : '{ "enabled": false }'
    }
    options.merge opts
  end

  def chart_interactive_tag(url, width, height, params=nil, htmlID=nil, shift_left = false, opts={})
    encoded_params = (params.nil?) ? nil : "?" + params.to_a.collect { |k, v| k.to_s + "=" + v.to_s }.join("&")
    result = "<div id='#{htmlID||''}' class='chart #{opts[:class]}'"

    opts.each_pair do |k,v|
      if k =~ /^data-/
        result << "#{k}='#{v}'"
      end
    end

    result << ( " datasrc='#{url}#{encoded_params}'") unless url.nil?
    result << " style='"
    result << ( " width:#{width.to_s}px;" ) unless width.nil?
    result << ( " height:#{height.to_s}px;" ) unless height.nil?
    result << (  " margin-left: -28px;" ) if shift_left
    result << "'";
    result << "></div>"
    return result
  end

  # renders a non-interactive chart tag that uses a pre-loaded data set
  def chart_with_data_tag(data, width, height, opts={})
    result =  "<div id='#{opts[:id]}' class='chart-with-data #{opts[:class]}' "

    opts.each_pair do |k,v|
      result << %Q(#{k}=#{v} ) if k =~ /^data-/
    end

    result << "datavalue='#{data.as_json}' style='"
    result << "width:#{width}px;" unless width.nil?
    result << "height:#{height}px;" unless height.nil?
    result << "'></div>"
  end

  def streamgraph_chart(url, scope)
    #encoded_params = (params.nil?) ? nil : "?" + params.to_a.collect { |k, v| k.to_s + "=" + v.to_s }.join("&")
    result = "<div id='ohloh_streamgraph' class='stream_graph #{scope}' "
    result << "datasrc='#{url.to_s}'" unless url.nil?
    result << "datascope='#{scope}'"
    result << "></div>"
    return result
  end

  def should_display_analysis_chart(analysis)
    return [false, :no_commits] if analysis.commit_count.nil? || analysis.commit_count <= 0
    return [false, :no_understood_lang] if analysis.logic_total <= 0 && analysis.markup_total <= 0
    return [true, nil]
  end

  def chart_watermark(img)
    chart_watermark_hash(img).to_json
  end

  def chart_watermark_hash(img, new_positions={})
    position = {x: "50%", y: "50%"}.merge!(new_positions)
    {
     "backgroundColor" => 'transparent',
     "style" => {
             "background-image" => "url(\"/images/#{img}.png\")",
             "background-repeat" => "no-repeat",
             "background-position" => "#{position[:x]} #{position[:y]}"
            }
    }
  end
end
