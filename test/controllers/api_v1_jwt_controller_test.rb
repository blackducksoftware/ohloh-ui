# frozen_string_literal: true

require 'test_helper'
require 'jwt_helper'

class Api::V1::JwtControllerTest < ActionController::TestCase
  include JwtHelper
  before do
    @account = create(:account)
    ENV['JWT_SECRET_API_KEY'] = Faker::Alphanumeric.alpha(number: 5)
  end

  describe 'create' do
    it 'should return a valid JWT' do
      post :create, params: { username: @account.login, password: @account.password }
      _(response).must_be :successful?
      JWT_decoded = decode_jwt(response.body)
      _(JWT_decoded.login).must_equal @account.login
    end

    it 'should return errors if given a bad user' do
      post :create, params: { username: 'jibberish', password: @account.password }
      assert_response :unauthorized
    end

    it 'should return errors if given a bad password' do
      post :create, params: { username: @account.login, password: 'jibberish' }
      assert_response :unauthorized
    end

    it 'should return errors if not given a user' do
      post :create, params: { password: @account.password }
      assert_response :bad_request
    end

    it 'should return errors if not given a password' do
      post :create, params: { username: @account.login }
      assert_response :bad_request
    end
  end
end
