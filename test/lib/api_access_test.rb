# frozen_string_literal: true

require 'test_helper'

describe 'ApiAccess' do
  describe 'resolve_hostname' do
    it 'must get the ip address for hostname' do
      api_access = ApiAccess.new(:code_locations)
      ip_address = api_access.send(:resolve_hostname, 'https://example.com/')
      _(ip_address).must_match /^\d+\.\d+\.\d+\.\d+$/
    end
  end
end
