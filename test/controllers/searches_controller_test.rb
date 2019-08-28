# frozen_string_literal: true

require 'test_helper'

describe 'SearchesController' do
  describe 'account' do
    it 'should return formatted account records as json' do
      account = create(:account)
      xhr :get, :account, term: account.login

      result = JSON.parse(response.body)
      result.first['id'].must_equal account.login
      result.first['value'].must_equal account.login
    end

    it 'should redirect ro peoples page when request is not ajax' do
      get :account, term: 'luck'

      must_redirect_to people_path(q: 'luck')
    end
  end
end
