class TsearchHooks
  def after_save(record)
    Person.where(id: record).update_all("vector = #{vector(record)}, popularity_factor = #{record.searchable_factor}")
  end

  def vector(record)
    weighted_sql = []
    record.searchable_vector.each do |weight, attr_value|
      attr_value.gsub!(/['?\\:]/, ' ')
      weighted_sql << "setweight(to_tsvector(coalesce('#{attr_value}')), '#{weight.upcase}')"
    end
    weighted_sql.join(' ||')
  end
end
