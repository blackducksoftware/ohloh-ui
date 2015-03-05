require 'test_helper'

describe 'SearchesController' do
  describe 'account' do
    it 'should return formatted account records as json' do
      xhr :get, :account, term: 'luck'

      result = JSON.parse(response.body)
      result.first['id'].must_equal 'user'
      result.first['value'].must_equal 'user'
      result.last['id'].must_equal 'privacy'
      result.last['value'].must_equal 'privacy'
    end

    it 'should redirect ro peoples page when request is not ajax' do
      get :account, term: 'luck'

      must_redirect_to people_path(q: 'luck')
    end
  end
end
