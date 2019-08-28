# frozen_string_literal: true

module LanguagesHelper
  def measures
    {
      'commits' => t('languages.monthly_commits'),
      'contributors' => t('languages.monthly_contributors'),
      'loc_changed' => t('languages.monthly_loc'),
      'projects' => t('languages.monthly_projects')
    }
  end

  def measure_description
    {
      'commits' => t('languages.commits_desc'),
      'contributors' => t('languages.contributors_desc'),
      'loc_changed' => t('languages.loc_desc'),
      'projects' => t('languages.projects_desc')
    }
  end
end
