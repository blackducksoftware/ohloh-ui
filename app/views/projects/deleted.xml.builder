# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status t('.failed')
  xml.error t('.message', name: @project.name)
end
