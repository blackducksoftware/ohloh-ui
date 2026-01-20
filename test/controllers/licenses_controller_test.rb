# frozen_string_literal: true

require 'test_helper'

class LicensesControllerTest < ActionController::TestCase
  before do
    @license = create(:license)
  end

  describe 'index' do
    it 'should return the licenses' do
      get :index
      assert_response :ok
      assert_template :index
      _(assigns(:licenses).count).must_equal 1
      _(assigns(:licenses).first).must_equal @license
    end

    it 'should filter based on query' do
      get :index, params: { query: @license.vanity_url }
      assert_response :ok
      assert_template :index
      _(assigns(:licenses).count).must_equal 1
      _(assigns(:licenses).first).must_equal @license
    end

    it 'should not return if query is not found' do
      get :index, params: { query: 'Im banana' }
      assert_response :ok
      assert_template :index
      _(assigns(:licenses).count).must_equal 0
    end
  end

  describe 'show' do
    it 'should show the license' do
      get :show, params: { id: @license.vanity_url }
      assert_response :ok
      assert_template :show
    end

    it 'must avoid deleted license' do
      @license.destroy

      get :show, params: { id: @license.vanity_url }

      assert_response :not_found
    end

    it 'must escape html and format newlines in description' do
      @license.update! description: "foo \n <link>"

      get :show, params: { id: @license.vanity_url }

      _(assert_select('p')[1].text).must_equal "foo \n <link>"
    end
  end

  describe 'new' do
    it 'should require login to create a license' do
      get :new
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should render new if user logged in' do
      login_as create(:account)
      get :new
      assert_response :ok
      assert_template :new
    end
  end

  describe 'create' do
    it 'should be logged in' do
      post :create
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should create license' do
      login_as create(:account)
      post :create, params: { license: build(:license).attributes }
      assert_response :redirect
      assert_redirected_to assigns(:license)
      _(flash[:notice]).must_equal 'Create successful!'
    end

    it 'should redirect to new if save fails' do
      login_as create(:account)
      License.any_instance.stubs(:save).returns(false)
      post :create, params: { license: build(:license).attributes }
      assert_response :ok
      assert_template :new
      _(flash[:error]).must_equal 'There was a problem!'
    end
  end

  describe 'update' do
    it 'should require login' do
      put :update, params: { id: @license.id, license: build(:license).attributes }
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'should update the license' do
      login_as create(:account)
      put :update, params: { id: @license.vanity_url, license: build(:license).attributes }
      assert_response :redirect
      assert_redirected_to assigns(:license)
      _(flash[:notice]).must_equal 'Save successful!'
    end

    it 'should render edit if update fails' do
      login_as create(:account)
      License.any_instance.stubs(:update).returns(false)
      put :update, params: { id: @license.vanity_url, license: build(:license).attributes }
      assert_response :ok
      assert_template :edit
      _(flash[:error]).must_equal 'There was a problem!'
    end
  end
end
