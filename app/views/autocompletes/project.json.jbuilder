json.array! @projects.each do |project|
  json.id project.to_param
  json.value project.name
end
