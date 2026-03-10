# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned @manages.length

  xml.result do
    @manages.each do |manage|
      xml.manager do
        account = manage.account
        position = account.positions.where(project_id: @parent.id).first
        name_fact = position&.name_fact
        pending = !(manage.approver || manage.destroyer)

        xml.account_id manage.account_id
        xml.account_name account.name
        xml.url account_url(account, format: 'xml')
        xml.html_url account_url(account)
        xml.commits name_fact ? name_fact.commits : 0
        xml.message manage.message
        xml.created_at xml_date_to_time(manage.created_at)
        xml.updated_at xml_date_to_time(manage.updated_at)
        xml.pending pending if pending
      end
    end
  end
end
