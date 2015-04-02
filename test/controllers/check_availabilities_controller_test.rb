require 'test_helper'

describe 'CheckAvailabilitiesController' do
  describe 'account' do
    it 'should return true when account is present' do
      create(:account, login: 'robin')
      xhr :get, :account, query: 'RoBiN'

      response.body.must_equal 'true'
    end

    it 'should return false when account is not present' do
      xhr :get, :account, query: 'test'

      response.body.must_equal 'false'
    end
  end
end
