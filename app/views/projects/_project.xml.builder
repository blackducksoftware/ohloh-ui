xml.project do
  xml.id project.id
  xml.name project.name
  xml.url project_url project, format: 'xml'
  xml.html_url project_url project
  xml.created_at project.created_at.iso8601
  xml.updated_at project.updated_at.iso8601
  xml.description project.description
  # TODO: Fix this when urls are implemented
  # xml.homepage_url project.url
  # xml.download_url project.download_url
  # xml.url_name project.url_name
  # TODO: Fix this when s3 urls are implemented
  # if project.logo_id
  #   xml.medium_logo_url s3_url_for(project.logo, :med)
  #   xml.small_logo_url s3_url_for(project.logo, :small)
  # end
  xml.user_count project.user_count
  xml.average_rating project.rating_average
  xml.rating_count project.ratings.count
  xml.review_count project.reviews.count
  xml.analysis_id project.best_analysis_id
  # TODO: Fix this when tags are implemented
  # unless project.tag_list.empty?
  #   xml.tags do
  #     project.tag_list.split.each do |t|
  #       xml.tag t
  #     end
  #   end
  # end
  if defined?(analysis) and analysis
    xml << render(partial: 'analyses/analysis', locals: { analysis: analysis, builder: xml })
  end
  xml.licenses do
    project.licenses.each do |license|
      xml.license do
        xml.name license.name
        xml.nice_name license.nice_name
      end
    end
  end
  xml.project_activity_index do
    xml.value project.best_analysis.activity_level.to_s
    xml.description t("projects.#{project.best_analysis.activity_level}")
  end
  # TODO: Fix this when links are implemented
  # if project.general_links.any?
  #   xml.links do
  #     project.general_links.each do |link|
  #       xml.link do
  #         xml.title link.title
  #         xml.url link.url
  #         xml.category link.category
  #       end
  #     end
  #   end
  # end
end
