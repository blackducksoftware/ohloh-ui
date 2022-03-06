# frozen_string_literal: true

include_analysis ||= false

xml.project do
  xml.id project.id
  xml.name project.name
  xml.url project_url project, format: 'xml'
  xml.html_url project_url project
  xml.created_at(project.created_at.iso8601) if project.created_at
  xml.updated_at(project.updated_at.iso8601) if project.updated_at
  xml.description project.description
  xml.homepage_url project.url
  xml.download_url project.download_url
  xml.url_name project.vanity_url
  xml.vanity_url project.vanity_url
  if project.logo_id
    xml.medium_logo_url project.logo.attachment.url(:med)
    xml.small_logo_url project.logo.attachment.url(:small)
  end
  xml.user_count project.user_count
  xml.average_rating project.rating_average
  xml.rating_count project.ratings.count
  xml.review_count project.reviews.count
  xml.analysis_id project.best_analysis_id
  tags = project.tag_list.split
  if tags.any?
    xml.tags do
      tags.each do |t|
        xml.tag t
      end
    end
  end
  if include_analysis && project.best_analysis.present?
    xml << render(partial: 'analyses/analysis', locals: { analysis: project.best_analysis, builder: xml })
  end
  xml.similar_projects do
    unless project.related_by_tags(4).empty?
      project.related_by_tags(4).each do |project|
        xml.project do
          xml.id project.id
          xml.name project.name
          xml.vanity_url project.vanity_url
        end
      end
    end
  end
  xml.licenses do
    project.licenses.each do |license|
      xml.license do
        xml.name license.name
        xml.vanity_url license.vanity_url
      end
    end
  end
  xml.project_activity_index do
    xml.value Analysis::ACTIVITY_LEVEL_INDEX_MAP[project.best_analysis.activity_level]
    xml.description t("projects.#{project.best_analysis.activity_level}")
  end
  if project.links.general.any?
    xml.links do
      project.links.general.each do |link|
        xml.link do
          xml.title link.title
          xml.url link.url
          xml.category link.category
        end
      end
    end
  end
end
