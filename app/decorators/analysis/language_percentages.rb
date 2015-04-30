class Analysis::LanguagePercentages
  TOTAL_PERCENTAGE = 100

  def initialize(analysis)
    @analysis = analysis
    @languages_breakdown = Analysis::LanguagesBreakdown.new(analysis: analysis).map
    @total_lines = @languages_breakdown.map { |language| language[:lines] }.sum
    create_broken_down_languages
  end

  def collection
    data = high_percentage_languages
    if low_percentage_languages.empty?
      data += combine_low_percentage_languages
    else
      data += [@last_language.info(insignificant_languages_percentage)]
    end
  end

  private

  def high_percentage_languages
    @high_pecentages ||= @languages.select(&:high_precentage?).map(&:info)
  end

  def low_percentage_languages
    @low_pecentages ||= (@languages - high_percentage_languages).map(&:brief_info)
  end

  def combine_low_percentage_languages
    others_info = low_percentage_languages + [last_language.brief_info]
    others_count = "#{low_percentage_languages.size} Other"
    [nil, others_count, { percent: insignificant_languages_percentage, composed_of: others_info, color: '000000' }]
  end

  def insignificant_languages_percentage
    @ingsignificant_pecentages ||= TOTAL_PERCENTAGE - high_percentage_languages.sum(&:percentage)
  end

  def create_broken_down_languages
    @languages = @languages_breakdown.map do |language_hash|
      Analysis::BorkedownLanguage.new language_hash.merge(total_lines: @total_lines)
    end
    @last_language = @languages.pop
  end
end
