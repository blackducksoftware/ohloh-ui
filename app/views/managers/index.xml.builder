# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned @manages.length
  xml.items_available @manages.length
  xml.first_item_position 0
  xml.result do
    @manages.each do |manage|
      xml.manager do
        xml.account_id manage.account_id
        xml.account_name manage.account.name
        xml.approved_by_id manage.approver_id
        xml.approved_by_name manage.approver&.name
        xml.created_at xml_date_to_time(manage.created_at)
        xml.updated_at xml_date_to_time(manage.updated_at)
        xml << render(partial: '/accounts/account', locals: { account: manage.account, builder: xml })
      end
    end
  end
end
