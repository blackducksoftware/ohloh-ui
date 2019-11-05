# frozen_string_literal: true

module ForumsHelper
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Style/MultilineIfModifier
  def forums_sidebar(forum)
    menus = []
    menus << [
      [nil,             t(:topic)],
      [:new_topic,      t(:new_topic), new_forum_topic_path(forum)],
      [:forum,          forum.name, forum_path(forum)]
    ] if @forum

    menus << [
      [nil,             t(:post)],
      [:recent,         t(:recent_posts),     all_posts_path],
      [:need_answers,   t(:unanswered_posts), all_posts_path(unanswered: true)]
    ]

    menus << [
      [nil,             t(:admin)],
      [:new,            t(:new_forum), new_forum_path]
    ] if current_user_is_admin? && !forum

    menus
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Style/MultilineIfModifier
end
