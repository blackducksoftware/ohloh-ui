module ToolHelper
  # rubocop:disable Metrics/MethodLength
  # Note: Is this used at all anywhere?
  def tools_sidebar
    [
      [
        [nil,                   t(:tools)],
        [:compare_projects,     t(:compare_projects),    compare_projects_path],
        [:compare_languages,    t(:compare_languages),   compare_languages_path],
        [:compare_repositories, t(:compare_repositories), compare_repositories_path]
      ],
      [
        [nil, 'Languages', nil, 'select'],
        ['All Languages', languages_path],
        ['select...', '']
      ] + Language.order('lower(nice_name)').map { |l| [l.nice_name, languages_path(l)] }
    ]
  end
end
