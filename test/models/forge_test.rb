# frozen_string_literal: true

require 'test_helper'

class ForgeTest < ActiveSupport::TestCase
  it 'should throw an exception if base class implementation of match is invoked' do
    proc { Forge.new.match('http://cnn.com') }.must_raise RuntimeError
  end

  it 'by default returns a nil json_api_url' do
    assert_nil Forge.new.json_api_url('anything')
  end
end
