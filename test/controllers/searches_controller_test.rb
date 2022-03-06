# frozen_string_literal: true

require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  describe 'account' do
    it 'should return formatted account records as json' do
      account = create(:account)
      get :account, params: { term: account.login }, xhr: true

      result = JSON.parse(response.body)
      _(result.first['id']).must_equal account.login
      _(result.first['value']).must_equal account.login
    end

    it 'should redirect ro peoples page when request is not ajax' do
      get :account, params: { term: 'luck' }

      assert_redirected_to people_path(q: 'luck')
    end
  end
end
