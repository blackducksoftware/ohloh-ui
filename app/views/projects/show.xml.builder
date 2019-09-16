# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.result do
    xml << render(partial: 'project', locals: { project: @project, builder: xml, include_analysis: true })
  end
end
