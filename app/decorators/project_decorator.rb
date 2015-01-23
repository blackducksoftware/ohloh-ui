class ProjectDecorator < Draper::Decorator
  delegate_all

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def sidebar
    [
      [
        [:project_summary,  'Project Summary',       h.project_path(object)],
        [:rss,              'News',                 h.project_rss_articles_path(object)],
        [:settings,         'Settings',             h.settings_project_path(object)],
        [:widgets,          'Sharing Widgets',      h.project_widgets_path(object)],
        [:similar_projects, 'Related Projects',     h.project_similar_projects_path(object)]
      ],
      [
        [:code_data,      'Code Data'],
        [:languages,      'Languages',      h.languages_summary_project_analysis_path(object, id: 'latest')],
        [:estimated_cost, 'Cost Estimates', h.estimated_cost_project_path(object)]
      ],
      [
        [:scm_data,     'SCM Data'],
        [:commits,      'Commits',      h.summary_project_commits_path(object)],
        [:contributors, 'Contributors', h.summary_project_contributors_path(object)]
      ],
      [
        [:user_data, 'Community Data'],
        [:users,      'Users',                        h.users_project_path(object)],
        [:reviews,    'Ratings & Reviews',            h.summary_project_reviews_path(object)],
        [:map,        'User & Contributor Locations', h.map_project_path(object)]
      ]
    ]
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
