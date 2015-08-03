require 'test_helper'

describe PostsController do
  let(:forum) { create(:forum) }
  let(:user) { create(:account) }
  let(:admin) { create(:admin) }
  let(:topic) { create(:topic) }
  let(:post_object) { create(:post) }

  #---------------------------User without an account------------------------
  describe 'index sort' do
    before { Post.destroy_all }

    it 'should render in atom format' do
      create_list(:post, 5)
      get :index, format: 'atom'
      must_respond_with :ok
    end

    it 'index should handle search for unlogged users' do
      login_as nil
      create(:post, body: 'oldest', created_at: Time.current - 2.hours)
      create(:post, body: 'newest', created_at: Time.current)
      get :index, sort: 'newest'
      must_respond_with :ok
      response.body.must_match(/newest.*oldest/m)
    end

    it 'index should handle query param that matches no project' do
      get :index, query: 'qwertyuioplkjhgfdsazxcvbnm'
      must_respond_with :ok
      must_select 'div.advanced_search_tips', true
    end

    it 'index should strip HTML from markdown' do
      create(:post, body: '**Markdown Me**')
      get :index
      must_respond_with :ok
      response.body.must_match 'Markdown Me'
    end

    it 'sorts index posts by newest' do
      create(:post, body: 'oldest', created_at: Time.current - 2.hours)
      create(:post, body: 'newest', created_at: Time.current)
      get :index, sort: 'newest'
      must_respond_with :ok
      response.body.must_match(/newest.*oldest/m)
    end

    it 'sorts index posts by unanswered' do
      create(:post, body: 'post_count_1')
      create_list(:post, 2, body: 'answered', topic: topic)
      get :index, sort: 'unanswered'
      must_respond_with :ok
      response.body.must_match(/postcount1/)
      response.body.wont_match(/\Aanswered/)
    end

    it 'sorts index posts by relevance' do
      post1 = create(:post, body: 'Elon Musk is cool', popularity_factor: 100)
      post2 = create(:post, body: 'Mark Zuckerberg is cool too, I guess...', popularity_factor: 200)
      get :index, query: nil, sort: 'relevance'
      must_respond_with :ok
      assigns(:posts).count 2
      assigns(:posts).first.must_equal post1
      assigns(:posts).last.must_equal post2
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
      create(:post, body: 'first Mozilla', created_at: Time.current - 3.hours)
      create(:post, body: 'second Mozilla', created_at: Time.current - 2.hours)
      create(:post, body: 'third Mozilla', created_at: Time.current)
      create(:post, body: 'Dropbox', created_at: Time.current - 4.hours)
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

    it 'sorts index posts by relevance and query (popularity_factor)' do
      post1 = create(:post, body: 'Mozilla Google Mozilla Yahoo')
      post2 = create(:post, body: 'Mozilla Google Mozilla Mozilla Google SpaceX Dropbox')
      get :index, query: 'Mozilla', sort: 'relevance'
      must_respond_with :ok
      response.body.must_match(/#{post2.body}.*#{post1.body}/m)
    end
  end

  describe 'account index sort' do
    before { Post.destroy_all }

    it 'should render in atom format' do
      create_list(:post, 5, account: user)
      get :index, account: user, format: 'atom'
      must_respond_with :ok
    end

    it 'finds no post by a user' do
      get :index, account_id: user
      must_respond_with :ok
      must_select 'div#no-posts', true
    end

    it 'redirects away from spammers' do
      get :index, account_id: create(:spammer).to_param
      must_respond_with 302
    end

    it 'sorts by unanswered' do
      create(:post, account: user, body: 'post_count_1')
      create_list(:post, 2, body: 'answered', topic: topic)
      get :index, account_id: user, sort: 'unanswered'
      must_respond_with :ok
      response.body.must_match(/postcount1/)
      response.body.wont_match(/\Aanswered/)
    end

    it 'sorts by newest' do
      create(:post, account: user, body: 'oldest', created_at: Time.current - 2.hours)
      create(:post, account: user, body: 'newest', created_at: Time.current)
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
      create(:post, account: user, body: 'first Mozilla', created_at: Time.current - 3.hours)
      create(:post, account: user, body: 'second Mozilla', created_at: Time.current - 2.hours)
      create(:post, account: user, body: 'third Mozilla', created_at: Time.current)
      create(:post, account: user, body: 'Dropbox', created_at: Time.current - 4.hours)
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

    it 'sorts index posts by relevance' do
      post1 = create(:post, account: user, body: 'Elon Musk is cool', popularity_factor: 100)
      post2 = create(:post, account: user, body: 'Mark Zuckerberg is cool too, I guess...', popularity_factor: 200)
      get :index, account: user, query: nil, sort: 'relevance'
      must_respond_with :ok
      assigns(:posts).count 2
      assigns(:posts).first.must_equal post1
      assigns(:posts).last.must_equal post2
    end
  end

  describe 'xml index' do
    it 'should render as xml' do
      get :index, format: 'atom'
      must_respond_with :ok
    end

    it 'should render as xml for account posts' do
      get :index, account: user, format: 'atom'
      must_respond_with :ok
    end

    it 'should render in rss format' do
      get :index, format: 'rss'
      must_respond_with :ok
      must_render_template 'index.atom.builder'
    end
  end

  it 'create fails for user with no account' do
    assert_no_difference('Post.count') do
      post :create, topic_id: topic.id, post: { body: 'Creating a post for testing' }
    end
  end

  it 'edit' do
    get :edit, topic_id: topic.id, id: post_object.id
    must_respond_with :redirect
    must_redirect_to new_session_path
  end

  it 'update' do
    put :update, topic_id: topic.id, id: post_object.id, post: { body: 'Updating the body' }
    post_object.reload
    post_object.body.must_equal post_object.body
    must_respond_with :redirect
    must_redirect_to new_session_path
  end

  it 'delete' do
    post_object2 = create(:post)
    assert_no_difference('Post.count') do
      delete :destroy, topic_id: topic.id, id: post_object2.id
    end
  end

  #-------------------Basic User-------------------------
  it 'user index' do
    login_as user
    get :index
    must_respond_with :ok
  end

  it 'create action: a user replies to a post for the first time' do
    topic = create(:topic) do |topic_record|
      topic_record.posts.build(body: 'Default post that comes with a topic', account_id: topic_record.account_id)
      topic_record.posts[0].save
    end

    login_as user
    ActionMailer::Base.deliveries.clear
    post :create, topic_id: topic.id, post: { body: 'Replying for the first time' }
    topic.posts.count.must_equal 2
    ActionMailer::Base.deliveries.size.must_equal 2

    email = ActionMailer::Base.deliveries

    email.first.to.must_equal [topic.account.email]
    email.first.subject.must_equal 'Someone has responded to your post'
    must_redirect_to topic_path(topic.id)

    email.last.to.must_equal [user.email]
    email.last.subject.must_equal 'Post successfully created'
    must_redirect_to topic_path(topic.id)
  end

  it 'create action: users who have posted more than once on a topic receive only one email notification' do
    topic = create(:topic_with_posts)
    # Setting the posts
    # 1. Set the first and last post's account as the creator of the topic
    #    in order to replicate post creation and reply by the same user.
    topic.posts[0].account = topic.account
    topic.posts[1].account = topic.account
    topic.save
    topic.reload
    # Sign in and reply as the last user to reply.
    last_user = user
    login_as last_user

    ActionMailer::Base.deliveries.clear
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
    # Third email goes to the user who created the last post reply.
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

    ActionMailer::Base.deliveries.clear
    post :create, topic_id: topic.id, post: { body: 'last_user replies to his own post' }

    email = ActionMailer::Base.deliveries

    email.first.to.must_equal [topic.posts[2].account.email]
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

  #-------------------Admin-------------------------------
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
