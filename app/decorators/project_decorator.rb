class ProjectDecorator < Cherry::Decorator
  include ColorsHelper

  delegate :main_language, to: :project

  def icon(size = :small, opts = {})
    opts[:color] = language_text_color(main_language)
    opts[:bg]    = language_color(main_language)

    icon = Icon.new(project, context: { size: size, options: opts })
    icon.image
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def sidebar
    [
      [
        [:project_summary,  I18n.t(:project_summary),    h.project_path(project)],
        [:rss,              I18n.t(:news),               h.project_rss_articles_path(project)],
        [:settings,         I18n.t(:settings),           h.settings_project_path(project)],
        [:widgets,          I18n.t(:sharing_widgets),    h.project_widgets_path(project)],
        [:similar_projects,  I18n.t(:related_projects),  h.project_similar_projects_path(project)]
      ],
      [
        [:code_data,        I18n.t(:code_data)],
        [:languages,        I18n.t(:languages), h.languages_summary_project_analysis_path(project, id: 'latest')],
        [:estimated_cost,   I18n.t(:cost_estimates),     h.estimated_cost_project_path(project)]
      ],
      [
        [:scm_data,         I18n.t(:scm_data)],
        [:commits,          I18n.t(:commits),            h.summary_project_commits_path(project)],
        [:contributors,     I18n.t(:contributors),       h.summary_project_contributors_path(project)]
      ],
      [
        [:user_data,        I18n.t(:community_data)],
        [:users,            I18n.t(:users),              h.users_project_path(project)],
        [:reviews,          I18n.t(:ratings_reviews),    h.summary_project_reviews_path(project)],
        [:map,              I18n.t(:user_contributors),  h.map_project_path(project)]
      ]
    ]
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
