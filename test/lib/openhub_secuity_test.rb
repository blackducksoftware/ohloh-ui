# frozen_string_literal: true

require 'test_helper'

class OpenhubSecurityTest < ActiveSupport::TestCase
  it 'should get the UUID for a given project' do
    VCR.use_cassette('kb') do
      uuid = OpenhubSecurity.get_uuid('rails')
      uuid.must_equal 'e45bf7f2-72ed-4a93-8958-931047ebde3b'
    end
  end
end
