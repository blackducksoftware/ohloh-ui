require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  fixtures :accounts, :forums, :topics, :posts

  def setup
    @forum = forums(:rails)
    @account = accounts(:user)
    @topic = topics(:ponies)
  end

  test "index" do
  	get :index, forum_id: @forum.id
  	assert_response :success
  	# assert_template :????
  end

  test "new" do
    get :new, forum_id: @forum.id
    assert_response :success
  end

  test "create a topic and accompanying post" do
    assert_difference(['Topic.count','Post.count']) do
	  	post :create, forum_id: @forum.id, topic: {account_id: @account.id,
                                                 title: "Example Forum", 
                                                   posts_attributes: [{body: "Post object that comes by default", account_id: @account.id}] } 
	  end
    assert_redirected_to forum_path(@forum.id)
  end

  test "show" do
    get :show, forum_id: @forum.id, id: @topic.id
    assert_response :success
  end

  test "edit" do
    get :edit, forum_id: @forum.id, id: @topic.id
    assert_response :success
  end

  test "update" do
    put :update, forum_id: @forum.id, id: @topic.id, topic: {title: "Changed title for test purposes"}
    @topic.reload
    assert_equal "Changed title for test purposes", @topic.title
  end

  test "delete a topic" do
    assert_difference('Topic.count',-1) do
      delete :destroy, forum_id: @forum.id, id: @topic.id
    end
    assert_redirected_to forums_path
  end

  test "deleting a topic deletes the associated posts" do
    @topic.destroy
    assert_equal @topic.posts_count, 0
  end

end