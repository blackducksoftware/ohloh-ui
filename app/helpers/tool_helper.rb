module ToolHelper
  # rubocop:disable Metrics/MethodLength
  def tools_sidebar
    [
      [
        [nil, 'Tools'],
        [:compare_projects,     'Compare Projects',    compare_projects_path],
        [:compare_languages,    'Compare Languages',   compare_languages_path],
        [:compare_repositories, 'Compare Repositories', compare_repositories_path]
      ],
      [
        [nil, 'Languages', nil, 'select'],
        ['All Languages', languages_path],
        ['select...', '']
      ] + Language.order('lower(nice_name)').map { |l| [l.nice_name, languages_path(l)] }
    ]
  end
end
