require 'test_helper'

describe ForumsController do
  let(:forum) { forums(:rails) }
  let(:admin) { accounts(:admin) }
  let(:user) { accounts(:user) }

  #----------------Admin functionality----------
  it 'admin index' do
    get :index
    must_respond_with :success
  end

  it 'admin new' do
    login_as admin
    get :new
    must_respond_with :success
  end

  it 'admin create' do
    login_as admin
    assert_difference('Forum.count', 1) do
      post :create, forum: { name: 'Ruby vs. Javascript, who will win?' }
    end
    must_redirect_to forums_path
  end

  it 'admin edit' do
    login_as admin
    get :edit, id: forum.id
    must_respond_with :success
  end

  it 'admin update' do
    login_as admin
    put :update, id: forum.id, forum: { name: 'Ruby vs. Python vs. Javascript deathmatch' }
    forum.reload
    forum.name.must_equal 'Ruby vs. Python vs. Javascript deathmatch'
  end

  it 'admin destroy' do
    login_as admin
    assert_difference('Forum.count', -1) do
      delete :destroy, id: forum.id
    end
    must_redirect_to forums_path
  end

  #------------------User Functionality----------------------
  it 'index' do
    login_as user
    get :index
    must_respond_with :success
  end

  it 'new' do
    login_as user
    get :new
    must_respond_with :unauthorized
  end

  it 'create' do
    login_as user
    assert_no_difference('Forum.count') do
      post :create, forum: { name: 'Ruby vs. Javascript, who will win?' }
    end
  end

  it 'show' do
    login_as user
    get :show, id: forum.id
    must_respond_with :success
  end

  it 'edit' do
    login_as user
    get :edit, id: forum.id
    must_respond_with :unauthorized
  end

  it 'update' do
    login_as user
    put :update, id: forum.id, forum: { name: 'Ruby vs. Python vs. Javascript deathmatch' }
    forum.reload
    forum.name.must_equal 'rails'
  end

  it 'destroy' do
    login_as user
    assert_no_difference('Forum.count') do
      delete :destroy, id: forum.id
    end
  end
end
