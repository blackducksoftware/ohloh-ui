require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  it 'should return claimed persons when availabale when page is not given' do
    claimed_persons = Person.claimed

    claimed_persons.length.must_equal 7
    account_ids = claimed_persons.map(&:account_id).compact
    account_ids.size.must_equal 7
  end

  it 'should return claimed persons when availabale when page is 2' do
    Person.stubs(:per_page).returns(5)
    claimed_persons = Person.claimed(2)

    claimed_persons.length.must_equal 2
    account_ids = claimed_persons.map(&:account_id).compact
    account_ids.size.must_equal 2
  end
end
