require 'test_helper'

class Account::AuthenticatorTest < ActiveSupport::TestCase
  it 'can authenticate via email' do
    authenticator = Account::Authenticator.new(login: 'admin@openhub.net', password: 'test')
    authenticator.must_be :authenticated?
    authenticator.account.must_equal accounts(:admin)
  end

  it 'can authenticate via login' do
    authenticator = Account::Authenticator.new(login: 'admin', password: 'test')
    authenticator.must_be :authenticated?
    authenticator.account.must_equal accounts(:admin)
  end

  it 'wrong password does not authenticate via email' do
    authenticator = Account::Authenticator.new(login: 'admin@openhub.net', password: 'wrong')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil
  end

  it 'wrong password does not authenticate via login' do
    authenticator = Account::Authenticator.new(login: 'admin', password: 'wrong')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil
  end

  it 'unknown user does not authenticate via email' do
    authenticator = Account::Authenticator.new(login: 'I am a banana!', password: 'does not matter')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil
  end
end
