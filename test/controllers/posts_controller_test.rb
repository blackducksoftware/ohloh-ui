require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  fixtures :accounts, :forums, :topics, :posts
  
  def setup
    @forum = forums(:rails)
    @topic = topics(:pdi)
    @admin = accounts(:admin)
    @user = accounts(:user)
    @post = posts(:pdi)
  end

  #---------------------------User without an account------------------------
  test "index" do
    get :index, forum_id: @forum.id, topic_id: @topic.id
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "new" do
    get :new, forum_id: @forum.id, topic_id: @topic.id
    assert_response :unauthorized
  end

  test "create" do
    assert_no_difference('Post.count') do
      post :create, forum_id: @forum.id, topic_id: @topic.id, post: {body: "Creating a post for testing", account_id: nil } 
    end
  end

  test "edit" do
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    assert_response :unauthorized
  end

  test "update" do
    put :update, forum_id: @forum.id, topic_id: @topic.id, id: @post.id, post: {body: "Updating the body"}
    @post.reload
    assert_equal "P D I pdi", @post.body
    assert_response :unauthorized
  end

  test "delete" do
    assert_no_difference('Post.count') do
      delete :destroy, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    end
  end

  #-------------------Basic User-------------------------
  test "user index" do
    login_as @user
    get :index, forum_id: @forum.id, topic_id: @topic.id
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "user new" do
    login_as @user
    get :new, forum_id: @forum.id, topic_id: @topic.id
    assert_response :success
  end

  test "user create" do
    login_as @user
    assert_difference('Post.count') do
      post :create, forum_id: @forum.id, topic_id: @topic.id, post: {body: "Creating a post for testing", account_id: @user.id } 
    end
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "user edits their own post" do
    login_as @user
    post = posts(:pdi_reply)
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: post.id
    assert_response :success
  end

  test "user updates their own post" do
    login_as @user
    post = posts(:pdi_reply)
    put :update, forum_id: @forum.id, topic_id: @topic.id, id: post.id, post: {body: "Updating the body"}
    post.reload
    assert_equal "Updating the body", post.body
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "user cannot edit someone else's post" do
    login_as @user
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

 # -------------------Admin-------------------------------
  test "admin index" do
    login_as @admin
    get :index, forum_id: @forum.id, topic_id: @topic.id
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "admin new" do
    login_as @admin
    get :new, forum_id: @forum.id, topic_id: @topic.id
    assert_response :success
  end

  test "admin create" do
    login_as @admin
    assert_difference('Post.count') do
      post :create, forum_id: @forum.id, topic_id: @topic.id, post: {body: "Creating a post for testing", account_id: @admin.id } 
    end
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "admin edit" do
    login_as @admin
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    assert_response :success
  end

  test "admin update" do
    login_as @admin
    put :update, forum_id: @forum.id, topic_id: @topic.id, id: @post.id, post: {body: "Updating the body"}
    @post.reload
    assert_equal "Updating the body", @post.body
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "admin delete" do
    login_as @admin
    assert_difference('Post.count', -1) do
      delete :destroy, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    end
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

 #  Ask the Peters about this test. Might need to implement Model code.
 #  test "mark a user's post as spam" do
 #  end
end