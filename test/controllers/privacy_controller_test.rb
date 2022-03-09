# frozen_string_literal: true

require 'test_helper'

class PrivacyControllerTest < ActionController::TestCase
  let(:account) { create(:account) }
  before do
    login_as account
  end

  describe 'edit' do
    it 'must require login' do
      login_as nil
      get :edit, params: { id: account.id }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'must be own account' do
      login_as create(:account)
      get :edit, params: { id: account.id }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should get account privacy page' do
      get :edit, params: { id: account.id }
      assert_response :ok
    end

    it 'should get account privacy page with me as id' do
      get :edit, params: { id: 'me' }
      assert_response :ok
    end

    it 'should allow admins to edit others privacy page' do
      login_as create(:admin)
      get :edit, params: { id: account.id }
      assert_response :ok
      _(flash[:error]).must_equal I18n.t(:admin_warning)
    end

    it 'must set oauth_applications with unrevoked tokens' do
      create(:access_token, resource_owner_id: account.id).revoke # revoked application.
      create(:access_token)                                       # unauthorized application.
      authorized_application = create(:access_token, resource_owner_id: account.id).application
      create(:api_key, oauth_application: authorized_application)

      get :edit, params: { id: account.id }
      _(assigns(:oauth_applications)).must_equal [authorized_application]
    end
  end

  describe 'update' do
    it 'must require login' do
      login_as nil
      put :update, params: { id: account.id }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'must be own account' do
      login_as create(:account)
      put :update, params: { id: account.id }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'must gracefully handle exceptions' do
      Account.any_instance.stubs(:update).returns false
      put :update, params: { id: account.id, account: { email_master: false } }
      assert_response :unprocessable_entity
      assert_template :edit
    end

    it 'should update email master to false' do
      put :update, params: { id: account.id, account: { email_master: false } }
      account.save!
      account.reload
      _(account.email_master).must_equal false
      _(flash[:notice]).must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email master to true if set to false' do
      account.email_master = false
      put :update, params: { id: account.id, account: { email_master: true } }
      account.reload
      _(account.email_master).must_equal true
      _(flash[:notice]).must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email kudos to false' do
      put :update, params: { id: account.id, account: { email_kudos: false } }
      account.save!
      account.reload
      _(account.email_kudos).must_equal false
      _(flash[:notice]).must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email kudos to true if set to false' do
      account.email_kudos = false
      put :update, params: { id: account.id, account: { email_kudos: true } }
      account.reload
      _(account.email_kudos).must_equal true
      _(flash[:notice]).must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email posts to false' do
      put :update, params: { id: account.id, account: { email_posts: false } }
      account.save!
      account.reload
      _(account.email_posts).must_equal false
      _(flash[:notice]).must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email posts to true if set to false' do
      account.email_posts = false
      put :update, params: { id: account.id, account: { email_posts: true } }
      account.reload
      _(account.email_posts).must_equal true
      _(flash[:notice]).must_equal 'Your notifications are successfully updated.'
    end
  end
end
