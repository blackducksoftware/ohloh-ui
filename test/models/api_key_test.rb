require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  fixtures :accounts
  test 'defaults is called on new' do
    ApiKey.any_instance.expects(:defaults)
    create(:api_key)
  end
end
