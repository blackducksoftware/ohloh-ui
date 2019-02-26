require 'test_helper'

describe 'SessionsController' do
  describe 'create' do
    let(:password) { Faker::Internet.password }
    let(:account) { create(:account, password: password) }

    describe 'success' do
      before do
        Account.any_instance.stubs(:authenticated?).returns(true)
      end

      it 'must redirect to accounts/me after login' do
        post :create, login: { login: account.login }
        must_redirect_to '/accounts/me'
      end

      it 'must reset auth_fail_count' do
        account.update!(auth_fail_count: 3)
        post :create, login: { login: account.login }
        Account.find(account.id).auth_fail_count.must_equal 0
      end
    end

    describe 'failure' do
      it 'must increment auth failure count' do
        auth_fail_count = ENV['MAX_LOGIN_RETRIES'].to_i - 2
        account.update!(auth_fail_count: auth_fail_count)
        post :create, login: { login: account.login }

        must_render_template 'sessions/new'
        must_respond_with :unauthorized
        account.reload
        account.auth_fail_count.must_equal(auth_fail_count + 1)
        refute account.access.disabled?
      end

      it 'must disable account and send notice when auth failure reaches limit' do
        auth_fail_count = ENV['MAX_LOGIN_RETRIES'].to_i - 1
        account.update!(auth_fail_count: auth_fail_count)

        NewRelic::Agent.expects(:notice_error)
        AccountMailer.expects(:notify_disabled_account_for_login_failure).returns(stub(:deliver_now))
        post :create, login: { login: account.login }

        must_render_template 'sessions/new'
        account.reload
        account.auth_fail_count.must_equal(auth_fail_count + 1)
        assert account.access.disabled?
      end

      it 'must reset auth_fail_count if login fails after FAILED_LOGIN_TIMEOUT' do
        auth_fail_count = 3
        elapsed_time = ENV['FAILED_LOGIN_TIMEOUT'].to_i.minutes.ago - 1.minute
        account.update!(auth_fail_count: auth_fail_count, updated_at: elapsed_time)
        post :create, login: { login: account.login }

        must_respond_with :unauthorized
        account.reload
        account.auth_fail_count.must_equal 1
        refute account.access.disabled?
      end

      it 'must show appropriate message to disabled users' do
        account.update!(level: Account::Access::DISABLED)
        post :create, login: { login: account.login, password: password }

        must_render_template 'sessions/new'
        flash.now[:notice].must_equal I18n.t('accounts.disabled_error')
      end
    end
  end
end
