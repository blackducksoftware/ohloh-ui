module Tsearch
  extend ActiveSupport::Concern

  included do
    include PgSearch
    pg_search_scope :search_by_vector, against: :vector, using: { tsearch: { tsvector_column: 'vector' } },
                                       ranked_by: ':tsearch*(1+popularity_factor)'

    # update_columns doesn't support string interpolation so we have used update_all.
    # Why interpolation? because the entire set_vector result is a postgres function
    # that has to be evaluated while updating the vector column but in update_columns
    # it was treated as a string instead of function
    after_save do |record|
      record.class.where(id: record)
        .update_all("vector = #{set_vector(record)}, popularity_factor = #{record.searchable_factor}")
    end

    class << self
      def tsearch(query, sort_by)
        (query ? search_by_vector(query) : all).torder(query, sort_by)
      end

      def torder(query, sort_by)
        return order('') if sort_by.blank? && query.present?
        return order(popularity_factor: :desc) if sort_by.blank?
        send(sort_by)
      end
    end

    private

    def set_vector(record)
      [].tap do |set_weight|
        record.searchable_vector.each do |weight, attr_value|
          attr_value.to_s.gsub!(/['?\\:]/, ' ')
          set_weight << "setweight(to_tsvector(coalesce('#{attr_value}')), '#{weight.upcase}')"
        end
      end.join(' ||')
    end
  end
end
