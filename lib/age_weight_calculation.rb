module AgeWeightCalculation
  def age_weight
    age_weight_hash = {}
    generate_months_array.each_with_index do |date, index|
      ver_arr = []
      df = Math.exp(-(0.05 * (index + 1)))
      range = date.first..date.last
      version_release_date_series.select { |version, release_date| ver_arr << version if range.include?(release_date) }
      age_weight_hash.merge!(index + 1 => { df.round(4) => ver_arr })
    end
    age_weight_hash
  end

  def generate_months_array
    get_number_of_months.times.each_with_object([]) do |count, array|
      array << [(five_years_dange_range.last - count.months).beginning_of_month,
                (five_years_dange_range.last - count.months).end_of_month]
    end
  end

  def get_number_of_months
    recent_release_date = five_years_dange_range.last
    oldest_release_date = five_years_dange_range.first
    (recent_release_date.year * 12 + recent_release_date.month) - (oldest_release_date.year * 12 + oldest_release_date.month)
  end

end
