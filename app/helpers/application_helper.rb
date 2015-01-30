module ApplicationHelper
  include ChartHelper

  def error_tag(model, attr, opts = {})
    return '' if model.nil?
    err = model.errors[attr]
    return '' if err.blank?
    haml_tag 'p', [err].flatten.join('<br />'), opts.reverse_merge(class: 'error').merge(rel: attr)
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

  def language_color(name)
    LANGUAGE_COLORS[name] || 'EEE'
  end

  def language_text_color(name)
    BLACK_TEXT_LANGUAGES.include?(name) || language_color(name) == 'EEE' ? '000' : 'FFF'
  end

  def pluralize_without_count(count, singular, plural = nil)
    count == 1 ? singular : (plural || singular.pluralize)
  end

  def base_url
    request.protocol + request.host_with_port
  end

  def generate_page_name
    [controller_name, action_name, 'page'].join('_')
  end

  def months_in_range(start_date, end_date)
    (start_date..end_date).map { |d| Date.new(d.year, d.month) }.uniq
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
end
