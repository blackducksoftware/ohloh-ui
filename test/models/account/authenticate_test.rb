require 'test_helper'

class Account::AuthenticateTest < ActiveSupport::TestCase
  fixtures :accounts

  test 'can authenticate via email' do
    Account.any_instance.stubs(:crypted_password).returns('b2ddce206f8a0734794f4c62d83810a49b45e00f')
    authenticator = Account::Authenticate.new(login: 'admin@openhub.net', password: 'test')
    assert_equal accounts(:admin), authenticator.authenticate!
  end

  test 'can authenticate via login' do
    authenticator = Account::Authenticate.new(login: 'admin', password: 'test')
    Account.any_instance.stubs(:crypted_password).returns('b2ddce206f8a0734794f4c62d83810a49b45e00f')
    assert_equal accounts(:admin), authenticator.authenticate!
  end

  test 'wrong password does not authenticate via email' do
    authenticator = Account::Authenticate.new(login: 'admin@openhub.net', password: 'wrong')
    assert_equal nil, authenticator.authenticate!
  end

  test 'wrong password does not authenticate via login' do
    authenticator = Account::Authenticate.new(login: 'admin', password: 'wrong')
    assert_equal nil, authenticator.authenticate!
  end

  test 'unknown user does not authenticate via email' do
    authenticator = Account::Authenticate.new(login: 'I am a banana!', password: 'does not matter')
    assert_equal nil, authenticator.authenticate!
  end
end
