require 'test_helper'

describe 'AutocompletesController' do
  describe 'account' do
    it 'should return account hash' do
      xhr :get, :account, term: 'luck'

      result = JSON.parse(response.body)
      result.first['login'].must_equal 'user'
      result.first['value'].must_equal 'user'
      result.first['name'].must_equal 'user Luckey'
    end
  end
end
