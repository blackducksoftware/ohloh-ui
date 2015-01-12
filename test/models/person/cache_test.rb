require 'test_helper'

class Person::CacheTest < ActiveSupport::TestCase
  it 'should cache person count' do
    assert_equal Person::Cached.count, Person.count
    assert Person::Cached.count > 0
    assert_no_difference 'Person::Cached.count' do
      create(:person)
    end
  end
end
