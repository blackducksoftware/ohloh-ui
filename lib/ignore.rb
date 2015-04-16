module Ignore
  class << self
    def parse(text)
      text.to_s.each_line.collect do |line|
        parse_line(line)
      end.compact
    end

    def parse_line(line)
      return $1 if line.to_s.strip =~ /^Disallow:\s*([^#\*\s][^\*\s]+)\*?(\s+|$)/i
    end

    def match?(prefixes, fyle_name)
      prefixes.each do |prefix|
        return true if fyle_name[0, prefix.length] == prefix
      end
      false
    end
  end
end
