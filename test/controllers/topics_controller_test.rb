require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  fixtures :accounts, :forums, :topics, :posts

  def setup
    @forum = forums(:rails)
    @user = accounts(:user)
    @admin = accounts(:admin)
    @topic = topics(:ponies)
  end

#-------------User with no account---------------
  test "index" do
    get :index, forum_id: @forum.id
    assert_redirected_to forum_path(@forum)
  end

  test "new" do
    get :new, forum_id: @forum.id
    assert_response :unauthorized
  end

  test "create" do
    assert_no_difference(['Topic.count','Post.count']) do
      post :create, forum_id: @forum.id, topic: { account_id: @admin.id, title: "Example Forum", posts_attributes: [ { body: "Post object that comes by default", account_id: @admin.id } ] } 
    end
  end

  test "show" do
    get :show, forum_id: @forum.id, id: @topic.id
    assert_response :success
  end

  test "edit" do
    get :edit, forum_id: @forum.id, id: @topic.id
    assert_response :unauthorized
  end

  test "update" do
    assert_no_difference('Topic.count','Post.count') do
      put :update, forum_id: @forum.id, id: @topic.id ,topic: { title: "Example Forum" } 
    end
  end

  test "destroy" do
    assert_no_difference('Topic.count') do
      delete :destroy, forum_id: @forum.id, id: @topic.id
    end
  end

#--------------Basic User ----------------------
  test "user index" do
    login_as @user
    get :index, forum_id: @forum.id
    assert_redirected_to forum_path(@forum)
  end

  test "user new" do
    login_as @user
    get :new, forum_id: @forum.id
    assert_response :success
  end

  test "user create a topic and an accompanying post" do
    login_as(@user)
    assert_difference(['Topic.count','Post.count']) do
      post :create, forum_id: @forum.id, topic: { account_id: @admin.id, title: "Example Forum", posts_attributes: [ { body: "Post object that comes by default", account_id: @admin.id } ] } 
    end
    assert_redirected_to forum_path(@forum.id)
  end

  test "user show" do
    login_as @user
    get :show, forum_id: @forum.id, id: @topic.id
    assert_response :success
  end

  test "user edit" do
    login_as @user
    get :edit, forum_id: @forum.id, id: @topic.id
    assert_response :unauthorized
  end

  test "user update" do
    login_as @user
    put :update, forum_id: @forum.id, id: @topic.id, topic: { title: "Changed title for test purposes" }
    @topic.reload
    assert_equal "ponies", @topic.title
  end

  test "user destroy" do
    login_as @user
    assert_no_difference('Topic.count') do
      delete :destroy, forum_id: @forum.id, id: @topic.id
    end
  end

#-----------Admin Account------------------------
  test "admin index" do
    login_as @admin
  	get :index, forum_id: @forum.id
  	assert_redirected_to forum_path(@forum)
  end

  test "admin new" do
    login_as(@admin)
    get :new, forum_id: @forum.id
    assert_response :success
  end

  test "admin create a topic and accompanying post" do
    login_as(@admin)
    assert_difference(['Topic.count','Post.count']) do
	  	post :create, forum_id: @forum.id, topic: { account_id: @admin.id, title: "Example Forum", posts_attributes: [ { body: "Post object that comes by default", account_id: @admin.id } ] } 
	  end
    assert_redirected_to forum_path(@forum.id)
  end

  test "admin show" do
    login_as @admin
    get :show, forum_id: @forum.id, id: @topic.id
    assert_response :success
  end

  test "admin edit" do
    login_as(@admin)
    get :edit, forum_id: @forum.id, id: @topic.id
    assert_response :success
  end

  test "admin update" do
    login_as(@admin)
    put :update, forum_id: @forum.id, id: @topic.id, topic: { title: "Changed title for test purposes" }
    @topic.reload
    assert_equal "Changed title for test purposes", @topic.title
  end

  test "admin destroy" do
    login_as @admin
    assert_difference('Topic.count',-1) do
      delete :destroy, forum_id: @forum.id, id: @topic.id
    end
    assert_redirected_to forums_path
  end

  test "admin destryoing a topic deletes the associated posts" do
    login_as @admin
    @topic.destroy
    assert_equal @topic.posts_count, 0
  end

  test "admin can close a topic" do
    login_as @admin
    put :update, forum_id: @forum.id, id: @topic.id, topic: { closed: true }
    @topic.reload
    assert @topic.closed   
  end

  test "admin can reopen a topic" do
    login_as @admin
    @topic.closed = true
    @topic.reload
    put :update, forum_id: @forum.id, id: @topic.id, topic: { closed: false }
    assert_not @topic.closed
  end

  test "admin can move a topic" do
    forum = forums(:ponies)
    login_as @admin
    put :update, forum_id: @forum.id, id: @topic.id, topic: { forum_id: forum.id}
    @topic.reload
    assert_equal @topic.forum_id, forum.id
    assert_equal forum.topics.first.title, @topic.title
    assert_equal forum.topics.count, 1
  end

  # TODO: Ask Peters for feedback on this test. This one seems a little complicated
  # test "admin can flag an account as a spammer and remove all posts from that account" do
  #   login_as @admin
  #   assert_equal @admin.level, -20
  # end
end