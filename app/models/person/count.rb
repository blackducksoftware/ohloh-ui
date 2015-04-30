module Person::Count
  module_function

  # FIXME: Replace Person.count_unclaimed
  def unclaimed_by(query = nil, find_by = nil)
    return unclaimed if query.blank?
    Person.unclaimed_people(q: query, find_by: find_by).length
  end

  def claimed
    Person.where.not(account_id: nil).count
  end

  def unclaimed
    Person.count('distinct name_id')
  end
end
