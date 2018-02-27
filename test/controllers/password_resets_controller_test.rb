require 'test_helper'

describe 'PasswordResetsController' do
  describe 'create' do
    it 'must send the password reset email' do
      account = create(:account)

      post :create, password: { email: account.email }

      email = ActionMailer::Base.deliveries.last
      email.subject.must_match I18n.t('clearance.models.clearance_mailer.change_password')
    end
  end

  describe 'update' do
    it 'find the user for update' do
      Account.any_instance.stubs(:update_password)

      account = create(:account)
      account.update!(confirmation_token: Clearance::Token.new)

      put :update, user_id: account.login, token: account.confirmation_token,
                   password_reset: { password: Faker::Internet.password }

      assigns(:user).id.must_equal account.id
    end

    it 'must render error when token is expired' do
      Account.any_instance.stubs(:update_password)

      account = create(:account)
      account.update!(confirmation_token: Clearance::Token.new)

      put :update, user_id: account.login, token: Faker::Internet.password,
                   password_reset: { password: Faker::Internet.password }

      must_render_template 'passwords/new'
      flash[:error].must_equal I18n.t('passwords.token_expired_error')
    end
  end
end
