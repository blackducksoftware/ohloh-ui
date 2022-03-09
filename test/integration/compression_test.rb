# frozen_string_literal: true

require 'test_helper'

class CompressionTest < ActionDispatch::IntegrationTest
  describe 'when a visitor has a browser that supports compression' do
    it 'responds with a deflate/gzip content-encoding' do
      skip('FIXME: rack middleware seems to be bypassed in tests')
      # 'https://github.com/blackducksoftware/ohloh-ui/pull/842/commits/59033a6c543b76e4e9c47db297d742080e3ea228'
      ['deflate', 'gzip', 'deflate,gzip', 'gzip,deflate'].each do |compression_method|
        get root_path, headers: { 'HTTP_ACCEPT_ENCODING' => compression_method }
        assert_includes %w[deflate gzip], response.headers['Content-Encoding']
      end
    end
  end

  describe 'when a visitor\'s browser does not support compression' do
    it 'doesn\'t responds with a deflate/gzip content-encoding' do
      get root_path
      _(response.headers['Content-Encoding']).must_be_nil
    end
  end
end
