# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned @sent_kudos.length
  xml.items_available @sent_kudos.length
  xml.first_item_position 0
  xml.result do
    @sent_kudos.each do |kudo|
      xml.kudo do
        xml.sender_account_id kudo.sender.id
        xml.sender_account_name kudo.sender.name
        if kudo.account
          xml.receiver_account_id kudo.account.id
          xml.receiver_account_name kudo.account.name
        end
        if kudo.project
          xml.project_id kudo.project.id
          xml.project_name kudo.project.name
        end
        if kudo.name
          xml.contributor_id kudo.name.id
          xml.contributor_name kudo.name.name
        end
        xml.created_at kudo.created_at.iso8601
      end
    end
  end
end
