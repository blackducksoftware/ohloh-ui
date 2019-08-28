# frozen_string_literal: true

require 'test_helper'

describe 'PrivacyController' do
  let(:account) { create(:account) }
  before do
    login_as account
  end

  describe 'edit' do
    it 'must require login' do
      login_as nil
      get :edit, id: account.id
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must be own account' do
      login_as create(:account)
      get :edit, id: account.id
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'should get account privacy page' do
      get :edit, id: account.id
      must_respond_with :ok
    end

    it 'should get account privacy page with me as id' do
      get :edit, id: 'me'
      must_respond_with :ok
    end

    it 'should allow admins to edit others privacy page' do
      login_as create(:admin)
      get :edit, id: account.id
      must_respond_with :ok
      flash[:error].must_equal I18n.t(:admin_warning)
    end

    it 'must set oauth_applications with unrevoked tokens' do
      create(:access_token, resource_owner_id: account.id).revoke # revoked application.
      create(:access_token)                                       # unauthorized application.
      authorized_application = create(:access_token, resource_owner_id: account.id).application
      create(:api_key, oauth_application: authorized_application)

      get :edit, id: account.id
      assigns(:oauth_applications).must_equal [authorized_application]
    end
  end

  describe 'update' do
    it 'must require login' do
      login_as nil
      put :update, id: account.id
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must be own account' do
      login_as create(:account)
      put :update, id: account.id
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must gracefully handle exceptions' do
      Account.any_instance.stubs(:update).returns false
      put :update, id: account.id, account: { email_master: false }
      must_respond_with :unprocessable_entity
      must_render_template :edit
    end

    it 'should update email master to false' do
      put :update, id: account.id, account: { email_master: false }
      account.save!
      account.reload
      account.email_master.must_equal false
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email master to true if set to false' do
      account.email_master = false
      put :update, id: account.id, account: { email_master: true }
      account.reload
      account.email_master.must_equal true
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email kudos to false' do
      put :update, id: account.id, account: { email_kudos: false }
      account.save!
      account.reload
      account.email_kudos.must_equal false
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email kudos to true if set to false' do
      account.email_kudos = false
      put :update, id: account.id, account: { email_kudos: true }
      account.reload
      account.email_kudos.must_equal true
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email posts to false' do
      put :update, id: account.id, account: { email_posts: false }
      account.save!
      account.reload
      account.email_posts.must_equal false
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end

    it 'should update email posts to true if set to false' do
      account.email_posts = false
      put :update, id: account.id, account: { email_posts: true }
      account.reload
      account.email_posts.must_equal true
      flash[:notice].must_equal 'Your notifications are successfully updated.'
    end
  end
end
