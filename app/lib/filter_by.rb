# frozen_string_literal: true

module FilterBy
  def filterable_by(attributes)
    # Store as array, don't join yet
    @filter_attributes = attributes.collect { |attr| "lower(#{attr}) like :query" }
  end

  def filter_by(query)
    query ? where(build_sql_query(query)) : where(nil)
  end

  private

  def build_sql_query(query)
    # Join the filter attributes here when building the SQL
    filter_sql = @filter_attributes.join(' OR ')

    query.split.collect do |q|
      surround sanitize_sql([filter_sql, { query: "%#{q.downcase}%" }])
    end.join(' AND ')
  end

  def surround(string)
    "(#{string})"
  end
end

Rails.application.config.to_prepare do
  ApplicationRecord.extend FilterBy if defined?(ApplicationRecord)
end
