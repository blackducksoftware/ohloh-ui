# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status 'success'
  xml.result do
    xml << (render 'language', language: @language, builder: xml)
  end
end
