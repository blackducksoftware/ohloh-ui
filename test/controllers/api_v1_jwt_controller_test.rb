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

  describe 'JWT lockout behavior' do
    it 'increments failed attempts on wrong password' do
      post :create, params: { username: @account.login, password: 'wrong' }
      assert_response :unauthorized
      @account.reload
      assert_equal 1, @account.jwt_failed_attempts
    end

    it 'locks account after 5 failed attempts' do
      5.times do
        post :create, params: { username: @account.login, password: 'wrong' }
        assert_response :unauthorized
      end
      @account.reload
      assert @account.jwt_locked_until > Time.current
    end

    it 'returns 401 with correct password while locked' do
      @account.update!(jwt_locked_until: 30.minutes.from_now)
      post :create, params: { username: @account.login, password: @account.password }
      assert_response :unauthorized
      assert_equal 'Not Authorized', response.body
    end

    it 'allows login after lock expires' do
      @account.update!(jwt_locked_until: 1.second.ago)
      post :create, params: { username: @account.login, password: @account.password }
      assert_response :ok
    end

    it 'does not increment for unknown username' do
      initial_count = @account.jwt_failed_attempts
      post :create, params: { username: 'nonexistent_user_xyz', password: 'wrong' }
      assert_response :unauthorized
      @account.reload
      assert_equal initial_count, @account.jwt_failed_attempts
    end

    it 'resets failed attempts on successful login' do
      @account.update!(jwt_failed_attempts: 3, jwt_failed_attempts_window_start: 5.minutes.ago)
      post :create, params: { username: @account.login, password: @account.password }
      assert_response :ok
      @account.reload
      assert_equal 0, @account.jwt_failed_attempts
      assert_nil @account.jwt_failed_attempts_window_start
    end

    it 'sends email when account is locked' do
      ActionMailer::Base.deliveries.clear
      5.times do
        post :create, params: { username: @account.login, password: 'wrong' }
      end
      assert_equal 1, ActionMailer::Base.deliveries.count
      email = ActionMailer::Base.deliveries.last
      assert_equal @account.email, email.to[0]
      assert_match(/temporarily locked/, email.subject)
    end

    it 'resets window and count after expiry' do
      @account.update!(
        jwt_failed_attempts: 4,
        jwt_failed_attempts_window_start: 31.minutes.ago
      )
      # Next failure should start a fresh window with count = 1
      post :create, params: { username: @account.login, password: 'wrong' }
      assert_response :unauthorized
      @account.reload
      assert_equal 1, @account.jwt_failed_attempts
      # Window should be recent
      assert @account.jwt_failed_attempts_window_start > 1.minute.ago
    end

    it 'returns same error for locked vs invalid password' do
      # Lock the account
      @account.update!(jwt_locked_until: 30.minutes.from_now)
      post :create, params: { username: @account.login, password: @account.password }
      locked_response = response.body
      assert_response :unauthorized

      # Unauthorized response should be generic
      assert_equal 'Not Authorized', locked_response
    end
  end
end
