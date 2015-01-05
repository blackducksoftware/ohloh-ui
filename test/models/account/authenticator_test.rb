require 'test_helper'

class Account::AuthenticatorTest < ActiveSupport::TestCase
  test 'can authenticate via email' do
    authenticator = Account::Authenticator.new(login: 'admin@openhub.net', password: 'test')
    assert_equal true, authenticator.authenticated?
    assert_equal accounts(:admin), authenticator.account
  end

  test 'can authenticate via login' do
    authenticator = Account::Authenticator.new(login: 'admin', password: 'test')
    assert_equal true, authenticator.authenticated?
    assert_equal accounts(:admin), authenticator.account
  end

  test 'wrong password does not authenticate via email' do
    authenticator = Account::Authenticator.new(login: 'admin@openhub.net', password: 'wrong')
    assert_equal false, authenticator.authenticated?
    assert_equal nil, authenticator.account
  end

  test 'wrong password does not authenticate via login' do
    authenticator = Account::Authenticator.new(login: 'admin', password: 'wrong')
    assert_equal false, authenticator.authenticated?
    assert_equal nil, authenticator.account
  end

  test 'unknown user does not authenticate via email' do
    authenticator = Account::Authenticator.new(login: 'I am a banana!', password: 'does not matter')
    assert_equal false, authenticator.authenticated?
    assert_equal nil, authenticator.account
  end
end
