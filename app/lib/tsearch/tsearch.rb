# frozen_string_literal: true

module Tsearch
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    # update_columns doesn't support string interpolation so we have used update_all.
    # Why interpolation? because the entire set_vector result is a postgres function
    # that has to be evaluated while updating the vector column but in update_columns
    # it was treated as a string instead of function
    after_save do |record|
      record.class.where(id: record)
            .update_all("vector = #{set_vector(record)}, popularity_factor = #{record.searchable_factor}")
    end

    class << self
      def tsearch(query, sort_by = nil)
        (query.present? ? where(tsearch_where_clause(query)) : all).tsearch_sort_by(query, sort_by)
      end

      def tsearch_sort_by(query, sort_by)
        if sort_by.blank? && query.present?
          order("greatest(#{tsearch_rank('simple', query)},
                #{tsearch_rank('default', query)})*(1+popularity_factor) desc")
        elsif sort_by.blank?
          order(popularity_factor: :desc)
        else
          send(sort_by)
        end
      end

      private

      def tsearch_where_clause(query)
        "#{tsearch_where_condition('simple', query)} or #{tsearch_where_condition('default', query)}"
      end

      def tsearch_where_condition(dictionary, query)
        "(#{tsearch_vector} @@ #{tsearch_query(dictionary, query)})"
      end

      def tsearch_vector
        "(#{table_name}.vector)"
      end

      def tsearch_query(dictionary, query)
        "(to_tsquery('#{dictionary}', '#{query_parser(query)}'))"
      end

      def tsearch_rank(dictionary, query)
        "(ts_rank(#{tsearch_vector}, #{tsearch_query(dictionary, query)}))"
      end

      def query_parser(query)
        return "'' ' || ' #{query.tr("'", ' ')} ' || ' ''" unless query =~ /[-.\/]/

        "''#{query.gsub(/[-.'\/]/, '-' => 'dssh', '.' => 'dtt', '/' => ' ')}'' | ''#{query.delete("'")}''"
      end
    end

    private

    def set_vector(record)
      [].tap do |set_weight|
        record.searchable_vector.each do |weight, attr_value|
          set_weight << "setweight(to_tsvector(coalesce('#{clean_attr_value(attr_value)}')), '#{weight.upcase}')"
        end
      end.join(' ||')
    end

    def clean_attr_value(attr_value)
      attr_value.to_s.gsub(/['?\\:]/, ' ')
    end
  end
  # rubocop:enable Metrics/BlockLength
end
