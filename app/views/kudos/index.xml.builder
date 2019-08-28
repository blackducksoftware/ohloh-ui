# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned @received_kudos.length
  xml.items_available @received_kudos.length
  xml.first_item_position 0
  xml.result do
    @received_kudos.each do |kudo|
      xml.kudo do
        xml.sender_account_id kudo.sender.id
        xml.sender_account_name kudo.sender.name
        xml.receiver_account_id kudo.account.id
        xml.receiver_account_name kudo.account.name
        xml.created_at kudo.created_at.iso8601
      end
    end
  end
end
