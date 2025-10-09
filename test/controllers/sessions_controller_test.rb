# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  describe 'create' do
    let(:password) { Faker::Internet.password }
    let(:account) { create(:account, password: password) }
    let(:max_login_retries) { ENV['MAX_LOGIN_RETRIES'].to_i }

    describe 'success' do
      it 'must redirect to accounts/me after login' do
        post :create, params: { login: { login: account.login, password: password } }
        assert_redirected_to '/accounts/me'
      end

      it 'must reset auth_fail_count' do
        account.update!(auth_fail_count: 3)
        post :create, params: { login: { login: account.login, password: password } }
        _(Account.find(account.id).auth_fail_count).must_equal 0
      end
    end

    describe 'failure' do
      it 'must handle invalid email or login' do
        post :create, params: { login: { login: Faker::Name.name } }

        assert_template 'sessions/new'
        _(flash.now[:error]).must_equal I18n.t('flashes.failure_after_create')
      end

      it 'must increment auth failure count' do
        auth_fail_count = max_login_retries - 2
        account.update!(auth_fail_count: auth_fail_count, updated_at: Time.current)
        post :create, params: { login: { login: account.login } }
        account.reload
        assert_template 'sessions/new'
        assert_response :unauthorized
        _(account.auth_fail_count).must_equal(auth_fail_count + 1)
        _(flash.now[:error]).must_equal I18n.t('flashes.failure_after_create')
        assert_not account.access.disabled?
      end

      it 'wont compare password when recaptcha fails on the last try but auth passes' do
        auth_fail_count = max_login_retries - 1
        account.update!(auth_fail_count: auth_fail_count, updated_at: Time.current)
        @controller.expects(:verify_recaptcha)
        post :create, params: { login: { login: account.login, password: password },
                                'g-recaptcha-response': Faker::Internet.password }
        account.reload
        assert_template 'sessions/new'
        _(account.auth_fail_count).must_equal auth_fail_count
        _(flash.now[:error]).must_equal I18n.t('sessions.create.recaptcha_failure')
        assert_not account.access.disabled?
      end

      it 'wont compare password or disable account when recaptcha fails on the last try alongwith auth failure' do
        auth_fail_count = max_login_retries - 1
        account.update!(auth_fail_count: auth_fail_count, updated_at: Time.current)
        @controller.expects(:verify_recaptcha)
        post :create, params: { login: { login: account.login }, 'g-recaptcha-response': Faker::Internet.password }
        account.reload
        assert_template 'sessions/new'
        _(assert_select('label.control-label').children.first.text).must_equal I18n.t('shared.captcha.captcha_label')
        _(account.auth_fail_count).must_equal auth_fail_count
        _(flash.now[:error]).must_equal I18n.t('sessions.create.recaptcha_failure')
        assert_not account.access.disabled?
      end

      it 'must disable account and send notice when auth failure reaches limit' do
        auth_fail_count = max_login_retries - 1
        account.update!(auth_fail_count: auth_fail_count, updated_at: Time.current)

        DataDogReport.expects(:info)
        AccountMailer.expects(:notify_disabled_account_for_login_failure).returns(stub(deliver_now: nil))
        @controller.expects(:verify_recaptcha).returns(true)

        post :create, params: { login: { login: account.login }, 'g-recaptcha-response': Faker::Internet.password }
        account.reload

        assert_template 'sessions/new'
        _(account.auth_fail_count).must_equal(auth_fail_count + 1)
        assert account.access.disabled?
      end

      it 'must render a captcha form after 3 failed login attempts' do
        account.update!(auth_fail_count: 3, updated_at: Time.current)

        post :create, params: { login: { login: account.login } }

        _(assigns(:ask_for_recaptcha)).must_equal true
        assert_template 'sessions/new'
        _(assert_select('label.control-label').children.first.text).must_equal I18n.t('shared.captcha.captcha_label')
      end

      it 'must reset auth_fail_count if login fails after FAILED_LOGIN_TIMEOUT' do
        auth_fail_count = 3
        elapsed_time = ENV['FAILED_LOGIN_TIMEOUT'].to_i.minutes.ago - 1.minute
        account.update!(auth_fail_count: auth_fail_count, updated_at: elapsed_time)
        post :create, params: { login: { login: account.login } }

        assert_response :unauthorized
        account.reload
        _(account.auth_fail_count).must_equal 1
        assert_not account.access.disabled?
      end

      it 'must show appropriate message to disabled users' do
        account.update!(level: Account::Access::DISABLED)
        post :create, params: { login: { login: account.login, password: password } }

        assert_template 'sessions/new'
        _(flash.now[:error]).must_equal I18n.t('accounts.disabled_error')
      end
    end
  end

  describe 'health' do
    it 'must return the current timestamp when DB is accessible' do
      get :health
      assert_response :success
      _(response.body).must_match Time.current.strftime('%F %H')
    end
  end
end
