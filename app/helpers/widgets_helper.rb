# frozen_string_literal: true

module WidgetsHelper
  def factoid_image_path(factoid)
    path = case factoid.severity
           when 1..100 then 'fact_good.png'
           when 0 then 'fact_info.png'
           when -2..-1 then 'fact_warning.png'
           when -100..-3 then 'fact_bad.png'
           else 'fact_info.png'
           end
    widget_image_url path
  end

  def widget_image_url(source)
    source.starts_with?('http') ? source : asset_url(source)
  end

  def widget_ohloh_logo_url
    widget_image_url 'widget_logos/openhublogo.png'
  end

  def widget_url(widget, type)
    url_params = widget.vars.reject { |k, _| k.to_s == "#{type}_id" }
    send("#{widget.name.underscore}_#{controller_name}_url", widget.send(type)) +
      "?#{url_params.merge(format: 'js').to_query}"
  end

  def widget_gif_url(url, ref)
    query_params = { format: 'gif', ref: ref }
    url + "?#{query_params.to_query}"
  end

  def widget_url_without_format(widget, type)
    url_params = widget.vars.reject { |k, _| k.to_s == "#{type}_id" }
    send("#{widget.name.underscore}_#{controller_name}_url", widget.send(type), url_params)
  end

  def widget_iframe_style(widget)
    "height: #{widget.height}px; width: #{widget.width}px; border: none"
  end
end
