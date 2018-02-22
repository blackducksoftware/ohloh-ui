# rubocop: disable Metrics/ModuleLength
module ApplicationHelper
  include EmailObfuscation
  include ChartHelper
  include BootstrapHelper
  include TimeStampHelper

  def error_tag(model, attr, opts = {})
    return '' if model.nil?
    err = model.errors[attr]
    return '' if err.blank?
    haml_tag 'p', [err].flatten.join('<br />').html_safe, opts.reverse_merge(class: 'error').merge(rel: attr)
  end

  def password_error_tag(model, attr, opts = {})
    err = model.errors[attr]
    return '' if err.blank? || err == ["can't be blank"]
    err = err.first if err.size == 2
    haml_tag 'p', [err].flatten.join('<br />').html_safe, opts.reverse_merge(class: 'error').merge(rel: attr)
  end

  def project_pages_title(page_name = nil, project_name = nil)
    project_name ||= current_project.name if current_project
    s = project_name.nil? ? 'Open Hub' : t(:project_page_title, project_name: project_name)
    s.concat(" : #{page_name}") unless page_name.nil?
    s
  end

  def find_nag_reminder
    return unless current_user
    current_user.actions.where(status: [Action::STATUSES[:nag_once], Action::STATUSES[:remind]]).first
  end

  def expander(text, min = 250, max = 350, regex = /\s/, regex_offset = -1)
    return unless text
    text = text.escape.sanitize
    return text.html_safe if text.length < max

    l = (text[0..min].rindex(regex) || min + 1) + regex_offset
    l -= 1 if text[l..l] == ','
    render_expander(text, l).html_safe
  end

  def pluralize_without_count(count, singular, plural = nil)
    count == 1 ? singular : (plural || singular.pluralize)
  end

  def pluralize_with_delimiter(count, singular, plural = nil)
    number_with_delimiter(count || 0) + ' ' + ((count.to_i == 1) ? singular : (plural || singular.pluralize))
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
    return project_text_icon(project, size, opts) if project.logo.nil?
    styles = "#{icon_dimensions(size, opts)} border:0 none;"
    concat image_tag(project.logo.attachment.url(size), style: styles, itemprop: 'image', alt: project.name)
  end

  def project_text_icon(project, size, opts)
    p_name = project.name.first.capitalize
    main_language = project.main_language
    opts[:color] = language_text_color(main_language)
    opts[:bg]    = language_color(main_language)
    haml_tag(:p, p_name, style: default_icon_styles(size, opts))
  end

  def project_link(project, size = :small, opts = {})
    opts = opts.merge(href: "/p/#{project.to_param}")
    inner = capture_haml { project_icon(project, size, opts) }
    haml_tag :a, inner, opts
  end

  def xml_date_to_time(date)
    return '' if date.nil?
    Time.gm(date.year, date.month, date.day).xmlschema
  end

  def number_with_delimiter(number, delimiter: ',', separator: '.')
    parts = number.to_s.split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
    parts.join separator
  rescue
    number
  end

  def highlight(actual_time, base_time = nil)
    return if actual_time.blank?
    base_time ||= @highlight_from || Time.current
    return 'highlight' if actual_time >= base_time
  end

  def strip_tags_and_escaped_html(string)
    ActionView::Base.full_sanitizer.sanitize(string)
  end

  def needs_login
    logged_in? ? '' : 'needs_login'
  end

  def api_pagination(response)
    numbers = (1..response['total_entries']).to_a
    will_paginate(numbers.paginate(page: response['current_page'], per_page: response['per_page']))
  end

  private

  def render_expander(text, l)
    <<-EXPANDER
    #{text[0..l]}
    <span class="expander">
    <span x-wrapper>... #{link_to t('expander.more'), 'javascript:void(0);', class: 'ctrl'}</span>
    <span x-wrapper style="display:none">#{text[l + 1..-1]} #{link_to t('expander.less'), 'javascript:void(0);', class: 'ctrl'}</span>
    </span>
    EXPANDER
  end

  def opts_with_lang_colors(project, options)
    return options if !project.is_a?(Project) || project.best_analysis.main_language.nil?
    lang_name = project.best_analysis.main_language
    options.merge(color: language_text_color(lang_name), bg: language_color(lang_name))
  end

  def needs_login_or_verification_or_default(default_class = nil)
    return default_class if logged_in? && current_user_is_verified?
    return :needs_login unless logged_in?
    return :needs_email_verification unless current_user.access.email_verified?
    :needs_verification
  end
end
