# frozen_string_literal: true

json.project_name @project.name
json.metadata do
  json.current_page_response_size @similar_projects.length
  json.total_count @similar_projects.total_entries
  json.current_page @similar_projects.current_page
  json.total_pages @similar_projects.total_pages
end
json.similar_projects do
  json.array! @similar_projects do |project|
    json.partial! 'similar', project: project
  end
end
