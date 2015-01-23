module ForumHelper
  # rubocop:disable Metrics/MethodLength
  def forums_sidebar
    menus = []
    menus <<  [
      [nil, 'Topics'],
      [:new_topic,      'New Topic',     new_forum_topic_path(@forum)],
      [:forum,          @forum.name,     forum_path(@forum)]
    ] if @forum

    menus << [
      [nil, 'Posts'],
      [:recent,           'Recent Posts',     all_posts_path],
      [:need_answers,     'Unanswered Posts', all_posts_path(unanswered: true)]
    ]

    menus << [
      [nil,  'Admin'],
      [:new, 'New Forum', new_forum_path]
    ] if current_user_is_admin? && !@forum

    menus
  end
end
