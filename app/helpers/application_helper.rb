module ApplicationHelper
  include EmailObfuscation
  include ChartHelper
  def error_tag(model, attr, opts = {})
    return '' if model.nil?
    err = model.errors[attr]
    return '' if err.blank?
    haml_tag 'p', [err].flatten.join('<br />').html_safe, opts.reverse_merge(class: 'error').merge(rel: attr)
  end

  def project_pages_title(page_name = nil, project_name = nil)
    project_name ||= current_project.name if current_project
    s = project_name.nil? ? 'Open Hub' : t(:project_page_title, project_name: project_name)
    s.concat(" : #{page_name}") unless page_name.nil?
    s
  end

  def find_nag_reminder
    current_user.actions.where(status: [Action::STATUSES[:nag_once], Action::STATUSES[:remind]]).first
  end

  def expander(text, min = 250, max = 350, regex = /\s/, regex_offset = -1)
    return text if text.length < max

    l = (text[0..min].rindex(regex) || min + 1) + regex_offset
    l -= 1 if text[l..l] == ','
    render_expander(text, l)
  end

  def pluralize_without_count(count, singular, plural = nil)
    count == 1 ? singular : (plural || singular.pluralize)
  end

  def generate_page_name
    [controller_name, action_name, 'page'].join('_')
  end

  def my_account?(account)
    current_user.present? && current_user.id == account.id
  end

  def icon_int_size(size, opts)
    opts[:width] || opts[:height] || { med: 64, small: 32, tiny: 16 }[size]
  end

  def icon_dimensions(size, opts)
    i_size = icon_int_size(size, opts)
    "width:#{i_size}px; height:#{i_size}px;"
  end

  def default_icon_styles(size, opts)
    font_size_map = { 64 => 56, 48 => 40, 40 => 32, 32 => 26, 24 => 18, 16 => 13 }
    i_size = icon_int_size(size, opts)
    font_size = font_size_map[i_size] || 14
    bg = opts[:bg] || 'EEE'
    color = opts[:color] || '000'
    margin_right = i_size == 64 ? 0 : 2

    "background-color:##{bg}; color:##{color}; border:1px dashed ##{color}; \
      font-size:#{font_size}px; line-height:#{i_size}px; #{icon_dimensions(size, opts)} \
      text-align:center; float:left; margin-bottom:0; margin-top:0; margin-right:#{margin_right}px"
  end

  def project_icon(project, size = :small, opts = {})
    opts = opts_with_lang_colors(project, opts)
    return haml_tag(:p, project.name.capitalize, style: default_icon_styles(size, opts)) if project.logo.nil?
    styles = "#{icon_dimensions(size, opts)} border:0 none;"
    concat image_tag(project.logo.attachment.url(size), style: styles, itemprop: 'image', alt: project.name)
  end

  def project_link(project, size = :small, opts = {})
    opts = opts.merge(href: "/p/#{project.to_param}")
    inner = capture_haml { project_icon(project, size, opts) }
    haml_tag :a, inner, opts
  end

  private

  def render_expander(text, l)
    <<-EXPANDER
    #{ text[0..l] }
    <span class="expander">
    <span>... #{ link_to t('expander.more'), 'javascript:void(0);' }</span>
    <span style="display:none">#{ text[l + 1..-1] } #{ link_to t('expander.less'), 'javascript:void(0);' }</span>
    </span>
    EXPANDER
  end

  def opts_with_lang_colors(project, opts)
    return opts unless project.best_analysis && project.best_analysis.main_language
    lang_name = project.best_analysis.main_language
    opts.merge(color: language_text_color(lang_name), bg: language_color(lang_name))
  end
end
