# frozen_string_literal: true

require 'test_helper'

class ApiAccessTest < ActiveSupport::TestCase
  describe 'resolve_hostname' do
    it 'must get the ip address for hostname' do
      stub_constant ApiAccess, :URL, 'http://example.com/' do
        api_access = ApiAccess.new(:code_locations)

        api_url = api_access.send(:api_url)
        _(api_url).must_match %r{^http://\d+\.\d+\.\d+\.\d+/api/v1$}

        # Subsequent access to fisbot api
        api_access = ApiAccess.new(:code_locations)
        Net::HTTP.stubs(:get_response).returns(stub(code: '200'))
        # We must use cached data.
        api_access.expects(:resolve_hostname).never

        api_url = api_access.send(:api_url)
        _(api_url).must_match %r{^http://\d+\.\d+\.\d+\.\d+/api/v1$}
      end
    end
  end
end
