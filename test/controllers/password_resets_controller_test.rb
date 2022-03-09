# frozen_string_literal: true

require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  describe 'create' do
    it 'must send the password reset email' do
      account = create(:account)

      post :create, params: { password: { email: account.email } }

      email = ActionMailer::Base.deliveries.last
      _(email.subject).must_match I18n.t('clearance.models.clearance_mailer.change_password')
    end
  end

  describe 'update' do
    it 'find the user for update' do
      Account.any_instance.stubs(:update_password)

      account = create(:account)
      account.update!(confirmation_token: Clearance::Token.new)

      put :update, params: { account_id: account.login, token: account.confirmation_token,
                             password_reset: { password: Faker::Internet.password } }

      _(assigns(:user).id).must_equal account.id
    end

    it 'must render error when token is expired' do
      Account.any_instance.stubs(:update_password)

      account = create(:account)
      account.update!(confirmation_token: Clearance::Token.new)

      put :update, params: { account_id: account.login, token: Faker::Internet.password,
                             password_reset: { password: Faker::Internet.password } }

      assert_template 'passwords/new'
      _(flash[:error]).must_equal I18n.t('passwords.token_expired_error')
    end
  end
end
