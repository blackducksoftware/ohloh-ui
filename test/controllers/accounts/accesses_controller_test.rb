require 'test_helper'

describe 'Accounts::AccessesController' do
  describe 'activate' do
    it 'should successfully activate account' do
      account = Account.create(login: 'ralph', password: 'abcdef', password_confirmation: 'abcdef',
                               email: 'ralph@mailinator.com', email_confirmation: 'ralph@mailinator.com')

      get :activate, account_id: account.to_param, code: account.activation_code

      must_redirect_to account_path(account)
      flash[:success].must_equal I18n.t('accounts.accesses.activate.success')
      session[:account].must_equal account.id
    end

    it 'should redirect to maintainance page in diabled mode' do
      ApplicationController.any_instance.stubs(:read_only_mode?).returns(true)
      account = Account.create(login: 'ralph', password: 'abcdef', password_confirmation: 'abcdef',
                               email: 'ralph@mailinator.com', email_confirmation: 'ralph@mailinator.com')
      get :activate, account_id: account.to_param, code: account.activation_code

      must_redirect_to maintenance_path
    end

    it 'should redirect already activated message' do
      account = Account.create(login: 'ralph', password: 'abcdef', password_confirmation: 'abcdef',
                               email: 'ralph@mailinator.com', email_confirmation: 'ralph@mailinator.com')
      Account::Access.new(account).activate!(account.activation_code)

      get :activate, account_id: account.to_param, code: account.activation_code

      must_redirect_to account_path(account)
      flash[:notice].must_equal I18n.t('accounts.accesses.activate.notice')
    end
  end

  describe 'make spammer' do
    let(:account) { create(:account) }
    let(:admin) { create(:admin) }

    it 'admin should be able to label a spammer' do
      login_as admin
      post :make_spammer, account_id: account.id
      must_render_template 'accounts/disabled'
      flash[:success].must_equal I18n.t('accounts.accesses.make_spammer.success', name: account.name)
    end

    it 'user should not be able to label a spammer' do
      user2 = create(:account)
      login_as account
      post :make_spammer, account_id: user2.id
      must_respond_with :unauthorized
    end

    it 'should mark an account as spammer' do
      login_as admin
      admin.level.must_equal Account::Access::ADMIN
      get :make_spammer, account_id: admin.id

      must_render_template 'accounts/disabled'
      admin.reload.level.must_equal Account::Access::SPAM
      expected = ERB::Util.html_escape(I18n.t('accounts.accesses.make_spammer.success', name: admin.name))
      flash[:success].must_equal expected
    end
  end
end
