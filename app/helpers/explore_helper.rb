# frozen_string_literal: true

module ExploreHelper
  COMPARE_PROJECT_INPUT_NOS = [0, 1, 2].freeze

  def scale_to(count, nearest = 100)
    i = (count.to_i / nearest.to_f).ceil
    (i.zero? ? 1 : i) * nearest
  end

  def compare_project_inputs
    COMPARE_PROJECT_INPUT_NOS.map do |n|
      { type: 'text', name: "project_#{n}", placeholder: t('.enter_project'), id: "project_#{n}",
        class: 'autocompletable', data: { source: '/autocompletes/project' } }
    end
  end

  def cache_projects_explore_page
    if @language.blank?
      Rails.cache.fetch('projects_explore_page', expires_in: 1.hour) do
        render 'projects'
      end
    else
      render 'projects'
    end
  end
end
