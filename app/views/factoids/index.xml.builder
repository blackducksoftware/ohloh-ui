xml.instruct!
xml.response do
  xml.status('success')
  xml.items_returned @factoids.size
  xml.items_available @factoids.size
  xml.first_item_position 0
  if @factoids.present?
    xml.result do
      xml << render(partial: 'factoid', collection: @factoids, locals: { builder: xml })
    end
  end
end
