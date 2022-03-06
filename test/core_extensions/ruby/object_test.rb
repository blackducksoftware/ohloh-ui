# frozen_string_literal: true

require 'test_helper'

class ObjectTest < ActiveSupport::TestCase
  describe 'to_bool' do
    it 'truthy values are true' do
      _(true.to_bool).must_equal true
    end

    it 'falsey values are false' do
      _(nil.to_bool).must_equal false
      _(false.to_bool).must_equal false
    end
  end
end
