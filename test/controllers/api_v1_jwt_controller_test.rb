# frozen_string_literal: true

require 'test_helper'
require 'jwt_helper'

describe 'Api::V1::JwtControllerTest' do
    include JWTHelper

    before do
        @account = create(:account)
      end

    describe 'create' do

        it 'should return a valid JWT' do
            post(
                :create,
                username: @account.login,
                password: @account.password,
            )
            response.must_be :success?

            JWT_decoded = decode_jwt(response.body)
            JWT_decoded.login.must_equal @account.login
        end

        it 'should return errors if given a bad user' do
            post(
                :create,
                username: 'jibberish',
                password: @account.password,
            )
            assert_response 401
        end

        it 'should return errors if given a bad password' do
            post(
                :create,
                username: @account.login,
                password: 'jibberish',
            )
            assert_response 401
        end

        it 'should return errors if not given a user' do
            post(
                :create,
                password: @account.password
            )
            assert_response 401
        end

        it 'should return errors if not given a password' do
            post(
                :create,
                username: @account.login
            )
            assert_response 401
        end
    end
end