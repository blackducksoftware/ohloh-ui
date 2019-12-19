# frozen_string_literal: true

require 'test_helper'

class CompressionTest < ActionDispatch::IntegrationTest
  describe 'when a visitor has a browser that supports compression' do
    it 'responds with a deflate/gzip content-encoding' do
      ['deflate', 'gzip', 'deflate,gzip', 'gzip,deflate'].each do |compression_method|
        get root_path, {}, 'HTTP_ACCEPT_ENCODING' => compression_method
        assert_includes %w[deflate gzip], response.headers['Content-Encoding']
      end
    end
  end

  describe 'when a visitor\'s browser does not support compression' do
    it 'doesn\'t responds with a deflate/gzip content-encoding' do
      get root_path
      assert_nil response.headers['Content-Encoding']
    end
  end
end
