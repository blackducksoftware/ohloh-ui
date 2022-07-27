# frozen_string_literal: true

require 'test_helper'

class SpamControllerTest < ActionController::TestCase
  describe 'redirect_to_first_potential_spammer' do
    let(:account) { create(:account) }
    let(:admin) { create(:admin) }

    it 'regular user should not be able to access' do
      login_as account
      get :redirect_to_first_potential_spammer
      assert_response :unauthorized
    end

    it 'should redirect to an account if there is one in oh.potential_spammers' do
      login_as admin
      sql = 'SELECT id FROM oh.potential_spammers LIMIT 1;'
      result = ActiveRecord::Base.connection.execute(sql)
      if result.num_tuples.positive?
        account = Account.find(result[0]['id'])
        get :redirect_to_first_potential_spammer
        assert_redirected_to account_path(account.login)
      else
        get :redirect_to_first_potential_spammer
        assert_redirected_to admin_path
      end
    end

    it 'should redirect to admin_path if there is nothing in oh.potential_spammers' do
      login_as admin
      sql = <<-SQL.squish
            DELETE FROM OH.MARKUPS;
            DELETE FROM oh.reviewed_not_spammers;
      SQL
      ActiveRecord::Base.connection.execute(sql)
      get :redirect_to_first_potential_spammer
      assert_redirected_to admin_path
    end
  end
end
