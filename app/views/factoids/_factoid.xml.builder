# frozen_string_literal: true

xml.factoid do
  xml.id factoid.id
  xml.analysis_id factoid.analysis_id
  xml.type factoid.class.to_s
  xml.description factoid.to_s
  xml.severity factoid.severity
  xml.language_id factoid.language_id if factoid.language_id
  xml.license_id factoid.license_id if factoid.license_id
end
