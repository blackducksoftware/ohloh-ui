require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  fixtures :forums

  def setup
    @forum = forums(:rails)
  end

  test "index" do
    get :index
    assert_response :success
  end

  test "new" do
    get :new
    assert_response :success
  end

  test "create a forum" do
    assert_difference('Forum.count',1) do
      post :create, forum: { name: "Ruby vs. Javascript, who will win?" }
    end
    assert_redirected_to forums_path
  end

  test "show" do
    get :show, id: @forum.id
    assert_response :success
  end

  test "edit" do
    get :edit, id: @forum.id
    assert_response :success
  end

  test "update" do
    put :update, id: @forum.id, forum: { name: "Ruby vs. Python vs. Javascript deathmatch" }
    @forum.reload
    assert_equal "Ruby vs. Python vs. Javascript deathmatch", @forum.name
  end

  test "destroy" do
    assert_difference('Forum.count',-1) do
      delete :destroy, id: @forum.id
    end
    assert_redirected_to forums_path
  end

end