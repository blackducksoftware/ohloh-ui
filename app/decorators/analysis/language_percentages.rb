# frozen_string_literal: true

class Analysis::LanguagePercentages
  TOTAL_PERCENTAGE = 100

  def initialize(analysis)
    @analysis = analysis
    @languages_breakdown = Analysis::LanguagesBreakdown.new(analysis: analysis).map
    @total_lines = @languages_breakdown.map { |language| language[:lines] }.sum
    @languages = create_broken_down_languages
  end

  def collection
    result = []
    @languages.each_with_index do |language, index|
      if (language.low_percentage? || index > 2) && index < (@languages.size - 1)
        result << combined_low_percentages_info(index)
        break
      end
      result << language.info
    end
    result
  end

  private

  def create_broken_down_languages
    @languages_breakdown.each_with_object([]) do |language_hash, array|
      array << Analysis::BrokedownLanguage.new(language_hash.merge(total_lines: @total_lines))
    end
  end

  def combined_low_percentages_info(index)
    others_info = @languages[index..-1].map(&:brief_info)
    percentage = remaining_percentage(index)
    [nil, "#{others_info.size} Other", { percent: percentage, composed_of: others_info, color: '000000' }]
  end

  def remaining_percentage(index)
    @remaining_percentage ||= TOTAL_PERCENTAGE - @languages[0...index].sum(&:percentage)
  end
end
