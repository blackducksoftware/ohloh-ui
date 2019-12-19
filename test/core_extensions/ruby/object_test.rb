# frozen_string_literal: true

require 'test_helper'

class ObjectTest < ActiveSupport::TestCase
  describe 'to_bool' do
    it 'truthy values are true' do
      true.to_bool.must_equal true
    end

    it 'falsey values are false' do
      nil.to_bool.must_equal false
      false.to_bool.must_equal false
    end
  end
end
