# frozen_string_literal: true

require 'test_helper'

class NumericTest < ActiveSupport::TestCase
  it 'to_human' do
    _(1.to_human).must_equal '1'
    _(4_500.to_human).must_equal '4.5K'
    _(7_890_123.to_human).must_equal '7.89M'
    _(67_890_123_000.to_human).must_equal '67.8G'
    _(123_456_789_000_765.to_human).must_equal '123T'
  end
end
