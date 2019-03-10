require 'test_helper'

describe 'SessionsController' do
  describe 'create' do
    let(:password) { Faker::Internet.password }
    let(:account) { create(:account, password: password) }
    let(:max_login_retries) { ENV['MAX_LOGIN_RETRIES'].to_i }

    describe 'success' do
      it 'must redirect to accounts/me after login' do
        post :create, login: { login: account.login, password: password }
        must_redirect_to '/accounts/me'
      end

      it 'must reset auth_fail_count' do
        account.update!(auth_fail_count: 3)
        post :create, login: { login: account.login, password: password }
        Account.find(account.id).auth_fail_count.must_equal 0
      end
    end

    describe 'failure' do
      it 'must handle invalid email or login' do
        post :create, login: { login: Faker::Name.name }

        must_render_template 'sessions/new'
        flash.now[:error].must_equal I18n.t('flashes.failure_after_create')
      end

      it 'must increment auth failure count' do
        auth_fail_count = max_login_retries - 2
        account.update!(auth_fail_count: auth_fail_count)
        post :create, login: { login: account.login }

        must_render_template 'sessions/new'
        must_respond_with :unauthorized
        account.reload
        account.auth_fail_count.must_equal(auth_fail_count + 1)
        flash.now[:error].must_equal I18n.t('flashes.failure_after_create')
        refute account.access.disabled?
      end

      it 'wont compare password when recaptcha fails on the last try but auth passes' do
        auth_fail_count = max_login_retries - 1
        account.update!(auth_fail_count: auth_fail_count)
        @controller.expects(:verify_recaptcha)

        post :create, login: { login: account.login, password: password },
                      'g-recaptcha-response': Faker::Internet.password
        account.reload

        must_render_template 'sessions/new'
        account.auth_fail_count.must_equal auth_fail_count
        flash.now[:error].must_equal I18n.t('sessions.create.recaptcha_failure')
        refute account.access.disabled?
      end

      it 'wont compare password or disable account when recaptcha fails on the last try alongwith auth failure' do
        auth_fail_count = max_login_retries - 1
        account.update!(auth_fail_count: auth_fail_count)
        @controller.expects(:verify_recaptcha)

        post :create, login: { login: account.login }, 'g-recaptcha-response': Faker::Internet.password
        account.reload

        must_render_template 'sessions/new'
        must_select('label.control-label').children.first.text.must_equal I18n.t('shared.captcha.captcha_label')
        account.auth_fail_count.must_equal auth_fail_count
        flash.now[:error].must_equal I18n.t('sessions.create.recaptcha_failure')
        refute account.access.disabled?
      end

      it 'must disable account and send notice when auth failure reaches limit' do
        auth_fail_count = max_login_retries - 1
        account.update!(auth_fail_count: auth_fail_count)

        NewRelic::Agent.expects(:notice_error)
        AccountMailer.expects(:notify_disabled_account_for_login_failure).returns(stub(:deliver_now))
        @controller.expects(:verify_recaptcha).returns(true)

        post :create, login: { login: account.login }, 'g-recaptcha-response': Faker::Internet.password
        account.reload

        must_render_template 'sessions/new'
        account.auth_fail_count.must_equal(auth_fail_count + 1)
        assert account.access.disabled?
      end

      it 'must render a captcha form before the last try' do
        account.update!(auth_fail_count: max_login_retries - 2)

        post :create, login: { login: account.login }

        assigns(:ask_for_recaptcha).must_equal true
        must_render_template 'sessions/new'
        must_select('label.control-label').children.first.text.must_equal I18n.t('shared.captcha.captcha_label')
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
        flash.now[:error].must_equal I18n.t('accounts.disabled_error')
      end
    end
  end
end
