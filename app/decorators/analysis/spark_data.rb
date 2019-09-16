# frozen_string_literal: true

class Analysis::SparkData
  class << self
    def generate
      default_series.merge(series_for_last_two_months).to_a
    end

    private

    def series_for_last_two_months
      Analysis::AgeHistogram.execute.each_with_object({}) do |analysis, hsh|
        hsh[analysis.logged_date] = analysis.value
      end
    end

    def default_series
      current_date = Date.current
      ((current_date - 63)..current_date).to_a.each_with_object({}) do |date, hsh|
        hsh[date.to_time(:utc)] = 0
      end
    end
  end
end
