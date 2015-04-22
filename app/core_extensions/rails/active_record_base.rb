class ActiveRecord::Base
  extend StripAttributes

  class << self
    def fix_string_column_encodings!
      after_find :fix_string_column_encodings
    end

    def string_column_names
      @string_columns ||= columns.reject { |column| column.sql_type != 'text' }.map(&:name).map(&:to_sym)
    end
  end

  def fix_string_column_encodings
    self.attributes.keys.each do |column|
      string = send(column)
      next unless string.is_a?(String)
      send("#{column}=", string.fix_encoding_if_invalid!) unless string.blank?
    end
  end
end
