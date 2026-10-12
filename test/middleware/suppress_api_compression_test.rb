# frozen_string_literal: true

require 'test_helper'

class SuppressApiCompressionTest < ActiveSupport::TestCase
  def setup
    @app = ->(_env) { [200, { 'Content-Type' => 'application/json' }, ['ok']] }
    @middleware = SuppressApiCompression.new(@app)
  end

  describe 'API paths (/api/*)' do
    it 'forces Accept-Encoding to identity so Rack::Deflater skips all compression' do
      env = { 'PATH_INFO' => '/api/v1/projects', 'HTTP_ACCEPT_ENCODING' => 'gzip, deflate, br' }
      @middleware.call(env)

      _(env['HTTP_ACCEPT_ENCODING']).must_equal 'identity'
    end

    it 'sets Content-Encoding: identity on the response' do
      env = { 'PATH_INFO' => '/api/v1/projects', 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      _status, headers, _body = @middleware.call(env)

      _(headers['Content-Encoding']).must_equal 'identity'
    end

    it 'does not overwrite an existing Content-Encoding header' do
      app_with_encoding = ->(_env) { [200, { 'Content-Encoding' => 'deflate' }, ['ok']] }
      middleware = SuppressApiCompression.new(app_with_encoding)
      env = { 'PATH_INFO' => '/api/v1/projects', 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      _status, headers, _body = middleware.call(env)

      _(headers['Content-Encoding']).must_equal 'deflate'
    end

    it 'handles nil Accept-Encoding without error' do
      env = { 'PATH_INFO' => '/api/v1/projects', 'HTTP_ACCEPT_ENCODING' => nil }
      _status, headers, _body = @middleware.call(env)

      _(headers['Content-Encoding']).must_equal 'identity'
    end

    it 'applies to the bare /api path without a trailing slash' do
      env = { 'PATH_INFO' => '/api', 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      _status, headers, _body = @middleware.call(env)

      _(headers['Content-Encoding']).must_equal 'identity'
    end

    it 'passes through the original status and body unchanged' do
      env = { 'PATH_INFO' => '/api/v1/projects', 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      status, _headers, body = @middleware.call(env)

      _(status).must_equal 200
      _(body).must_equal ['ok']
    end
  end

  describe 'non-API paths' do
    it 'does not modify Accept-Encoding' do
      env = { 'PATH_INFO' => '/projects', 'HTTP_ACCEPT_ENCODING' => 'gzip, deflate' }
      @middleware.call(env)

      _(env['HTTP_ACCEPT_ENCODING']).must_equal 'gzip, deflate'
    end

    it 'does not set Content-Encoding on the response' do
      env = { 'PATH_INFO' => '/projects', 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      _status, headers, _body = @middleware.call(env)

      _(headers['Content-Encoding']).must_be_nil
    end

    it 'does not affect paths that begin with api but are not under /api/' do
      env = { 'PATH_INFO' => '/apikey', 'HTTP_ACCEPT_ENCODING' => 'gzip' }
      @middleware.call(env)

      _(env['HTTP_ACCEPT_ENCODING']).must_equal 'gzip'
    end
  end
end
