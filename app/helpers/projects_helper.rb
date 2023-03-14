# frozen_string_literal: true

# rubocop: disable Metrics/ModuleLength
module ProjectsHelper
  include ProjectVulnerabilityReportsHelper
  include SiteFeaturesHelper

  def project_activity_level_class(project, image_size)
    url = 'https://community.synopsys.com/s/article/Black-Duck-Open-Hub-About-Project-Activity-Icons'
    haml_tag :a, href: url, target: '_blank',
                 class: project_activity_css_class(project, image_size),
                 title: project_activity_text(project, true)
  end

  def project_activity_level_text(project, image_size)
    haml_tag :div, project_activity_text(project, true), class: project_activity_level_text_class(image_size)
  end

  def project_iusethis_button(project)
    haml_tag :a, href: '#', data: { project_id: project.to_param },
                 class: "#{needs_login_or_verification_or_default('new-stack-entry')} btn btn-primary btn-mini" do
      concat t('projects.i_use_this')
    end
  end

  def project_compare_button(project, label = project.name)
    selected = (@session_projects || []).include?(project)
    haml_tag :form, class: "sp_form styled form-inline #{'selected' if selected}",
                    style: 'min-width: 94px;', id: "sp_form_#{project.to_param}" do
      haml_tag :span, class: 'sp_label', title: label do
        concat label.truncate(35)
      end
      haml_tag :input, style: 'margin-top: 2px;', type: 'checkbox', id: "sp_chk_#{project.to_param}",
                       checked: selected, project_id: project.to_param, class: 'sp_input'
      haml_tag :div, class: 'clear_both'
    end
  end

  def project_twitter_description(project, analysis)
    return project_twitter_description_analysis(project, analysis) if analysis.present?

    project.description.to_s.empty? ? '' : project.description
  end

  def truncate_project_name(name, len = 25, link: false)
    if name.length > len && link == false
      content_tag(:abbr, name.truncate(len), title: name)
    elsif name.length > len && link == true
      name.truncate(len)
    else
      name
    end
  end

  def project_managers_list
    @project.active_managers.map { |m| link_to(html_escape(m.name), account_path(m)) }.to_sentence
  end

  def stack_name(account)
    stacks ||= account.stacks.joins(:projects).where(projects: { id: @project })
    stacks.map do |stack|
      name = stack.decorate.name(account, @project)
      link_to "#{name}#{' Stack' unless name =~ /stack/i}", stack_path(stack)
    end.join(', ')
  end

  def project_activity_text(project, append_activity)
    activity_level = project_activity_level(project)
    case activity_level
    when :na then "#{I18n.t('projects.activity') if append_activity} #{I18n.t('projects.not_available')}"
    when :new then I18n.t('projects.new_project')
    when :inactive then I18n.t('projects.inactive')
    else
      "#{I18n.t("projects.#{activity_level}")} #{I18n.t('projects.activity') if append_activity}"
    end
  end

  def project_separator_text
    '&nbsp;|&nbsp;'.html_safe
  end

  def show_badges
    content_tag :div, class: 'badges' do
      @project.badges_summary.map do |badge|
        concat content_tag(:img, nil, src: badge.badge_url)
      end
    end
  end

  def more_badges_link
    return if @project.project_badges.active.count <= ProjectBadge::SUMMARY_LIMIT

    content_tag :div, class: 'more_badges clearfix' do
      content_tag :p, link_to('more', project_project_badges_path(@project))
    end
  end

  def populate_project_from_forge(url, api)
    match = Forge::Match.first(url)
    Timeout.timeout(Forge::Match::MAX_FORGE_COMM_TIME) { match.project } if match
  rescue Timeout::Error, OpenURI::HTTPError, URI::InvalidURIError
    flash.now[:notice] = t('.forge_time_out', name: match.forge.name) unless api
  end

  private

  def project_twitter_description_analysis(project, analysis)
    content = ''
    content += project.description.to_s.truncate(80).dup.concat(', ')
    content += "#{number_with_delimiter analysis.code_total} lines of code"
    content += " from #{number_with_delimiter analysis.committers_all_time} contributors"
    content + ", #{project_activity_text(project, true)}, #{project.user_count} users"
  end

  def project_activity_css_class(project, size)
    "#{size}_project_activity_level_#{project_activity_level(project)}"
  end

  def project_activity_level_text_class(image_size)
    "#{image_size}_project_activity_text"
  end

  def project_activity_level(project)
    project.best_analysis.activity_level
  end

  def project_description_size_breached?(project)
    project.description && project.description.size > 800
  end

  def scan_oh_language_mapping(language)
    case language
    when 'C++', 'C/C++', 'C' then 'CXX'
    when 'Java' then 'JAVA'
    when 'C#' then 'CSHARP'
    when 'JavaScript' then 'JAVASCRIPT'
    when 'Ruby', 'Python', 'PHP' then 'OTHER'
    end
  end
end
# rubocop: enable Metrics/ModuleLength
