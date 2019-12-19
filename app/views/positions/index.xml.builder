# frozen_string_literal: true

xml.response do
  xml.status 'success'
  xml.items_returned @positions.length
  xml.items_available @positions.length
  xml.first_item_position 0
  xml.result do
    @positions.each do |position|
      xml.position do
        xml.title position.title
        xml.organization position.organization
        xml.html_url show_position_url(position)
        xml.created_at xml_date_to_time(position.created_at)
        xml.created_at xml_date_to_time(position.start_date)
        xml.created_at xml_date_to_time(position.stop_date)
        xml.sparkline_url commits_compound_spark_account_position_url(format: 'png', account_id: position.account_id,
                                                                      id: position.id)
        xml.commits position.name_fact.commits if position.name_fact
        if position.project
          xml << render(partial: '/projects/project', locals: { project: position.project, builder: xml })
        end
      end
    end
  end
end
