# frozen_string_literal: true

require 'test_helper'

describe 'ActivationResendsController' do
  describe 'new' do
    it 'must respond with success' do
      get :new
      must_respond_with :ok
      must_render_template :new
    end
  end

  describe 'create' do
    it 'should not send email if account is already activated' do
      account = create(:account)
      before = ActionMailer::Base.deliveries.count
      post :create, email: account.email
      ActionMailer::Base.deliveries.count.must_equal before
      must_respond_with :redirect
      must_redirect_to new_session_path
      flash[:notice].must_equal I18n.t('activation_resends.create.already_active')
    end

    it 'should not send email for recently activated account' do
      recently_activated = create(:unactivated, activation_resent_at: Time.current)
      before = ActionMailer::Base.deliveries.count
      post :create, email: recently_activated.email
      ActionMailer::Base.deliveries.count.must_equal before
      must_respond_with :redirect
      must_redirect_to root_path
      flash[:success].must_equal I18n.t('activation_resends.create.recently_activated')
    end

    it 'Should not allow if email is invalid' do
      before = ActionMailer::Base.deliveries.count
      post :create, email: 'InvalidEmail'
      ActionMailer::Base.deliveries.count.must_equal before
      must_respond_with :ok
      must_render_template :new
      assigns(:errors).must_equal I18n.t('activation_resends.create.no_account')
    end

    it 'should resend activation mail' do
      unactivated = create(:unactivated)
      before = ActionMailer::Base.deliveries.count
      post :create, email: unactivated.email
      ActionMailer::Base.deliveries.count.must_equal(before + 1)
      must_respond_with :redirect
      must_redirect_to root_path
      flash[:notice].must_equal I18n.t('activation_resends.create.success')
    end
  end
end
