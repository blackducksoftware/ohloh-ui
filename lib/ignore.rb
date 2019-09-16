# frozen_string_literal: true

module Ignore
  class << self
    def parse(text)
      text.to_s.each_line.collect do |line|
        parse_line(line)
      end.compact
    end

    def parse_line(line)
      line.to_s.strip.slice(/^Disallow:\s*([^#\*\s][^\*\s]+)\*?(\s+|$)/i, 1)
    end

    def match?(prefixes, fyle_name)
      prefixes.any? do |prefix|
        prefix = prefix.tr('\\', '/')
        fyle_name.match(/^#{prefix}/)
      end
    end
  end
end
