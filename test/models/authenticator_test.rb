require 'test_helper'

class AuthenticatorTest < ActiveSupport::TestCase
  fixtures :accounts

  it 'can authenticate via email' do
    authenticator = Authenticator.new(login: 'admin@openhub.net', password: 'test')
    authenticator.account.id.must_equal accounts(:admin).id
    authenticator.correct_password?.must_equal true
  end

  it 'can authenticate via login' do
    authenticator = Authenticator.new(login: 'admin', password: 'test')
    authenticator.account.id.must_equal accounts(:admin).id
    authenticator.correct_password?.must_equal true
  end

  it 'wrong password does not authenticate via email' do
    authenticator = Authenticator.new(login: 'admin@openhub.net', password: 'wrong')
    authenticator.account.id.must_equal accounts(:admin).id
    authenticator.correct_password?.must_equal false
  end

  it 'wrong password does not authenticate via login' do
    authenticator = Authenticator.new(login: 'admin', password: 'wrong')
    authenticator.account.id.must_equal accounts(:admin).id
    authenticator.correct_password?.must_equal false
  end

  it 'unknown user does not authenticate via email' do
    authenticator = Authenticator.new(login: 'I am a banana!', password: 'does not matter')
    authenticator.account.must_equal nil
    authenticator.correct_password?.must_equal false
  end

  it 'generate_salt when called ten times gives ten different salts back' do
    salts = (0...10).map { Authenticator.generate_salt }
    salts.uniq.length.must_equal 10
  end
end
