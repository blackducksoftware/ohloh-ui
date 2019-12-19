# frozen_string_literal: true

require 'test_helper'

class Person::CountTest < ActiveSupport::TestCase
  describe '#unclaimed_by' do
    it 'must return unclaimed people count when no query' do
      create(:person)
      create(:person)
      Person::Count.unclaimed_by.must_equal 2
    end

    it 'must return count of matching unclaimed people' do
      create(:person, effective_name: 'joe')
      Person::Count.unclaimed_by('joe').must_equal 1
    end

    it 'must return 0 when no unclaimed people are found' do
      create(:person)
      Person::Count.unclaimed_by('robinhood').must_equal 0
    end

    it 'must return count of unclaimed people matching given value and column name' do
      Person::Count.unclaimed_by('test@test.com', 'email').must_equal 0

      ea = EmailAddress.create!(address: 'test@test.com')
      name_fact = create(:name_fact, email_address_ids: "{#{ea.id}}")
      create(:person, name_fact: name_fact)

      Person::Count.unclaimed_by('test@test.com', 'email').must_equal 1
    end
  end

  describe '#claimed' do
    it 'must return count of people with accounts' do
      project = create(:project)
      Person.count.must_equal 3
      Person.where.not(account_id: nil).count.must_equal 3
      Person::Count.claimed.must_equal 3

      name = create(:name_with_fact)
      Person.first.update!(name: name, name_fact: NameFact.find_by(name: name),
                           project: project, account_id: nil)

      Person::Count.claimed.must_equal 4
    end
  end

  describe '#unclaimed' do
    it 'must return distinct count of people with name_id' do
      2.times { create(:person) }
      Person.count('distinct name_id').must_equal 2
      Person::Count.unclaimed.must_equal 2
    end
  end
end
