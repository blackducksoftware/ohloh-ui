json.array! @projects.to_a do |project|
  json.id project.to_param
  json.value project.name
end
