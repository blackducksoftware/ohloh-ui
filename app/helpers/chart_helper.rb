module ChartHelper
  def chart_options(opts = {})
    default_options = {
      "data-scrollbar" => '{ "enabled": false }',
      "data-navigator" => '{ "enabled": false }',
      "data-range-selector" => '{ "enabled": false }',
      "data-legend" => '{ "enabled": false }'
    }
    opts.reverse_merge(default_options)
  end

  def chart_default_time_span
    "#{7.years.ago.strftime('%b %Y')} - Present"
  end

  def display_analysis_chart(analysis)
    if analysis.commit_count.nil? || analysis.commit_count <= 0
      [false, :no_commits]
    elsif analysis.logic_total <= 0 && analysis.markup_total <= 0
      [false, :no_understood_lang]
    else
      [true, nil]
    end
  end

  def chart_watermark(img)
    watermark_hash(img).to_json
  end

  def chart_watermark_hash(img, new_positions={})
    position = {x: "50%", y: "50%"}.merge!(new_positions)
    {
     "backgroundColor" => 'transparent',
     "style" => { "background-image" => "url(\"/images/#{img}.png\")",
                  "background-repeat" => "no-repeat",
                  "background-position" => "#{position[:x]} #{position[:y]}" }
    }
  end
end
