require 'test_helper'

class LoginFormatterTest < ActiveSupport::TestCase
  describe 'sanitized_and_unique' do
    it 'must prefix numeric login values with text' do
      login = '42'
      sanitized_login = Account::LoginFormatter.new(login).sanitized_and_unique
      sanitized_login.must_match(/\w{3}#{ login }/)
    end

    it 'must fix a login that is less than 3 chars long' do
      login = 'ex'
      sanitized_login = Account::LoginFormatter.new(login).sanitized_and_unique
      sanitized_login.must_match(/#{ login }\d{1,3}/)
    end

    it 'must return a value that does not match an existing account.login' do
      account = create(:account)
      login = account.login
      sanitized_login = Account::LoginFormatter.new(login).sanitized_and_unique
      sanitized_login.must_match(/#{ login }\d{1,3}/)
    end

    it 'must return a value that does not match an existing account.login case insensitively' do
      account = create(:account)
      login = account.login.upcase
      sanitized_login = Account::LoginFormatter.new(login).sanitized_and_unique
      sanitized_login.must_match(/#{ login }\d{1,3}/)
    end
  end
end
