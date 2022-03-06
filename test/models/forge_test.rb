# frozen_string_literal: true

require 'test_helper'

class ForgeTest < ActiveSupport::TestCase
  it 'should throw an exception if base class implementation of match is invoked' do
    _(proc { Forge.new.match('http://cnn.com') }).must_raise RuntimeError
  end

  it 'by default returns a nil json_api_url' do
    _(Forge.new.json_api_url('anything')).must_be_nil
  end
end
