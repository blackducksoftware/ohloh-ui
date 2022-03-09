# frozen_string_literal: true

require 'test_helper'

class StripAttributesTest < ActiveSupport::TestCase
  it 'must add strip_attributes as a class method' do
    _(Account.singleton_methods).must_include(:strip_attributes)
  end

  it 'must strip attributes during validation' do
    account = Account.new
    account.login = ' login '
    account.valid?

    _(account.login).must_equal 'login'
  end

  it 'must strip virtual attributes' do
    account = Account.new
    account.invite_code = '   code'
    account.valid?

    _(account.invite_code).must_equal 'code'
  end
end
