# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.result do
    render partial: 'organization', locals: { xml_instance: xml, organization: @organization, detailed_info: true }
  end
end
