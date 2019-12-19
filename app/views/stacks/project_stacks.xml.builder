# frozen_string_literal: true

order = 'lower(accounts.name), lower(stacks.title)'
stacks = @project.stacks.joins(:account).includes(:account, :stack_entries).order(order)
stacks = stacks.paginate(page: page_param, per_page: 10)

xml.instruct!
xml.response do
  xml.status 'success'
  xml.items_returned stacks.size
  xml.items_available stacks.total_entries
  xml.first_item_position stacks.offset
  xml.result do
    stacks.each do |stack|
      xml.stack do
        xml.id stack.id
        xml.title stack.title
        xml.description stack.description
        xml.updated_at xml_date_to_time(stack.updated_at)
        xml.project_count stack.project_count
        xml.stack_entries do
          stack.stack_entries.each do |stack_entry|
            xml.stack_entry do
              xml.id stack_entry.id
              xml.stack_id stack_entry.stack_id
              xml.project_id stack_entry.project_id
              xml.created_at xml_date_to_time(stack_entry.created_at)
            end
          end
        end
        xml.account_id stack.account_id
        xml << render(partial: '/accounts/account', locals: { account: stack.account, builder: xml })
      end
    end
  end
end
