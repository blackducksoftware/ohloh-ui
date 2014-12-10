module ApplicationHelper
  BLOG_LINKS = {
    terms:                    'terms',
    additional_terms:         'terms-2',
    contact_form:             'support-2',
    api_getting_started:      'getting_started',
    api_oauth:                'oauth',
    project_languages:        'project_languages',
    project_licenses:         'project_licenses',
    managing_projects:        'managingprojects',
    all_factoids:             'factoid-list',
    no_available_repository:  'no_available_repository',
    repository_not_supported: 'repository_not_supported',
    project_codebase_cost:    'project_codebase_cost',
    mostly_written:           'mostly_written',
    project_codebase_history: 'project_codebase_history',
    stack_faq:                'stack_faq',
    examples:                 'examples',
    stack_update_post:        '2008/05/stack_update',
    badges:                   'about-badges',
    pai_about:                'about-project-activity-icons',
    hotness_score:            '2014/01/about-the-ohloh-hotness-score'
  }

  def blog_link_to(link:, link_text:)
    "<a class='meta' href='http://blog.openhub.net/#{BLOG_LINKS[link]}' target='_blank'>#{link_text}</a>"
  end

  def error_tag(model, attr, opts = {})
    return '' if model.nil?
    err = model.errors[attr]
    return '' if err.blank?
    haml_tag 'p', [err].flatten.join('<br />'), opts.reverse_merge(class: 'error').merge(rel: attr)
  end

  def disabled_button(text, opts = {})
    opts[:class] ||= ''
    opts[:class] << (current_user ? ' disabled' : ' needs_login')
    "<a href='#' class='btn #{opts[:class]}'>#{text}</a>".html_safe
  end

  def project_pages_title(page_name = nil, project_name = nil)
    project_name ||= current_project.name if current_project
    s = project_name.nil? ? 'Open Hub' : t(:project_page_title, project_name: project_name)
    s.concat(" : #{page_name}") unless page_name.nil?
    s
  end
end
