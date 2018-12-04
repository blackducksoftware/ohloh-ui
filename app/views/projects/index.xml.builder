xml.instruct!
xml.response do
  xml.status('success')
  xml.items_returned @projects.length
  xml.items_available @projects.total_entries
  xml.first_item_position @projects.offset
  if @projects.present?
    xml.result do
      xml << render(partial: 'project', collection: @projects, locals: { builder: xml })
    end
  end
end
