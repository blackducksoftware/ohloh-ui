# frozen_string_literal: true

module Allowed
  def self.parse(text)
    text.to_s.each_line.map do |line|
      line.sub(/\*$/, '').chomp.strip
    end.reject(&:empty?)
  end

  def self.match?(prefixes, fyle_name)
    prefixes.any? do |prefix|
      prefix = prefix.tr('\\', '/')
      fyle_name.match(/^#{prefix}/)
    end
  end
end
