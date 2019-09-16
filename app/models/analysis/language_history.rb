# frozen_string_literal: true

class Analysis::LanguageHistory < Analysis::QueryBase
  arel_tables :all_month, :activity_fact, :language

  def execute
    AllMonth.select(select_columns).joins(joins_clause).joins(languages_joins).where(within_date)
            .group(group_clause).order(languages[:nice_name], month)
  end

  private

  def group_clause
    [month, languages[:nice_name], languages[:name]]
  end

  def select_columns
    [month, languages[:nice_name].as('language'), languages[:name].as('language_name'), super]
  end

  def languages_joins
    activity_facts.join(languages).on(activity_facts[:language_id].eq(languages[:id])).join_sources
  end

  def start_date
    truncate_date(@start_date)
  end

  def end_date
    truncate_date(@end_date)
  end
end
