# frozen_string_literal: true

module BlogLinkHelper
  BLOG_LINKS = {
    terms: 'Black-Duck-Open-Hub-Terms-of-Use',
    additional_terms: 'Black-Duck-Open-Hub-API-Use-Agreement',
    contact_form: 'Black-Duck-Open-Hub-Support',
    api_oauth: 'oauth',
    project_languages: 'Black-Duck-Open-Hub-Project-Langauges',
    project_licenses: 'Project-File-Licenses',
    managing_projects: 'Black-Duck-Open-Hub-Managing-Projects-FAQ',
    all_factoids: 'Black-Duck-Open-Hub-Factoid-List',
    no_available_repository: 'No-public-source-code-repository',
    repository_not_supported: 'Ohloh-can-not-process-this-project',
    project_codebase_cost: 'Codebase-Cost',
    mostly_written: 'Mostly-Written-In',
    project_codebase_history: 'Codebase-History',
    stack_update_post: 'Stack-Update',
    badges: 'Black-Duck-Open-Hub-About-Badges',
    pai_about: 'Black-Duck-Open-Hub-About-Project-Activity-Icons',
    hotness_score: 'Black-Duck-Open-Hub-About-the-Ohloh-Hotness-Score'
  }.freeze

  def blog_link_to(link:, link_text:)
    url = "https://community.blackduck.com/s/article/#{BLOG_LINKS[link]}"
    "<a class='meta' href='#{url}' target='_blank'>#{link_text}</a>".html_safe
  end

  def blog_url_for(article_name)
    path = BLOG_LINKS[article_name] || article_name.to_s
    "https://community.blackduck.com/s/article/#{path}"
  end
end
