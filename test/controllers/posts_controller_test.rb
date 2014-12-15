require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  fixtures :accounts, :forums, :topics, :posts
  
  def setup
    @forum = forums(:rails)
    @topic = topics(:pdi)
    @account = accounts(:user)
    @post = posts(:pdi)
  end

  test "index" do
    get :index, forum_id: @forum.id, topic_id: @topic.id
    assert_response :success
  end

  test "create a post" do
    assert_difference('Post.count') do
      post :create, forum_id: @forum.id, topic_id: @topic.id, post: {body: "Creating a post for testing", account_id: @account.id } 
    end
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "edit" do
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    assert_response :success
  end

  test "update a post" do
    put :update, forum_id: @forum.id, topic_id: @topic.id, id: @post.id, post: {body: "Updating the body"}
    @post.reload
    assert_equal "Updating the body", @post.body
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test "delete a post" do
    assert_difference('Post.count', -1) do
      delete :destroy, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    end
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end
end