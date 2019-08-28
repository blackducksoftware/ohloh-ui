# frozen_string_literal: true

module TimeParser
  module_function

  def months_in_range(start_date, end_date)
    (start_date..end_date).map { |d| Date.new(d.year, d.month) }.uniq
  end
end
