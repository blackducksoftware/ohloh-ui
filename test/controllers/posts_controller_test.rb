require 'test_helper'

describe PostsController do
  let(:forum) { forums(:rails) }
  let(:topic) { topics(:pdi) }
  let(:admin) { accounts(:admin) }
  let(:user) { accounts(:user) }
  let(:post_object) { posts(:pdi) }
  before { ActionMailer::Base.deliveries.clear }

  #---------------------------User without an account------------------------
  it 'index' do
    get :index, forum_id: forum.id, topic_id: topic.id
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'new' do
    get :new, forum_id: forum.id, topic_id: topic.id
    must_respond_with :unauthorized
  end

  it 'create' do
    assert_no_difference('Post.count') do
      post :create, forum_id: forum.id, topic_id: topic.id, post: { body: 'Creating a post for testing' }
    end
  end

  it 'edit' do
    get :edit, forum_id: forum.id, topic_id: topic.id, id: post_object.id
    must_respond_with :unauthorized
  end

  it 'update' do
    put :update, forum_id: forum.id, topic_id: topic.id, id: post_object.id, post: { body: 'Updating the body' }
    post_object.reload
    post_object.body.must_equal 'P D I pdi'
    must_respond_with :unauthorized
  end

  it 'delete' do
    assert_no_difference('Post.count') do
      delete :destroy, forum_id: forum.id, topic_id: topic.id, id: post_object.id
    end
  end

  #-------------------Basic User-------------------------
  it 'user index' do
    login_as user
    get :index, forum_id: forum.id, topic_id: topic.id
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'user new' do
    login_as user
    get :new, forum_id: forum.id, topic_id: topic.id
    must_respond_with :success
  end

  it 'create action: a user creates a post for the first time' do
    forum = forums(:broken_forum_topic_no_posts)
    topic = topics(:broken_topic_no_posts)
    login_as admin
    assert_difference(['Post.count', 'ActionMailer::Base.deliveries.size'], 1) do
      post :create, forum_id: forum.id, topic_id: topic.id, post: { body: 'I am the same user.' }
    end
    email = ActionMailer::Base.deliveries.last
    email.to.must_equal [admin.email] # Admin Allen
    email.subject.must_equal 'Post successfully created'
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'create action: user2 replying to user1 receives a creation email while user1 receives a reply email' do
    forum = forums(:javascript)
    topic = topics(:javascript)
    login_as user
    assert_difference(['ActionMailer::Base.deliveries.size'], 2) do
      post :create, forum_id: forum.id, topic_id: topic.id, post: { body: 'Post reply gets sent to Joe.
                                                                    Post creation gets sent to user Luckey' }
    end
    email = ActionMailer::Base.deliveries
    email.first.to.must_equal [topic.account.email]
    email.first.subject.must_equal 'Someone has responded to your post'
    email.last.to.must_equal [user.email]
    email.last.subject.must_equal 'Post successfully created'
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'create action: users who have posted more than once on a topic receive only one email notification' do
    last_user = accounts(:joe)
    login_as accounts(:joe)
    assert_difference(['ActionMailer::Base.deliveries.size'], 3) do
      post :create, forum_id: forum.id, topic_id: topic.id, post: { body: 'This post should trigger a cascade
                                                                      of emails being sent to all preceding users' }
    end
    email = ActionMailer::Base.deliveries
    # First email
    email.first.to.must_equal [admin.email]
    email.first.subject.must_equal 'Someone has responded to your post'
    # Second email
    email[1].to.must_equal [user.email]
    email[1].subject.must_equal 'Someone has responded to your post'
    # Third email
    email.last.to.must_equal [last_user.email]
    email.last.subject.must_equal 'Post successfully created'
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'create action: A user who replies to his own post will not receive
        a post notification email while everyone else does.' do
    last_user = accounts(:admin)
    login_as admin
    assert_difference(['ActionMailer::Base.deliveries.size'], 2) do
      post :create, forum_id: forum.id, topic_id: topic.id, post: { body: 'Admin allen replies to his own post' }
    end
    email = ActionMailer::Base.deliveries
    email.first.to.must_equal [user.email]
    email.first.subject.must_equal 'Someone has responded to your post'
    # Third email
    email.last.to.must_equal [last_user.email]
    email.last.subject.must_equal 'Post successfully created'
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'user edits their own post' do
    login_as user
    post_object = posts(:pdi_reply)
    get :edit, forum_id: forum.id, topic_id: topic.id, id: post_object.id
    must_respond_with :success
  end

  it 'user updates their own post' do
    login_as user
    post_object = posts(:pdi_reply)
    put :update, forum_id: forum.id, topic_id: topic.id, id: post_object.id, post: { body: 'Updating the body' }
    post_object.reload
    post_object.body.must_equal 'Updating the body'
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'user cannot edit someone else\'s post' do
    login_as user
    get :edit, forum_id: forum.id, topic_id: topic.id, id: post_object.id
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  #-------------------Admin-------------------------------
  it 'admin index' do
    login_as admin
    get :index, forum_id: forum.id, topic_id: topic.id
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'admin new' do
    login_as admin
    get :new, forum_id: forum.id, topic_id: topic.id
    must_respond_with :success
  end

  it 'admin create' do
    login_as admin
    assert_difference('Post.count') do
      post :create, forum_id: forum.id, topic_id: topic.id, post: { body: 'Creating a post for testing' }
    end
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'admin edit' do
    login_as admin
    get :edit, forum_id: forum.id, topic_id: topic.id, id: post_object.id
    must_respond_with :success
  end

  it 'admin update' do
    login_as admin
    put :update, forum_id: forum.id, topic_id: topic.id, id: post_object.id, post: { body: 'Updating the body' }
    post_object.reload
    post_object.body.must_equal 'Updating the body'
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end

  it 'admin delete' do
    login_as admin
    assert_difference('Post.count', -1) do
      delete :destroy, forum_id: forum.id, topic_id: topic.id, id: post_object.id
    end
    must_redirect_to forum_topic_path(forum.id, topic.id)
  end
end
