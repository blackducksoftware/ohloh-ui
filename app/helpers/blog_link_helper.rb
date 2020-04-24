# frozen_string_literal: true

module BlogLinkHelper
  BLOG_LINKS = {
    terms: 'Black-Duck-Software-Open-Hub-Terms-of-Use',
    additional_terms: 'Black-Duck-Open-Hub-API-Use-Agreement',
    contact_form: 'Black-Duck-Open-Hub-Support',
    api_oauth: 'oauth',
    project_languages: 'project_languages',
    project_licenses: 'project_licenses',
    managing_projects: 'Black-Duck-Open-Hub-Managing-Projects-FAQ',
    all_factoids: 'Black-Duck-Open-Hub-Factoid-List',
    no_available_repository: 'no_available_repository',
    repository_not_supported: 'repository_not_supported',
    project_codebase_cost: 'project_codebase_cost',
    mostly_written: 'mostly_written',
    project_codebase_history: 'project_codebase_history',
    stack_faq: '#',
    examples: 'examples',
    stack_update_post: '2008/05/stack_update',
    badges: 'Black-Duck-Open-Hub-About-Badges',
    pai_about: 'Black-Duck-Open-Hub-About-Project-Activity-Icons',
    hotness_score: 'Black-Duck-Open-Hub-About-the-Ohloh-Hotness-Score'
  }.freeze

  def blog_link_to(link:, link_text:)
    url = "https://community.synopsys.com/s/article/#{BLOG_LINKS[link]}"
    "<a class='meta' href='#{url}' target='_blank'>#{link_text}</a>".html_safe
  end

  def blog_url_for(article_name)
    path = BLOG_LINKS[article_name] || article_name.to_s
    "https://community.synopsys.com/s/article/#{path}"
  end
end
