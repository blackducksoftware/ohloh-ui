# frozen_string_literal: true

require 'test_helper'

class ApiAccessTest < ActiveSupport::TestCase
  describe 'resolve_hostname' do
    it 'must get the ip address for hostname' do
      stub_constant ApiAccess, :URL, 'https://openhub.net/' do
        Rails.env.stubs(:test?).returns(false)
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

  describe 'available?' do
    it 'must be truthy when fisbot api is accessible' do
      stub_request(:get, "#{ApiAccess::URL}/health").to_return(status: 200)

      assert ApiAccess.available?
    end

    it 'must be falsy when fisbot api is not accessible' do
      Net::HTTP.stubs(:get_response).raises(Errno::ECONNREFUSED) # prevent VCR takeover.

      assert_not ApiAccess.available?
    end
  end
end
