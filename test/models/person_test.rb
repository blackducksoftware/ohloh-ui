require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  let(:admin_account) { accounts(:admin) }
  let(:linux_project) { projects(:linux) }

  it 'should return claimed persons when availabale when page is not given' do
    assert_equal 7, Person.claimed.length
  end

  it 'should return claimed persons when availabale when page is 2' do
    Person.stubs(:per_page).returns(5)
    assert_equal 2, Person.claimed(2).length
  end
end
