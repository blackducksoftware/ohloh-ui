module CsvHelper
  def csv_escape(value)
    string = value.to_s
    return string if [',', '"', "'"].select { |char| string.include?(char) }.compact.empty?

    "\"#{string.gsub('"', '""')}\""
  end
end
