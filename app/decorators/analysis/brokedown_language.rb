# frozen_string_literal: true

class Analysis::BrokedownLanguage
  include ColorsHelper

  def initialize(options)
    options.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  def percentage
    @total_lines <= 0 ? 0 : ((@lines / @total_lines.to_f) * 100).round
  end

  def low_percentage?
    percentage < 5
  end

  def info(percentage_value = percentage)
    [@id, @nice_name, { vanity_url: @name, percent: percentage_value, color: language_color(@name) }]
  end

  def brief_info
    [@id, @nice_name, { percent: percentage }]
  end
end
