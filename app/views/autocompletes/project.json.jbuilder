# frozen_string_literal: true

json.array! @projects do |project|
  json.id project.to_param
  json.value project.name
end
