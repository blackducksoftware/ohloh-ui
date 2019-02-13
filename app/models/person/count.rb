module Person::Count
  module_function

  def unclaimed_by(query = nil, find_by = nil)
    return unclaimed if query.blank?
    Person.unclaimed_people(q: query, find_by: find_by).length
  end

  def claimed
    Person.where.not(account_id: nil).count
  end

  def unclaimed
    Rails.cache.fetch('unclaimed_people_count', expires_in: 15.minutes) do
      Person.count('distinct name_id')
    end
  end

  def total
    Rails.cache.fetch('people_total_count', expires_in: 4.hours) do
      Person.count
    end
  end
end
