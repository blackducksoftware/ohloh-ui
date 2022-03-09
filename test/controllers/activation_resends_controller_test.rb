# frozen_string_literal: true

require 'test_helper'

class ActivationResendsControllerTest < ActionController::TestCase
  describe 'new' do
    it 'must respond with success' do
      get :new
      assert_response :ok
      assert_template :new
    end
  end

  describe 'create' do
    it 'should not send email if account is already activated' do
      account = create(:account)
      before = ActionMailer::Base.deliveries.count
      post :create, params: { email: account.email }
      _(ActionMailer::Base.deliveries.count).must_equal before
      assert_response :redirect
      assert_redirected_to new_session_path
      _(flash[:notice]).must_equal I18n.t('activation_resends.create.already_active')
    end

    it 'should not send email for recently activated account' do
      recently_activated = create(:unactivated, activation_resent_at: Time.current)
      before = ActionMailer::Base.deliveries.count
      post :create, params: { email: recently_activated.email }
      _(ActionMailer::Base.deliveries.count).must_equal before
      assert_response :redirect
      assert_redirected_to root_path
      _(flash[:success]).must_equal I18n.t('activation_resends.create.recently_activated')
    end

    it 'Should not allow if email is invalid' do
      before = ActionMailer::Base.deliveries.count
      post :create, params: { email: 'InvalidEmail' }
      _(ActionMailer::Base.deliveries.count).must_equal before
      assert_response :ok
      assert_template :new
      _(assigns(:errors)).must_equal I18n.t('activation_resends.create.no_account')
    end

    it 'should resend activation mail' do
      unactivated = create(:unactivated)
      before = ActionMailer::Base.deliveries.count
      post :create, params: { email: unactivated.email }
      _(ActionMailer::Base.deliveries.count).must_equal(before + 1)
      assert_response :redirect
      assert_redirected_to root_path
      _(flash[:notice]).must_equal I18n.t('activation_resends.create.success')
    end
  end
end
