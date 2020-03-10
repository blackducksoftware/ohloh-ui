# frozen_string_literal: true

require 'test_helper'

describe 'LicensesControllerTest' do
  before do
    @license = create(:license)
  end

  describe 'index' do
    it 'should return the licenses' do
      get :index
      must_respond_with :ok
      must_render_template :index
      assigns(:licenses).count.must_equal 1
      assigns(:licenses).first.must_equal @license
    end

    it 'should filter based on query' do
      get :index, query: @license.vanity_url
      must_respond_with :ok
      must_render_template :index
      assigns(:licenses).count.must_equal 1
      assigns(:licenses).first.must_equal @license
    end

    it 'should not return if query is not found' do
      get :index, query: 'Im banana'
      must_respond_with :ok
      must_render_template :index
      assigns(:licenses).count.must_equal 0
    end
  end

  describe 'show' do
    it 'should show the license' do
      get :show, id: @license.vanity_url
      must_respond_with :ok
      must_render_template :show
    end

    it 'must avoid deleted license' do
      @license.destroy

      get :show, id: @license.vanity_url

      must_respond_with :not_found
    end

    it 'must escape html and format newlines in description' do
      @license.update! description: "foo \n <link>"

      get :show, id: @license.vanity_url

      must_select('p')[3].text.must_equal "foo \n <link>"
    end
  end

  describe 'new' do
    it 'should require login to create a license' do
      get :new
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'should render new if user logged in' do
      login_as create(:account)
      get :new
      must_respond_with :ok
      must_render_template :new
    end
  end

  describe 'create' do
    it 'should be logged in' do
      post :create
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'should create license' do
      login_as create(:account)
      post :create, license: build(:license).attributes
      must_respond_with :redirect
      must_redirect_to assigns(:license)
      flash[:notice].must_equal 'Create successful!'
    end

    it 'should redirect to new if save fails' do
      login_as create(:account)
      License.any_instance.stubs(:save).returns(false)
      post :create, license: build(:license).attributes
      must_respond_with :ok
      must_render_template :new
      flash[:error].must_equal 'There was a problem!'
    end
  end

  describe 'update' do
    it 'should require login' do
      put :update, id: @license.id, license: build(:license).attributes
      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'should update the license' do
      login_as create(:account)
      put :update, id: @license.vanity_url, license: build(:license).attributes
      must_respond_with :redirect
      must_redirect_to assigns(:license)
      flash[:notice].must_equal 'Save successful!'
    end

    it 'should render edit if update fails' do
      login_as create(:account)
      License.any_instance.stubs(:update).returns(false)
      put :update, id: @license.vanity_url, license: build(:license).attributes
      must_respond_with :ok
      must_render_template :edit
      flash[:error].must_equal 'There was a problem!'
    end
  end
end
