require 'test_helper'

describe PostsController do
  let(:forum) { create(:forum) }
  let(:user) { create(:account) }
  let(:admin) { create(:admin) }
  let(:topic) { create(:topic) }
  let(:post_object) { create(:post) }
  before { ActionMailer::Base.deliveries.clear }

  #---------------------------User without an account------------------------
  describe 'index sort' do
    # Remove fixture data.
    # TODO: Remove when all models are independent of fixture data.
    before { Post.destroy_all }

    it 'index should handle search for unlogged users' do
      login_as nil
      create(:post, body: 'oldest', created_at: Time.now - 2.hours)
      create(:post, body: 'newest', created_at: Time.now)
      get :index, sort: 'newest'
      must_respond_with :ok
      response.body.must_match(/newest.*oldest/m)
    end

    it 'index should handle query param that matches no project' do
      get :index, query: 'qwertyuioplkjhgfdsazxcvbnm'
      must_respond_with :ok
      must_select 'div.advanced_search_tips', true
    end

    it 'sorts index posts by newest' do
      create(:post, body: 'oldest', created_at: Time.now - 2.hours)
      create(:post, body: 'newest', created_at: Time.now)
      get :index, sort: 'newest'
      must_respond_with :ok
      response.body.must_match(/newest.*oldest/m)
    end

    it 'sorts index posts by unanswered' do
      create(:post, body: 'post_count_1')
      create_list(:post, 2, body: 'answered', topic: topic)
      get :index, sort: 'unanswered'
      must_respond_with :ok
      response.body.must_match(/post_count_1/)
      response.body.wont_match(/\Aanswered/)
    end

    it 'filters index by query parameter' do
      create(:post, body: 'Mozilla')
      create(:post, body: 'Apache')
      create(:post, body: 'Google')
      create(:post, body: 'Dropbox')
      get :index, query: 'Mozilla'
      must_respond_with :ok
      response.body.must_match(/Mozilla/)
      response.body.wont_match(/Apache/)
      response.body.wont_match(/Google/)
      response.body.wont_match(/Dropbox/)
    end

    it 'filters index by query parameter and sorts by newest' do
      create(:post, body: 'first Mozilla', created_at: Time.now - 3.hours)
      create(:post, body: 'second Mozilla', created_at: Time.now - 2.hours)
      create(:post, body: 'third Mozilla', created_at: Time.now)
      create(:post, body: 'Dropbox', created_at: Time.now - 4.hours)
      get :index, query: 'Mozilla', sort: 'newest'
      must_respond_with :ok
      response.body.must_match(/third\sMozilla.*second\sMozilla.*first\sMozilla/m)
      response.body.wont_match(/Dropbox/)
    end

    it 'filters index by query parameter and sorts by unanswered' do
      create(:post, body: 'Mozilla unanswered')
      create_list(:post, 2, body: 'Mozilla answered', topic: topic)
      get :index, query: 'Mozilla', sort: 'unanswered'
      must_respond_with :ok
      response.body.must_match(/Mozilla\sunanswered/)
      response.body.wont_match(/Mozilla\sanswered/)
    end
  end

  describe 'account index sort' do
    before { Post.destroy_all }

    it 'fails to find a match' do
      get :index, account_id: user, query: 'qwertyuioplkjhgfdsazxcvbnm'
      must_respond_with :ok
      must_select 'div.advanced_search_tips', true
    end

    it 'sorts by unanswered' do
      create(:post, account: user, body: 'post_count_1')
      create_list(:post, 2, body: 'answered', topic: topic)
      get :index, account_id: user, sort: 'unanswered'
      must_respond_with :ok
      response.body.must_match(/post_count_1/)
      response.body.wont_match(/\Aanswered/)
    end

    it 'sorts by newest' do
      create(:post, account: user, body: 'oldest', created_at: Time.now - 2.hours)
      create(:post, account: user, body: 'newest', created_at: Time.now)
      get :index, account_id: user, sort: 'newest'
      must_respond_with :ok
      response.body.must_match(/newest.*oldest/m)
    end

    it 'filters index by query parameter' do
      create(:post, account: user, body: 'Mozilla')
      create(:post, account: user, body: 'Apache')
      create(:post, account: user, body: 'Google')
      create(:post, account: user, body: 'Dropbox')
      get :index, account_id: user, query: 'Mozilla'
      must_respond_with :ok
      response.body.must_match(/Mozilla/)
      response.body.wont_match(/Apache/)
      response.body.wont_match(/Google/)
      response.body.wont_match(/Dropbox/)
    end

    it 'filters index by query parameter and sorts by newest' do
      create(:post, account: user, body: 'first Mozilla', created_at: Time.now - 3.hours)
      create(:post, account: user, body: 'second Mozilla', created_at: Time.now - 2.hours)
      create(:post, account: user, body: 'third Mozilla', created_at: Time.now)
      create(:post, account: user, body: 'Dropbox', created_at: Time.now - 4.hours)
      get :index, account_id: user, query: 'Mozilla', sort: 'newest'
      must_respond_with :ok
      response.body.must_match(/third\sMozilla.*second\sMozilla.*first\sMozilla/m)
      response.body.wont_match(/Dropbox/)
    end

    it 'filters index by query parameter and sorts by unanswered' do
      create(:post, account: user, body: 'Mozilla unanswered')
      create_list(:post, 2, account: user, body: 'Mozilla answered', topic: topic)
      get :index, account_id: user, query: 'Mozilla', sort: 'unanswered'
      must_respond_with :ok
      response.body.must_match(/Mozilla\sunanswered/)
      response.body.wont_match(/Mozilla\sanswered/)
    end
  end

  it 'create fails for user with no account' do
    assert_no_difference('Post.count') do
      post :create, topic_id: topic.id, post: { body: 'Creating a post for testing' }
    end
  end

  it 'edit' do
    get :edit, topic_id: topic.id, id: post_object.id
    must_respond_with :unauthorized
  end

  it 'update' do
    put :update, topic_id: topic.id, id: post_object.id, post: { body: 'Updating the body' }
    post_object.reload
    post_object.body.must_equal post_object.body
    must_respond_with :unauthorized
  end

  it 'delete' do
    post_object2 = create(:post)
    assert_no_difference('Post.count') do
      delete :destroy, topic_id: topic.id, id: post_object2.id
    end
  end

  # #-------------------Basic User-------------------------
  it 'user index' do
    login_as user
    get :index
    must_respond_with :ok
  end

  it 'create action: valid recaptcha' do
    login_as(user)
    PostsController.any_instance.expects(:verify_recaptcha).returns(true)
    assert_difference('Post.count') do
      post :create, topic_id: topic.id, post: { body: 'A valid post with valid recaptcha' }
    end
    must_redirect_to topic_path(topic)
  end

  it 'create action: invalid recaptcha' do
    login_as(user)
    PostsController.any_instance.expects(:verify_recaptcha).returns(false)
    assert_no_difference('Post.count') do
      post :create, topic_id: topic.id, post: { body: 'A valid post with valid recaptcha' }
    end
  end

  it 'create action: a user creates a post for the first time' do
    login_as user
    assert_difference(['Post.count', 'ActionMailer::Base.deliveries.size'], 1) do
      post :create, topic_id: topic.id, post: { body: 'Creating a post for the first time.' }
    end
    email = ActionMailer::Base.deliveries.last
    email.to.must_equal [user.email]
    email.subject.must_equal 'Post successfully created'
    must_redirect_to topic_path(topic.id)
  end

  it 'create action: user2 replying to user1 receives a creation email while user1 receives a reply email' do
    user2 = user
    login_as user2

    post_object.topic.account = post_object.account
    user1 = post_object.topic.account

    assert_difference('ActionMailer::Base.deliveries.size', 2) do
      post :create, topic_id: post_object.topic.id, post: { body: 'Post reply gets sent to User 1.
                                                                    Post creation gets sent to User 2' }
    end
    email = ActionMailer::Base.deliveries
    email.first.to.must_equal [user1.email]
    email.first.subject.must_equal 'Someone has responded to your post'
    email.last.to.must_equal [user2.email]
    email.last.subject.must_equal 'Post successfully created'
    must_redirect_to topic_path(post_object.topic.id)
  end

  it 'create action: users who have posted more than once on a topic receive only one email notification' do
    topic = create(:topic_with_posts)
    # Setting the posts
    # 1. Set the first and last post's account as the creator of the topic
    #    in order to replicate post creation and reply by the same user.
    topic.posts[0].account = topic.account
    topic.posts[2].account = topic.account
    topic.save
    topic.reload
    # Sign in and reply as the last user to reply.
    last_user = user
    login_as last_user
    assert_difference(['ActionMailer::Base.deliveries.size'], 3) do
      post :create, topic_id: topic.id, post: { body: 'This post should trigger a cascade
                                                                      of emails being sent to all preceding users' }
    end
    email = ActionMailer::Base.deliveries
    # First response email should go to the originator of the topic/post
    email.first.to.must_equal [topic.posts[0].account.email]
    email.first.subject.must_equal 'Someone has responded to your post'
    # Second response email should go to the second person who posted to the original.
    email[1].to.must_equal [topic.posts[1].account.email]
    email[1].subject.must_equal 'Someone has responded to your post'
    # Third email
    email.last.to.must_equal [last_user.email]
    email.last.subject.must_equal 'Post successfully created'
    must_redirect_to topic_path(topic.id)
  end

  it 'create action: A user who replies to his own post will not receive
        a post notification email while everyone else does.' do
    topic = create(:topic_with_posts)
    # Setting the posts
    # 1. Set the first and last post's account as the creator of the topic
    #    in order to replicate post creation and reply by the same user.
    topic.posts[0].account = topic.account
    topic.posts[2].account = topic.account
    topic.save
    topic.reload

    # Sign in and reply as the last user to reply.
    last_user = topic.account
    login_as last_user
    assert_difference(['ActionMailer::Base.deliveries.size'], 2) do
      post :create, topic_id: topic.id, post: { body: 'last_user replies to his own post' }
    end

    email = ActionMailer::Base.deliveries
    email.first.to.must_equal [topic.posts[1].account.email]
    email.first.subject.must_equal 'Someone has responded to your post'
    email.last.to.must_equal [last_user.email]
    email.last.subject.must_equal 'Post successfully created'
    must_redirect_to topic_path(topic.id)
  end

  it 'user edits their own post' do
    login_as post_object.account
    get :edit, topic_id: post_object.topic.id, id: post_object.id
    must_respond_with :success
  end

  it 'user cannot edit their own post' do
    login_as user
    get :edit, topic_id: post_object.topic.id, id: post_object.id
    must_redirect_to topic_path(post_object.topic)
  end

  it 'user updates their own post' do
    login_as post_object.account
    put :update, topic_id: post_object.topic.id, id: post_object.id, post: { body: 'Updating the body' }
    post_object.reload
    post_object.body.must_equal 'Updating the body'
    must_redirect_to topic_path(post_object.topic.id)
  end

  it 'update gracefully handles errors' do
    Post.any_instance.expects(:update).returns(false)
    login_as post_object.account
    put :update, topic_id: post_object.topic.id, id: post_object.id, post: { body: 'Updating the body' }
    post_object.reload
    post_object.body.wont_equal 'Updating the body'
    must_redirect_to topic_path(post_object.topic.id, post: { body: post_object.body }, anchor: 'post_reply')
  end

  it 'user cannot edit someone else\'s post' do
    login_as user
    get :edit, topic_id: post_object.topic.id, id: post_object.id
    must_redirect_to topic_path(post_object.topic.id)
  end

  # #-------------------Admin-------------------------------
  it 'admin index' do
    login_as admin
    get :index
    must_respond_with :ok
  end

  it 'admin create' do
    login_as admin
    assert_difference('Post.count') do
      post :create, topic_id: topic.id, post: { body: 'Creating a post for testing' }
    end
    must_redirect_to topic_path(topic.id)
  end

  it 'admin fails create' do
    login_as admin
    assert_no_difference('Post.count') do
      post :create, topic_id: topic.id, post: { body: nil }
    end
    must_redirect_to topic_path(topic.id) + '?post%5Bbody%5D=#post_reply'
  end

  it 'create action: valid recaptcha' do
    login_as(admin)
    PostsController.any_instance.expects(:verify_recaptcha).returns(true)
    assert_difference('Post.count') do
      post :create, topic_id: topic.id, post: { body: 'A valid post with valid recaptcha' }
    end
    must_redirect_to topic_path(topic)
  end

  it 'create action: invalid recaptcha' do
    login_as(admin)
    PostsController.any_instance.expects(:verify_recaptcha).returns(false)
    assert_no_difference('Post.count') do
      post :create, topic_id: topic.id, post: { body: 'A valid post with valid recaptcha' }
    end
  end

  it 'admin edit page' do
    login_as admin
    topic.id = post_object.topic_id
    get :edit, topic_id: topic.id, id: post_object.id
    must_respond_with :success
  end

  it 'admin update' do
    login_as admin
    put :update, topic_id: topic.id, id: post_object.id, post: { body: 'Admin status edit' }
    post_object.reload
    post_object.body.must_equal 'Admin status edit'
    must_redirect_to topic_path(topic.id)
  end

  it 'admin delete' do
    login_as admin
    post_object2 = create(:post)
    assert_difference('Post.count', -1) do
      delete :destroy, topic_id: post_object2.topic.id, id: post_object2.id
    end
    must_redirect_to topic_path(post_object2.topic.id)
  end

  it 'destroy gracefully handles errors' do
    post_object2 = create(:post)
    login_as create(:admin)
    Post.any_instance.expects(:destroy).returns(false)
    assert_no_difference('Post.count') do
      delete :destroy, topic_id: post_object2.topic.id, id: post_object2.id
    end
    must_redirect_to topic_path(post_object2.topic.id)
  end
end
