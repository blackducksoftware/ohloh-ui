require 'test_helper'

describe 'CheckAvailabilitiesController' do
  describe 'account' do
    it 'should return account attributes when account is present' do
      create(:account, login: 'robin')
      xhr :get, :account, q: 'robin'
      result = JSON.parse(response.body)

      result['login'].must_equal 'robin'
      result['q'].must_equal 'robin'
    end

    it 'should return id as nil when account is not present' do
      xhr :get, :account, q: 'test'
      result = JSON.parse(response.body)

      result['id'].must_equal nil
      result['q'].must_equal 'test'
    end
  end
end
