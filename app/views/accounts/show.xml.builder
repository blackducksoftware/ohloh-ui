xml.instruct!
xml.response do
  xml.status 'success'
  xml.result do
    xml << (render 'account', builder: xml, account: @account)
  end
end
