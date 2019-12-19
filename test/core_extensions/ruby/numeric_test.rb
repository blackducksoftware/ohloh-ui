# frozen_string_literal: true

require 'test_helper'

class NumericTest < ActiveSupport::TestCase
  it 'to_human' do
    1.to_human.must_equal '1'
    4_500.to_human.must_equal '4.5K'
    7_890_123.to_human.must_equal '7.89M'
    67_890_123_000.to_human.must_equal '67.8G'
    123_456_789_000_765.to_human.must_equal '123T'
  end
end
