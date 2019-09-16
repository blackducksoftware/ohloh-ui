# frozen_string_literal: true

def load_chart_options(source)
  defaults = YAML.safe_load File.read(Rails.root.join("config/charting/#{source}"))
  defaults.with_indifferent_access
end

def chart_background_image(image_name)
  ApplicationController.helpers.asset_url('charts/' + image_name)
end

CHART_DEFAULTS = load_chart_options('defaults.yml')
ActiveSupport.on_load(:after_initialize) do
  path = Rails.root.join('config', 'charting', 'commits_by_project.yml')
  COMMITS_BY_PROJECT_CHART_DEFAULTS = YAML.safe_load(ERB.new(File.read(path)).result(binding))
end

DEMOGRAPHIC_CHART_DEFAULTS = load_chart_options('demographic.yml')

ANALYSIS_CHART_DEFAULTS = load_chart_options('analysis/defaults.yml')
TOP_COMMIT_VOLUME_CHART_DEFAULTS = load_chart_options('analysis/top_commit_volume.yml')
ANALYSIS_CHARTS_OPTIONS = load_chart_options('analysis/options_based_on_type.yml')

VULNERABILITY_VERSION_CHART_DEFAULTS = load_chart_options('project_vulnerability_version.yml')
ACCOUNTS_CHART_DEFAULTS = load_chart_options('accounts.yml')
