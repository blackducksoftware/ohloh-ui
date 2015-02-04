module IconHelper
  def project_icon(project, size = :small, opts = {})
    lang_name = Project.where(id: project).language
    opts[:color] = language_text_color(lang_name)
    opts[:bg]    = language_color(lang_name)

    haml_tag :a, href: project_path(project) do
      icon(project, size, opts)
    end
  end

  def icon(obj, size = :small, opts = {})
    # TODO: prefetched_logos
    # few pages pre-load all the logos at once to avoid N+1 queries in view
    # prefetched_logos = @logos || @logos_map || {}
    # logo = prefetched_logos[obj.logo_id] || obj.logo

    logo = obj.logo
    if logo
      styles = "#{icon_dimensions(size, opts)} border:0 none;"
      concat image_tag(obj.logo.attachment.url(size), style: styles, itemprop: 'image', alt: obj.name)
    else
      haml_tag :p, obj.name.first.capitalize, style: default_icon_styles(size, opts)
    end
  end

  def default_icon_styles(size, opts)
    font_size_map     = { 64 => 56, 48 => 40, 40 => 32, 32 => 26, 24 => 18, 16 => 13 }
    icon_size         = icon_int_size(size, opts)
    font_size         = font_size_map.fetch(icon_size, 14)
    background_color  = opts.fetch(:bg, 'EEE')
    color             = opts.fetch(:color, '000')
    margin_right      = icon_size == 64 ? 0 : 2

    "background-color:##{background_color}; color:##{color}; border:1px dashed ##{color};" \
    "font-size:#{font_size}px; line-height:#{icon_size}px; #{icon_dimensions(size, opts)}" \
    "text-align:center; float:left; margin-bottom:0; margin-top:0; margin-right:#{margin_right}px"
  end

  def icon_int_size(size, opts)
    size_map = { med: 64, small: 32, tiny: 16 }
    opts[:width] || opts[:height] || size_map[size]
  end

  def icon_dimensions(size, opts)
    icon_size = icon_int_size(size, opts)
    "width:#{icon_size}px; height:#{icon_size}px;"
  end
end
