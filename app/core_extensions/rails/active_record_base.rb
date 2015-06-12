class ActiveRecord::Base
  extend StripAttributes
  after_find :fix_string_column_encodings

  private

  def fix_string_column_encodings
    attributes.keys.each do |column|
      string = send(column)
      next unless string.is_a?(String)
      send("#{column}=", string.fix_encoding_if_invalid!) unless string.blank?
    end
  end
end
