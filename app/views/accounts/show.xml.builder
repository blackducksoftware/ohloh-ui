# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.result do
    xml << (render 'account', builder: xml, account: @account, show_positions: true, show_about: true)
  end
end
