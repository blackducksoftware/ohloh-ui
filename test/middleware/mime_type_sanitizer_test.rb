# frozen_string_literal: true

require 'test_helper'

class MimeTypeSanitizerTest < ActiveSupport::TestCase
  def setup
    @app = ->(_env) { [200, { 'Content-Type' => 'text/html' }, ['OK']] }
    @middleware = MimeTypeSanitizer.new(@app)
  end

  describe 'Accept header validation' do
    it 'rejects bare asterisk Accept header' do
      env = { 'HTTP_ACCEPT' => '*' }
      status, headers, body = @middleware.call(env)

      _(status).must_equal 406
      _(headers['Content-Type']).must_equal 'text/plain'
      _(body.first).must_include 'Invalid Accept header'
    end

    it 'allows */* Accept header' do
      env = { 'HTTP_ACCEPT' => '*/*' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'allows valid Accept header with single type' do
      env = { 'HTTP_ACCEPT' => 'text/html' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'allows valid Accept header with multiple types' do
      env = { 'HTTP_ACCEPT' => 'text/html, application/json, */*' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'allows wildcard subtype like text/*' do
      env = { 'HTTP_ACCEPT' => 'text/*' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'allows Accept header with quality values' do
      env = { 'HTTP_ACCEPT' => 'text/html;q=0.9, application/json;q=0.8' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'rejects invalid Accept header format' do
      env = { 'HTTP_ACCEPT' => 'invalid' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 406
    end

    it 'rejects Accept header with bare slash' do
      env = { 'HTTP_ACCEPT' => '/' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 406
    end

    it 'allows empty Accept header' do
      env = {}
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end
  end

  describe 'Content-Type header validation' do
    it 'rejects bare asterisk Content-Type header' do
      env = { 'CONTENT_TYPE' => '*' }
      status, headers, body = @middleware.call(env)

      _(status).must_equal 406
      _(headers['Content-Type']).must_equal 'text/plain'
      _(body.first).must_include 'Invalid Content-Type header'
    end

    it 'allows valid Content-Type header' do
      env = { 'CONTENT_TYPE' => 'application/json' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'allows Content-Type with charset' do
      env = { 'CONTENT_TYPE' => 'application/json; charset=utf-8' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'allows Content-Type with boundary' do
      env = { 'CONTENT_TYPE' => 'multipart/form-data; boundary=----WebKitFormBoundary' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'rejects Content-Type with bare slash' do
      env = { 'CONTENT_TYPE' => '/' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 406
    end

    it 'rejects invalid Content-Type format' do
      env = { 'CONTENT_TYPE' => 'invalid' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 406
    end

    it 'allows empty Content-Type' do
      env = {}
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end
  end

  describe 'format parameter validation' do
    it 'rejects format=* in query string' do
      env = { 'QUERY_STRING' => 'format=*' }
      status, headers, body = @middleware.call(env)

      _(status).must_equal 406
      _(headers['Content-Type']).must_equal 'text/plain'
      _(body.first).must_include 'Invalid format parameter'
    end

    it 'rejects format parameter containing asterisk' do
      env = { 'QUERY_STRING' => 'format=html*' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 406
    end

    it 'allows valid format parameter' do
      env = { 'QUERY_STRING' => 'format=json' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'allows format parameter with other params' do
      env = { 'QUERY_STRING' => 'id=123&format=xml&page=2' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'allows empty query string' do
      env = {}
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end
  end

  describe 'combined validation scenarios' do
    it 'rejects request with multiple invalid headers' do
      env = {
        'HTTP_ACCEPT' => '*',
        'CONTENT_TYPE' => '*',
        'QUERY_STRING' => 'format=*'
      }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 406
    end

    it 'allows request with all valid headers' do
      env = {
        'HTTP_ACCEPT' => 'text/html, application/json',
        'CONTENT_TYPE' => 'application/x-www-form-urlencoded',
        'QUERY_STRING' => 'format=html'
      }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'validates Accept before Content-Type' do
      env = {
        'HTTP_ACCEPT' => '*',
        'CONTENT_TYPE' => 'application/json'
      }
      status, _headers, body = @middleware.call(env)

      _(status).must_equal 406
      _(body.first).must_include 'Accept header'
    end
  end

  describe 'edge cases' do
    it 'handles Accept header with spaces' do
      env = { 'HTTP_ACCEPT' => '  text/html  ,  application/json  ' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'handles special characters in MIME types' do
      env = { 'HTTP_ACCEPT' => 'application/vnd.api+json' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end

    it 'handles MIME types with dots and dashes' do
      env = { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' }
      status, _headers, _body = @middleware.call(env)

      _(status).must_equal 200
    end
  end
end
