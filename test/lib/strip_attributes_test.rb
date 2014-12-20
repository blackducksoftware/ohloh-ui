require 'test_helper'

class StripAttributesTest < ActiveSupport::TestCase
  test 'must add strip_attributes as a class method' do
    assert_equal true, Account.singleton_methods.include?(:strip_attributes)
  end

  test 'must strip attributes during validation' do
    account = Account.new
    account.login = ' login '
    account.valid?

    assert_equal 'login', account.login
  end

  test 'must strip virtual attributes' do
    account = Account.new
    account.invite_code = '   code'
    account.valid?

    assert_equal 'code', account.invite_code
  end
end
