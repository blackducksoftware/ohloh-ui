# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned @organizations.length
  xml.items_available @organizations.total_entries
  xml.first_item_position @organizations.offset
  xml.result do
    render partial: 'organization', collection: @organizations, locals: { xml_instance: xml }
  end
end
