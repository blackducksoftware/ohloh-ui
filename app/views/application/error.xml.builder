# frozen_string_literal: true

xml.instruct!
xml.error do
  xml.message @error[:message]
end
