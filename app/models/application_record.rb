class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend StripAttributes
  after_find :fix_string_column_encodings

  private

  def fix_string_column_encodings
    attributes.each do |column, value|
      self[column] = value.fix_encoding_if_invalid if value.is_a?(String)
    end
  end
end
