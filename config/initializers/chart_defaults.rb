def load_chart_options(source)
  defaults = YAML.load File.read(Rails.root.join("config/charting/#{source}"))
  defaults.with_indifferent_access
end

CHART_DEFAULTS = load_chart_options('defaults.yml')
COMMITS_BY_PROJECT_CHART_DEFAULTS = load_chart_options('commits_by_project.yml')
DEMOGRAPHIC_CHART_DEFAULTS = load_chart_options('demographic.yml')
ANALYSIS_CHART_DEFAULTS = load_chart_options('analysis/defaults.yml')
TOP_COMMIT_VOLUME_CHART_DEFAULTS = load_chart_options('analysis/top_commit_volume.yml')

COMMIT_HISTORY_CHART_DEFAULTS = load_chart_options('analysis_commit_history_chart.yml')
COMMITTER_HISTORY_CHART_DEFAULTS = load_chart_options('analysis_committer_history_chart.yml')
CODE_HISTORY_CHART_DEFAULTS = load_chart_options('analysis_code_history_chart.yml')
LANGUAGE_HISTORY_CHART = load_chart_options('analysis_language_history_chart.yml')
LINES_OF_CODE_CHART_DEFAULTS = load_chart_options('analysis_lines_of_code_chart_defaults.yml')
