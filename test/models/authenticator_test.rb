require 'test_helper'

class AuthenticatorTest < ActiveSupport::TestCase
  fixtures :accounts

  test 'can authenticate via email' do
    authenticator = Authenticator.new(login: 'admin@openhub.net', password: 'test')
    assert_equal accounts(:admin).id, authenticator.account.id
    assert_equal true, authenticator.correct_password?
  end

  test 'can authenticate via login' do
    authenticator = Authenticator.new(login: 'admin', password: 'test')
    assert_equal accounts(:admin).id, authenticator.account.id
    assert_equal true, authenticator.correct_password?
  end

  test 'wrong password does not authenticate via email' do
    authenticator = Authenticator.new(login: 'admin@openhub.net', password: 'wrong')
    assert_equal accounts(:admin).id, authenticator.account.id
    assert_equal false, authenticator.correct_password?
  end

  test 'wrong password does not authenticate via login' do
    authenticator = Authenticator.new(login: 'admin', password: 'wrong')
    assert_equal accounts(:admin).id, authenticator.account.id
    assert_equal false, authenticator.correct_password?
  end

  test 'unknown user does not authenticate via email' do
    authenticator = Authenticator.new(login: 'I am a banana!', password: 'does not matter')
    assert_equal nil, authenticator.account
    assert_equal false, authenticator.correct_password?
  end

  test 'generate_salt when called ten times gives ten different salts back' do
    salts = (0...10).map { Authenticator.generate_salt }
    assert_equal 10, salts.uniq.length
  end
end
