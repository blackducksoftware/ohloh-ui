class Analysis::LangaugeBreakdown < Analysis::Query
  LANAGUAGE_SELECT_COLUMNS = { id: 'language_id', nice_name: 'language', name: 'language_name', category: 'category' }

  arel_tables :activity_fact, :language

  def collection
    execute.select { |fact| fact.code_total.to_i > 0 || fact.comments_total.to_i > 0 }
  end

  private

  def execute
    empty? ? [] : query
  end

  def query
    ActivityFact.select([select_columns, language_select_colums]).joins(:language).where(with_analysis)
                .group(language: LANAGUAGE_SELECT_COLUMNS.keys).order('code_total DESC, nice_name, name, category')
  end

  def language_select_colums
    LANAGUAGE_SELECT_COLUMNS.map do |column, name|
      languages[column].as(name)
    end
  end
end
