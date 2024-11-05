# frozen_string_literal: true

module StacksHelper
  def stack_edit_in_place
    haml_tag :a, class: 'rest_in_place_helper' do
      concat I18n.t('stacks.edit_in_place')
    end
  end

  def stack_similar_project_list(projects)
    projects.collect do |proj|
      link_to(html_escape(proj.name), project_path(proj), title: html_escape(proj.name))
    end.join(', ').html_safe
  end

  def stack_country_flag(code)
    img_relative_path = "flags/#{code.to_s.downcase}.png"
    return '' unless asset_exists?(img_relative_path)

    haml_tag 'img', src: asset_url(img_relative_path)
  end

  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end
end
