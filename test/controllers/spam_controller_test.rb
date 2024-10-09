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
      markup = create(:markup, raw: 'https://foobar')
      account.update!(about_markup_id: markup.id)

      get :redirect_to_first_potential_spammer
      assert_redirected_to account_path(account.login)
    end

    it 'should redirect to admin path if there is nothing in oh.potential_spammers' do
      login_as admin
      sql = <<-SQL.squish
            DELETE FROM OH.MARKUPS;
            DELETE FROM oh.reviewed_non_spammers;
      SQL
      ActiveRecord::Base.connection.execute(sql)
      get :redirect_to_first_potential_spammer
      assert_redirected_to oh_admin_root_path
    end
  end
end
