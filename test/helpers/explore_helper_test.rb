# frozen_string_literal: true

require 'test_helper'

class ExploreHelperTest < ActiveSupport::TestCase
  include ExploreHelper

  describe 'scale_to' do
    it 'should return scaled value with two arguments' do
      _(scale_to(94)).must_equal 100
    end

    it 'should return scaled value with one argument' do
      _(scale_to(94, 1000)).must_equal 1000
    end
  end
end
