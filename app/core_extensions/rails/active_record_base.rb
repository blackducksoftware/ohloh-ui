class ActiveRecord::Base
  extend StripAttributes
  after_initialize :fix_string_column_encodings

  private

  def fix_string_column_encodings
    attributes.each do |column, value|
      send("#{column}=", value.fix_encoding_if_invalid!) if value.is_a?(String)
    end
  end
end
