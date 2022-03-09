# frozen_string_literal: true

module FilterBy
  def filterable_by(attributes)
    @filter_attributes = attributes.collect { |attr| "lower(#{attr}) like :query" }.join(' OR ')
  end

  def filter_by(query)
    query ? where(build_sql_query(query)) : where(nil)
  end

  private

  def build_sql_query(query)
    query.split.collect do |q|
      surround sanitize_sql([@filter_attributes, { query: "%#{q.downcase}%" }])
    end.join(' AND ')
  end

  def surround(string)
    "(#{string})"
  end
end

ApplicationRecord.extend FilterBy
