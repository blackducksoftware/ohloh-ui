# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.error t('.no_analysis_message', name: @project.name)
end
