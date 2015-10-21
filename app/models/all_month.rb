class AllMonth < ActiveRecord::Base
  attr_accessor :ticks

  class << self
    def all_attributes(start_date, end_date)
      query = sanitize_sql(["SELECT month AS this_month, 0 AS count
                               FROM all_months
                               WHERE month BETWEEN ? AND ?", start_date, end_date])

      connection.execute(query).to_a
    end
  end
end
