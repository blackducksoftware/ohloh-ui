# frozen_string_literal: true

require 'test_helper'

class ApiAccessTest < ActiveSupport::TestCase
  after do
    ApiAccess.send :reset_cache_data
  end

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

  describe 'set_fis_ip_url' do
    it 'must resolve url to ip address' do
      loop_ip_address = '127.0.0.1'
      Resolv.stubs(:getaddress).returns(loop_ip_address)

      ApiAccess.send :set_fis_ip_url

      _(ApiAccess.fis_ip_url).must_equal "http://#{loop_ip_address}"
    end
  end

  describe 'uptime_check_expired?' do
    it 'must be true when cache has expired' do
      duration = (ApiAccess::CACHE_DURATION + 1.minute).to_i / 60
      ApiAccess.uptime_verified_time = Time.current.advance(minutes: -duration)

      ApiAccess.send(:uptime_check_expired?).must_equal true
    end

    it 'must be false when cache has not expired' do
      duration = (ApiAccess::CACHE_DURATION - 2.minutes).to_i / 60
      ApiAccess.uptime_verified_time = Time.current.advance(minutes: -duration)

      ApiAccess.send(:uptime_check_expired?).must_equal false
    end
  end
end
