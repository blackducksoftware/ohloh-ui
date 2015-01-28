class ProjectDecorator < Draper::Decorator
  delegate_all

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def sidebar
    [
      [
        [:project_summary,  h.t(:project_summary),    h.project_path(object)],
        [:rss,              h.t(:news),               h.project_rss_articles_path(object)],
        [:settings,         h.t(:settings),           h.settings_project_path(object)],
        [:widgets,          h.t(:sharing_widgets),    h.project_widgets_path(object)],
        [:similar_projects,  h.t(:related_projects),  h.project_similar_projects_path(object)]
      ],
      [
        [:code_data,        h.t(:code_data)],
        [:languages,        h.t(:languages),          h.languages_summary_project_analysis_path(object, id: 'latest')],
        [:estimated_cost,   h.t(:cost_estimates),     h.estimated_cost_project_path(object)]
      ],
      [
        [:scm_data,         h.t(:scm_data)],
        [:commits,          h.t(:commits),            h.summary_project_commits_path(object)],
        [:contributors,     h.t(:contributors),       h.summary_project_contributors_path(object)]
      ],
      [
        [:user_data,        h.t(:community_data)],
        [:users,            h.t(:users),              h.users_project_path(object)],
        [:reviews,          h.t(:ratings_reviews),    h.summary_project_reviews_path(object)],
        [:map,              h.t(:user_contributors),  h.map_project_path(object)]
      ]
    ]
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
