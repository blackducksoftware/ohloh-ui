require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  fixtures :accounts
  test 'defaults are populated on new' do
    api_key = create(:api_key)
    assert ApiKey::DEFAULT_DAILY_LIMIT, api_key.daily_limit
  end
end
