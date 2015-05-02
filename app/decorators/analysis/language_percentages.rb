class Analysis::LanguagePercentages
  TOTAL_PERCENTAGE = 100

  def initialize(analysis)
    @analysis = analysis
    @languages_breakdown = Analysis::LanguagesBreakdown.new(analysis: analysis).map
    @total_lines = @languages_breakdown.map { |language| language[:lines] }.sum
    create_broken_down_languages
  end

  def collection
    if low_percentage_languages_info.empty?
      high_percentage_languages_info + combined_low_percentage_languages_info
    else
      high_percentage_languages_info << @last_language.info(insignificant_languages_percentage)
    end
  end

  private

  def high_percentage_languages_info
    @high_pecentages ||= @languages.select(&:high_precentage?).map(&:info)
  end

  def low_percentage_languages_info
    @low_pecentages ||= @languages.select(&:low_percentage?).map(&:brief_info)
  end

  def combined_low_percentage_languages_info
    others_info = low_percentage_languages_info + [last_language.brief_info]
    others_count = "#{low_percentage_languages_info.size} Other"
    [nil, others_count, { percent: insignificant_languages_percentage, composed_of: others_info, color: '000000' }]
  end

  def insignificant_languages_percentage
    significant_lanaguages_percentage = high_percentage_languages_info.map(&:last).sum { |detail| detail[:percent] }
    @ingsignificant_pecentages ||= TOTAL_PERCENTAGE - significant_lanaguages_percentage
  end

  def create_broken_down_languages
    @languages = @languages_breakdown.each_with_object([]) do |language_hash, array|
      array << Analysis::BrokedownLanguage.new(language_hash.merge(total_lines: @total_lines, index: array.size))
    end
    @last_language = @languages.pop
  end
end
