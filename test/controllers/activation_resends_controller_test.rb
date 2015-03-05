require 'test_helper'

describe 'ActivationResendsController' do
  let(:account) { create(:account) }
  let(:unactivated) { create(:unactivated) }
  let(:recently_activated) { create(:unactivated, activation_resent_at: Time.now) }

  describe 'new' do
    it 'must respond with success' do
      get :new
      must_respond_with :ok
      must_render_template :new
    end
  end

  describe 'create' do
    it 'should not send email if account is already activated' do
      lambda do
        post :create, email: account.email
      end.wont_change 'ActionMailer::Base.deliveries.count'
      must_respond_with :redirect
      must_redirect_to new_session_path
      flash[:notice].must_equal I18n.t('activation_resends.create.already_active')
    end

    it 'should not send email for recently activated account' do
      lambda do
        post :create, email: recently_activated.email
      end.wont_change 'ActionMailer::Base.deliveries.count'
      must_respond_with :redirect
      must_redirect_to message_path
      flash[:success].must_equal I18n.t('activation_resends.create.recently_activated')
    end

    it 'Should not allow if email is invalid' do
      lambda do
        post :create, email: 'InvalidEmail'
      end.wont_change 'ActionMailer::Base.deliveries.count'
      must_respond_with :ok
      must_render_template :new
      assigns(:errors).must_equal I18n.t('activation_resends.create.no_account')
    end

    it 'should resend activation mail' do
      lambda do
        post :create, email: unactivated.email
      end.must_change 'ActionMailer::Base.deliveries.count'
      must_respond_with :redirect
      must_redirect_to message_path
      flash[:notice].must_equal I18n.t('activation_resends.create.success')
    end
  end
end
