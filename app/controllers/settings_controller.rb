class SettingsController < ApplicationController
  # NOTE: renamed disable_oversized_projects to oversized_project?
  def oversized_project?(project)
    return true if defined?(OVERSIZED_PROJECT_IDS) && OVERSIZED_PROJECT_IDS.include?(project.id)
  end
end
