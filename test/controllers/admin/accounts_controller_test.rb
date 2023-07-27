# frozen_string_literal: true

require 'test_helper'

class Admin::AccountsControllerTest < ActionController::TestCase
  let(:admin) { create(:admin) }
  let(:account) { create(:account) }

  before do
    login_as admin
  end

  it 'should render index template' do
    get :reset_password, params: { id: account.login }
    assert_equal flash[:notice], "Account #{account.email}'s password has been changed."
    must_redirect_to admin_account_path_path(account)
  end
end
