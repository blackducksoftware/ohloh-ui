require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  fixtures :forums, :accounts

  def setup
    @forum = forums(:rails)
    @admin = accounts(:admin)
    @user = accounts(:user)
  end

  #----------------Admin functionality----------
  test 'admin index' do
    get :index
    assert_response :success
  end

  test 'admin new' do
    login_as @admin
    get :new
    assert_response :success
  end

  test 'admin create' do
    login_as @admin
    assert_difference('Forum.count', 1) do
      post :create, forum: { name: 'Ruby vs. Javascript, who will win?' }
    end
    assert_redirected_to forums_path
  end

  test 'admin edit' do
    login_as @admin
    get :edit, id: @forum.id
    assert_response :success
  end

  test 'admin update' do
    login_as @admin
    put :update, id: @forum.id, forum: { name: 'Ruby vs. Python vs. Javascript deathmatch' }
    @forum.reload
    assert_equal 'Ruby vs. Python vs. Javascript deathmatch', @forum.name
  end

  test 'admin destroy' do
    login_as @admin
    assert_difference('Forum.count', -1) do
      delete :destroy, id: @forum.id
    end
    assert_redirected_to forums_path
  end

  #------------------User Functionality----------------------
  test 'index' do
    login_as @user
    get :index
    assert_response :success
  end

  test 'new' do
    login_as @user
    get :new
    assert_response :unauthorized
  end

  test 'create' do
    login_as @user
    assert_no_difference('Forum.count') do
      post :create, forum: { name: 'Ruby vs. Javascript, who will win?' }
    end
  end

  test 'show' do
    login_as @user
    get :show, id: @forum.id
    assert_response :success
  end

  test 'edit' do
    login_as @user
    get :edit, id: @forum.id
    assert_response :unauthorized
  end

  test 'update' do
    login_as @user
    put :update, id: @forum.id, forum: { name: 'Ruby vs. Python vs. Javascript deathmatch' }
    @forum.reload
    assert_equal 'rails', @forum.name
  end

  test 'destroy' do
    login_as @user
    assert_no_difference('Forum.count') do
      delete :destroy, id: @forum.id
    end
  end
end
