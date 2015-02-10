def load_charting_defaults(source)
  defaults = YAML.load File.read(source)
  defaults.with_indifferent_access
end

CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/defaults.yml")
COMMITS_BY_PROJECT_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/commits_by_project.yml")
DEMOGRAPHIC_CHART_DEFAULTS = load_charting_defaults("#{Rails.root}/config/charting/demographic.yml")
