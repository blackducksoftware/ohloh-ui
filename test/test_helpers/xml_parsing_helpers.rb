# frozen_string_literal: true

def xml_time(date)
  Time.gm(date.year, date.month, date.day).xmlschema
end

def xml_hash(data)
  xml = Nokogiri::XML(data)
  Hash.from_xml(xml.to_s)
end
