# frozen_string_literal: true

class ProjectDecorator < Cherry::Decorator
  include ColorsHelper

  delegate :main_language, :links, to: :project

  def icon(size = :small, opts = {})
    opts[:color] = language_text_color(main_language)
    opts[:bg]    = language_color(main_language)

    icon = Icon.new(project, context: { size: size, options: opts })
    icon.image
  end

  def sorted_link_list
    links.sort do |a, b|
      if b.category == 'Homepage'
        1
      elsif a.category == 'Homepage'
        -1
      else
        a.category <=> b.category
      end
    end.group_by(&:category)
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def sidebar(account)
    [
      [
        [:project_summary,  I18n.t(:project_summary),    h.project_path(project)],
        [:rss,              I18n.t(:news),               h.project_rss_articles_path(project)],
        [:settings,         I18n.t(:settings),           h.settings_project_path(project)],
        [:widgets,          I18n.t(:sharing_widgets),    h.project_widgets_path(project)],
        [:similar_projects, I18n.t(:related_projects), h.similar_project_path(project)]
      ],
      [
        [:code_data,        I18n.t(:code_data)],
        [:languages,        I18n.t(:languages_menu), h.languages_summary_project_analysis_path(project, id: 'latest')],
        [:estimated_cost,   I18n.t(:cost_estimates), h.estimated_cost_project_path(project)],
        [:project_security, I18n.t(:project_security), h.security_project_path(project)]
      ],
      [
        [:scm_data,         I18n.t(:scm_data)],
        [:commits,          I18n.t(:commits_menu),       h.summary_project_commits_path(project)],
        [:contributors,     I18n.t(:contributors),       h.summary_project_contributors_path(project)]
      ],
      [
        [:user_data,        I18n.t(:community_data)],
        [:users,            I18n.t(:users),              h.users_project_path(project)],
        [:reviews,          I18n.t(:ratings_reviews),    h.summary_project_reviews_path(project)],
        [:map,              I18n.t(:user_contributors),  h.map_project_path(project)]
      ]
    ].tap do |menus|
      append_sbom_menu(menus, account)
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def append_sbom_menu(menus, account)
    return unless (Rails.env.staging? || account.access.admin?) && project.sboms.exists?

    menus.third << [:sbom, I18n.t(:sbom), h.project_project_sboms_path(project)]
  end
end
