# frozen_string_literal: true

class ActiveRecord::Base
  extend StripAttributes
  after_find :fix_string_column_encodings

  private

  def fix_string_column_encodings
    attributes.each do |column, value|
      write_attribute(column, value.fix_encoding_if_invalid) if value.is_a?(String)
    end
  end
end
