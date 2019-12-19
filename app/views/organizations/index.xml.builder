# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned @organizations.size
  xml.items_available @organizations.size
  xml.first_item_position 0
  xml.result do
    render partial: 'organization', collection: @organizations, locals: { xml_instance: xml }
  end
end
