xml.instruct!
xml.response do
  xml.status('success')
  xml.items_returned @people.length
  xml.items_available @people.total_entries
  xml.first_item_position @people.offset
  if @people.present?
    xml.result do
      xml << render(partial: 'account', collection: @people.map(&:account), locals: { builder: xml })
    end
  end
end
