# frozen_string_literal: true

xml.instruct!
if @analysis.blank?
  xml.response do
    xml.status('error')
    xml.message('Code analysis is not available')
  end
else
  xml.response do
    xml.status('success')
    xml.result do
      xml << render(partial: 'analysis', locals: { analysis: @analysis, builder: xml })
    end
  end
end
