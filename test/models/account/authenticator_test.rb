require 'test_helper'

class Account::AuthenticatorTest < ActiveSupport::TestCase
  it 'can authenticate via email' do
    account = create(:account, password: 'password')
    authenticator = Account::Authenticator.new(login: account.email, password: 'password')
    authenticator.must_be :authenticated?
    authenticator.account.must_equal account
  end

  it 'can authenticate via login' do
    account = create(:account, password: 'password')
    authenticator = Account::Authenticator.new(login: account.login, password: 'password')
    authenticator.must_be :authenticated?
    authenticator.account.must_equal account
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

  it 'should not authenicate ananymous accounts' do
    ohloh_slave = Account.hamster
    anonymous = create(:account, password: 'password', login: 'anonymous_coward', email: 'anon@openhub.net')
    crawler = create(:account, password: 'password', login: 'uber_data_crawler', email: 'uber_data_crawler@ohloh.net')

    authenticator = Account::Authenticator.new(login: ohloh_slave.login, password: 'password')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil

    authenticator = Account::Authenticator.new(login: ohloh_slave.email, password: 'password')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil

    authenticator = Account::Authenticator.new(login: anonymous.login, password: 'password')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil

    authenticator = Account::Authenticator.new(login: anonymous.email, password: 'password')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil

    authenticator = Account::Authenticator.new(login: crawler.login, password: 'password')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil

    authenticator = Account::Authenticator.new(login: crawler.email, password: 'password')
    authenticator.wont_be :authenticated?
    authenticator.account.must_equal nil
  end
end
