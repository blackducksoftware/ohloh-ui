module Person::Cached
  module_function

  def claimed_count
    Rails.cache.fetch('person_claimed_count', expires_in: 15.minutes) do
      Person.where.not(account_id: nil).count
    end
  end

  def unclaimed_count
    Rails.cache.fetch('person_unclaimed_count', expires_in: 15.minutes) do
      Person.count('distinct name_id')
    end
  end
end
