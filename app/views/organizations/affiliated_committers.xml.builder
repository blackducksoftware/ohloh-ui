# frozen_string_literal: true

accs = @affiliated_committers.select { |acc| organization_affiliated_committers_stats(@stats_map[acc.id]) }

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned accs.size
  xml.items_available @affiliated_committers.total_entries
  xml.first_item_position @affiliated_committers.offset
  xml.result do
    render partial: '/organizations/show/affiliated_committers', locals: { accs: accs, xml_instance: xml }
  end
end
