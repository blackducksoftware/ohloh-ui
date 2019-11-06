# frozen_string_literal: true

# rubocop: disable InverseOf

class LanguageFact < ActiveRecord::Base
  belongs_to :language
  belongs_to :all_month, primary_key: :month, foreign_key: :month

  class << self
    def report(language, options = {})
      start_month = options[:start_month] || Time.current.years_ago(10)
      end_month = options[:end_month] || Time.current.months_ago(1)
      measure = options[:measure] || 'loc_changed'

      AllMonth.joins(join_clause(language.id))
              .select(select_clause(measure))
              .where(month: start_month..end_month)
              .order(:month)
    end

    private

    def all_months
      AllMonth.arel_table
    end

    def join_clause(language_id)
      all_months.join(arel_table, Arel::Nodes::OuterJoin)
                .on(
                  all_months[:month].eq(arel_table[:month])
                 .and(arel_table[:language_id].eq(language_id))
                )
                .join_sources
    end

    def select_clause(measure)
      "all_months.month as month, \
      language_facts.#{measure} as #{measure},
      CASE WHEN COALESCE(language_facts.#{measure}, 0) = 0
      THEN 0
      ELSE
      ((language_facts.#{measure})::float / (#{measure_sum(measure)})) * 100
      END AS percent"
    end

    def measure_sum(measure)
      LanguageFact.select(arel_table[measure].sum)
                  .where('language_facts.month = all_months.month').to_sql
    end
  end
end

# rubocop: enable InverseOf
