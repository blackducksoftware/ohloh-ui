# frozen_string_literal: true

xml.instruct!
xml.response do
  xml.status('success')
  xml.result do
    xml << render(partial: 'enlistment', locals: { enlistment: @enlistment, builder: xml })
  end
end
