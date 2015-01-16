require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  fixtures :accounts, :forums, :topics, :posts
  def setup
    @forum = forums(:rails)
    @topic = topics(:pdi)
    @admin = accounts(:admin)
    @user = accounts(:user)
    @post = posts(:pdi)
    ActionMailer::Base.deliveries.clear
  end

  #---------------------------User without an account------------------------
  test 'index' do
    get :index, forum_id: @forum.id, topic_id: @topic.id
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test 'new' do
    get :new, forum_id: @forum.id, topic_id: @topic.id
    assert_response :unauthorized
  end

  test 'create' do
    assert_no_difference('Post.count') do
      post :create, forum_id: @forum.id, topic_id: @topic.id, post: { body: 'Creating a post for testing' }
    end
  end

  test 'edit' do
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    assert_response :unauthorized
  end

  test 'update' do
    put :update, forum_id: @forum.id, topic_id: @topic.id, id: @post.id, post: { body: 'Updating the body' }
    @post.reload
    assert_equal 'P D I pdi', @post.body
    assert_response :unauthorized
  end

  test 'delete' do
    assert_no_difference('Post.count') do
      delete :destroy, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    end
  end

  #-------------------Basic User-------------------------
  test 'user index' do
    login_as @user
    get :index, forum_id: @forum.id, topic_id: @topic.id
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test 'user new' do
    login_as @user
    get :new, forum_id: @forum.id, topic_id: @topic.id
    assert_response :success
  end

  test 'create action: a user creates a post for the first time' do
    forum = forums(:broken_forum_topic_no_posts)
    topic = topics(:broken_topic_no_posts)
    login_as @admin
    assert_difference(['Post.count', 'ActionMailer::Base.deliveries.size'], 1) do
      post :create, forum_id: forum.id, topic_id: topic.id, post: { body: 'I am the same user.' }
    end
    email = ActionMailer::Base.deliveries.last
    assert_equal [@admin.email], email.to # Admin Allen
    assert_equal 'Post successfully created', email.subject
    assert_redirected_to forum_topic_path(forum.id, topic.id)
  end

  test 'create action: user2 replying to user1 receives a creation email while user1 receives a reply email' do
    forum = forums(:javascript)
    topic = topics(:javascript)
    login_as @user
    assert_difference(['ActionMailer::Base.deliveries.size'], 2) do
      post :create, forum_id: forum.id, topic_id: topic.id, post: { body: 'Post reply gets sent to Joe.
                                                                    Post creation gets sent to user Luckey' }
    end
    email = ActionMailer::Base.deliveries
    assert_equal [topic.account.email], email.first.to
    assert_equal 'Someone has responded to your post', email.first.subject
    assert_equal [@user.email], email.last.to
    assert_equal 'Post successfully created', email.last.subject
    assert_redirected_to forum_topic_path(forum.id, topic.id)
  end

  test 'create action: users who have posted more than once on a topic receive only one email notification' do
    last_user = accounts(:joe)
    login_as accounts(:joe)
    assert_difference(['ActionMailer::Base.deliveries.size'], 3) do
      post :create, forum_id: @forum.id, topic_id: @topic.id, post: { body: 'This post should trigger a cascade
                                                                      of emails being sent to all preceding users' }
    end
    email = ActionMailer::Base.deliveries
    # First email
    assert_equal [@admin.email], email.first.to
    assert_equal 'Someone has responded to your post', email.first.subject
    # Second email
    assert_equal [@user.email], email[1].to
    assert_equal 'Someone has responded to your post', email[1].subject
    # Third email
    assert_equal [last_user.email], email.last.to
    assert_equal 'Post successfully created', email.last.subject
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test 'create action: A user who replies to his own post will not receive
        a post notification email while everyone else does.' do
    last_user = accounts(:admin)
    login_as @admin
    assert_difference(['ActionMailer::Base.deliveries.size'], 2) do
      post :create, forum_id: @forum.id, topic_id: @topic.id, post: { body: 'Admin allen replies to his own post' }
    end
    email = ActionMailer::Base.deliveries
    assert_equal [@user.email], email.first.to
    assert_equal 'Someone has responded to your post', email.first.subject
    # Third email
    assert_equal [last_user.email], email.last.to
    assert_equal 'Post successfully created', email.last.subject
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test 'user edits their own post' do
    login_as @user
    post = posts(:pdi_reply)
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: post.id
    assert_response :success
  end

  test 'user updates their own post' do
    login_as @user
    post = posts(:pdi_reply)
    put :update, forum_id: @forum.id, topic_id: @topic.id, id: post.id, post: { body: 'Updating the body' }
    post.reload
    assert_equal 'Updating the body', post.body
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test 'user cannot edit someone else\'s post' do
    login_as @user
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  #-------------------Admin-------------------------------
  test 'admin index' do
    login_as @admin
    get :index, forum_id: @forum.id, topic_id: @topic.id
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test 'admin new' do
    login_as @admin
    get :new, forum_id: @forum.id, topic_id: @topic.id
    assert_response :success
  end

  test 'admin create' do
    login_as @admin
    assert_difference('Post.count') do
      post :create, forum_id: @forum.id, topic_id: @topic.id, post: { body: 'Creating a post for testing' }
    end
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test 'admin edit' do
    login_as @admin
    get :edit, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    assert_response :success
  end

  test 'admin update' do
    login_as @admin
    put :update, forum_id: @forum.id, topic_id: @topic.id, id: @post.id, post: { body: 'Updating the body' }
    @post.reload
    assert_equal 'Updating the body', @post.body
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end

  test 'admin delete' do
    login_as @admin
    assert_difference('Post.count', -1) do
      delete :destroy, forum_id: @forum.id, topic_id: @topic.id, id: @post.id
    end
    assert_redirected_to forum_topic_path(@forum.id, @topic.id)
  end
end
