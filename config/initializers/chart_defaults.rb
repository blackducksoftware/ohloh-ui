def load_charting_defaults(source)
  defaults = YAML.load File.read(source)
  defaults.with_indifferent_access
end

CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/defaults.yml")
COMMITS_BY_PROJECT_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/commits_by_project.yml")
DEMOGRAPHIC_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/demographic.yml")
ANALYSIS_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/analysis_chart_defaults.yml")
COMMIT_HISTORY_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/analysis_commit_history_chart.yml")
COMMITTER_HISTORY_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/analysis_committer_history_chart.yml")
CODE_HISTORY_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/analysis_code_history_chart.yml")
COMMIT_VOLUME_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/analysis_commit_volume_chart.yml")
LANGUAGE_HISTORY_CHART = load_charting_defaults("#{Rails.root}/config/charting/analysis_language_history_chart.yml")
