# frozen_string_literal: true

require 'test_helper'

class ApiAccessTest < ActiveSupport::TestCase
  describe 'resolve_hostname' do
    it 'must get the ip address for hostname' do
      stub_constant ApiAccess, :URL, 'http://example.com/' do
        api_url = ApiAccess.api_url
        _(api_url).must_match %r{^http://\d+\.\d+\.\d+\.\d+/api/v1$}

        # Subsequent access to fisbot api
        Net::HTTP.stubs(:get_response).returns(stub(code: '200'))
        # Must use cached data.
        ApiAccess.expects(:resolve_hostname).never

        api_url = ApiAccess.api_url
        _(api_url).must_match %r{^http://\d+\.\d+\.\d+\.\d+/api/v1$}
      end
    end
  end
end
