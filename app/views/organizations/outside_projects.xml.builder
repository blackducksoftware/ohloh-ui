# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned @outside_projects.size
  xml.items_available @outside_projects.total_entries
  xml.first_item_position @outside_projects.offset
  xml.result do
    render partial: '/organizations/show/outside_projects', locals: { xml_instance: xml }
  end
end
