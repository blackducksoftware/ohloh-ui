# frozen_string_literal: true

class Analysis::LanguagesBreakdown < Analysis::QueryBase
  LANAGUAGE_SELECT_COLUMNS = { id: 'language_id', nice_name: 'language_nice_name', name: 'language_name',
                               category: 'category' }.freeze

  arel_tables :activity_fact, :language

  def collection
    execute.select { |fact| fact.code_total.to_i.positive? || fact.comments_total.to_i.positive? }
  end

  def map
    collection.map do |fact|
      { id: fact.language_id, nice_name: fact.language_nice_name, name: fact.language_name,
        lines: (fact.code_total + fact.comments_total + fact.blanks_total) }
    end
  end

  private

  def execute
    empty? ? [] : query
  end

  def query
    ActivityFact.select([select_columns, language_select_colums]).joins(:language).where(with_analysis)
                .group(language_group_columns).order('code_total DESC, nice_name, name, category')
  end

  def language_group_columns
    LANAGUAGE_SELECT_COLUMNS.keys.map { |column| languages[column] }
  end

  def language_select_colums
    LANAGUAGE_SELECT_COLUMNS.map do |column, name|
      languages[column].as(name)
    end
  end
end
