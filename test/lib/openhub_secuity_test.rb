# frozen_string_literal: true

require 'test_helper'

class OpenhubSecurityTest < ActiveSupport::TestCase
  it 'should get the UUID for a given project' do
    VCR.use_cassette('kb') do
      uuid = OpenhubSecurity.get_uuid('rails')
      _(uuid).must_equal '7102004a-cf57-42d5-91c6-fcf9d4c4c576'
    end
  end
end
