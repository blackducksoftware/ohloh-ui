# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status('success')
  xml.items_returned @enlistments.length
  xml.items_available @enlistments.total_entries
  xml.first_item_position @enlistments.offset
  if @enlistments.present?
    xml.result do
      xml << render(partial: 'enlistment', collection: @enlistments, locals: { builder: xml })
    end
  end
end
