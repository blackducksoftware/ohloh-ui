# frozen_string_literal: true

require 'test_helper'

class PostsControllerTest < ActionController::TestCase
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
      get :index, params: { format: 'atom' }
      assert_response :ok
    end

    it 'index should handle search for unlogged users' do
      login_as nil
      create(:post, body: 'oldest', created_at: Time.current - 2.hours)
      create(:post, body: 'newest', created_at: Time.current)
      get :index, params: { sort: 'newest' }
      assert_response :ok
      _(response.body).must_match(/newest.*oldest/m)
    end

    it 'index should handle query param that matches no project' do
      get :index, params: { query: 'qwertyuioplkjhgfdsazxcvbnm' }
      assert_response :ok
      assert_select 'div.advanced_search_tips', true
    end

    it 'index should strip HTML from markdown' do
      create(:post, body: '**Markdown Me**')
      get :index
      assert_response :ok
      _(response.body).must_match 'Markdown Me'
    end

    it 'sorts index posts by newest' do
      create(:post, body: 'oldest', created_at: Time.current - 2.hours)
      create(:post, body: 'newest', created_at: Time.current)
      get :index, params: { sort: 'newest' }
      assert_response :ok
      _(response.body).must_match(/newest.*oldest/m)
    end

    it 'sorts index posts by most recent in default view' do
      create(:post, body: 'oldest', created_at: Time.current - 2.hours)
      create(:post, body: 'newest', created_at: Time.current)
      get :index
      assert_response :ok
      _(response.body).must_match(/newest.*oldest/m)
    end

    it 'shows index posts under open topics only' do
      create(:topic, :closed, :with_posts, posts_count: 3)
      create(:topic, :with_posts, posts_count: 5)
      get :index
      assert_response :ok
      assigns(:posts).count 5
    end

    it 'sorts index posts by unanswered' do
      create(:post, body: 'post_count_1')
      create_list(:post, 2, body: 'answered', topic: topic)
      get :index, params: { sort: 'unanswered' }
      assert_response :ok
      _(response.body).must_match(/postcount1/)
      _(response.body).wont_match(/\Aanswered/)
    end

    it 'sorts index posts by relevance' do
      post1 = create(:post, body: 'Elon Musk is cool', popularity_factor: 100, created_at: 1.day.from_now)
      post2 = create(:post, body: 'Mark Zuckerberg is cool too, I guess...', popularity_factor: 200)
      get :index, params: { query: nil, sort: 'relevance' }
      assert_response :ok
      assigns(:posts).count 2
      _(assigns(:posts).first).must_equal post1
      _(assigns(:posts).last).must_equal post2
    end

    it 'filters index by query parameter' do
      create(:post, body: 'Mozilla')
      create(:post, body: 'Apache')
      create(:post, body: 'Google')
      create(:post, body: 'Dropbox')
      get :index, params: { query: 'Mozilla' }
      assert_response :ok
      _(response.body).must_match(/Mozilla/)
      _(response.body).wont_match(/Apache/)
      _(response.body).wont_match(/Google/)
      _(response.body).wont_match(/Dropbox/)
    end

    it 'filters index by query parameter and sorts by newest' do
      create(:post, body: 'first Mozilla', created_at: Time.current - 3.hours)
      create(:post, body: 'second Mozilla', created_at: Time.current - 2.hours)
      create(:post, body: 'third Mozilla', created_at: Time.current)
      create(:post, body: 'Dropbox', created_at: Time.current - 4.hours)
      get :index, params: { query: 'Mozilla', sort: 'newest' }
      assert_response :ok
      _(response.body).must_match(/third\sMozilla.*second\sMozilla.*first\sMozilla/m)
      _(response.body).wont_match(/Dropbox/)
    end

    it 'filters index by query parameter and sorts by unanswered' do
      create(:post, body: 'Mozilla unanswered')
      create_list(:post, 2, body: 'Mozilla answered', topic: topic)
      get :index, params: { query: 'Mozilla', sort: 'unanswered' }
      assert_response :ok
      _(response.body).must_match(/Mozilla\sunanswered/)
      _(response.body).wont_match(/Mozilla\sanswered/)
    end

    it 'sorts index posts by relevance and query (popularity_factor)' do
      post1 = create(:post, body: 'Mozilla Google Mozilla Yahoo')
      post2 = create(:post, body: 'Mozilla Google Mozilla Mozilla Google SpaceX Dropbox')
      get :index, params: { query: 'Mozilla', sort: 'relevance' }
      assert_response :ok
      _(response.body).must_match(/#{post2.body}.*#{post1.body}/m)
    end
  end

  describe 'account index sort' do
    before { Post.destroy_all }

    it 'should render in atom format' do
      create_list(:post, 5, account: user)
      get :index, params: { account: user, format: 'atom' }
      assert_response :ok
    end

    it 'finds no post by a user' do
      get :index, params: { account_id: user }
      assert_response :ok
      assert_select 'div#no-posts', true
    end

    it 'must redirect for disabled account' do
      account = create(:account)
      login_as account
      account.access.spam!

      get :index, params: { account_id: account.id }

      assert_response 302
    end

    it 'sorts by unanswered' do
      create(:post, account: user, body: 'post_count_1')
      create_list(:post, 2, body: 'answered', topic: topic)
      get :index, params: { account_id: user, sort: 'unanswered' }
      assert_response :ok
      _(response.body).must_match(/postcount1/)
      _(response.body).wont_match(/\Aanswered/)
    end

    it 'sorts by newest' do
      create(:post, account: user, body: 'oldest', created_at: Time.current - 2.hours)
      create(:post, account: user, body: 'newest', created_at: Time.current)
      get :index, params: { account_id: user, sort: 'newest' }
      assert_response :ok
      _(response.body).must_match(/newest.*oldest/m)
    end

    it 'filters index by query parameter' do
      create(:post, account: user, body: 'Mozilla')
      create(:post, account: user, body: 'Apache')
      create(:post, account: user, body: 'Google')
      create(:post, account: user, body: 'Dropbox')
      get :index, params: { account_id: user, query: 'Mozilla' }
      assert_response :ok
      _(response.body).must_match(/Mozilla/)
      _(response.body).wont_match(/Apache/)
      _(response.body).wont_match(/Google/)
      _(response.body).wont_match(/Dropbox/)
    end

    it 'filters index by query parameter and sorts by newest' do
      create(:post, account: user, body: 'first Mozilla', created_at: Time.current - 3.hours)
      create(:post, account: user, body: 'second Mozilla', created_at: Time.current - 2.hours)
      create(:post, account: user, body: 'third Mozilla', created_at: Time.current)
      create(:post, account: user, body: 'Dropbox', created_at: Time.current - 4.hours)
      get :index, params: { account_id: user, query: 'Mozilla', sort: 'newest' }
      assert_response :ok
      _(response.body).must_match(/third\sMozilla.*second\sMozilla.*first\sMozilla/m)
      _(response.body).wont_match(/Dropbox/)
    end

    it 'filters index by query parameter and sorts by unanswered' do
      create(:post, account: user, body: 'Mozilla unanswered')
      create_list(:post, 2, account: user, body: 'Mozilla answered', topic: topic)
      get :index, params: { account_id: user, query: 'Mozilla', sort: 'unanswered' }
      assert_response :ok
      _(response.body).must_match(/Mozilla\sunanswered/)
      _(response.body).wont_match(/Mozilla\sanswered/)
    end

    it 'sorts index posts by relevance' do
      post1 = create(:post, account: user, body: 'Elon Musk is cool', popularity_factor: 100,
                            created_at: 1.day.from_now)
      post2 = create(:post, account: user, body: 'Mark Zuckerberg is cool too, I guess...', popularity_factor: 200)
      get :index, params: { account: user, query: nil, sort: 'relevance' }
      assert_response :ok
      assigns(:posts).count 2
      _(assigns(:posts).first).must_equal post1
      _(assigns(:posts).last).must_equal post2
    end
  end

  describe 'xml index' do
    it 'should render as xml' do
      create(:post, account: user, body: 'Elon Musk is cool', popularity_factor: 100)
      create(:post, account: user, body: 'Mark Zuckerberg is cool too, I guess...', popularity_factor: 200)
      get :index, params: { format: 'atom' }
      assert_response :ok
    end

    it 'should render as xml for account posts' do
      create(:post, account: user, body: 'Elon Musk is cool', popularity_factor: 100)
      create(:post, account: user, body: 'Mark Zuckerberg is cool too, I guess...', popularity_factor: 200)
      get :index, params: { account: user, format: 'atom' }
      assert_response :ok
    end

    it 'should render in rss format' do
      create(:post, account: user, body: 'Elon Musk is cool', popularity_factor: 100)
      get :index, params: { format: 'rss' }
      assert_response :ok
      assert_template 'index.atom.builder'
    end
  end

  describe 'update' do
    it 'update' do
      put :update, params: { topic_id: topic.id, id: post_object.id, post: { body: 'Updating the body' } }
      post_object.reload
      _(post_object.body).must_equal post_object.body
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    it 'user updates their own post' do
      login_as post_object.account
      put :update, params: { topic_id: post_object.topic.id, id: post_object.id, post: { body: 'Updating the body' } }
      post_object.reload
      _(post_object.body).must_equal 'Updating the body'
      assert_redirected_to topic_path(post_object.topic.id)
    end

    it 'update gracefully handles errors' do
      Post.any_instance.expects(:update).returns(false)
      login_as post_object.account
      put :update, params: { topic_id: post_object.topic.id, id: post_object.id, post: { body: 'Updating the body' } }
      post_object.reload
      _(post_object.body).wont_equal 'Updating the body'
      assert_template 'edit'
    end

    it 'admin update' do
      login_as admin
      put :update, params: { topic_id: topic.id, id: post_object.id, post: { body: 'Admin status edit' } }
      post_object.reload
      _(post_object.body).must_equal 'Admin status edit'
      assert_redirected_to topic_path(topic.id)
    end
  end

  it 'delete' do
    post_object2 = create(:post)
    assert_no_difference('Post.count') do
      delete :destroy, params: { topic_id: topic.id, id: post_object2.id }
    end
  end

  #-------------------Basic User-------------------------
  it 'user index' do
    login_as user
    get :index
    assert_response :ok
  end

  describe 'create' do
    it 'must let a user reply to a post for the first time' do
      topic = create(:topic) do |topic_record|
        topic_record.posts.build(body: 'Default post that comes with a topic', account_id: topic_record.account_id)
        topic_record.posts[0].save
      end

      login_as user
      ActionMailer::Base.deliveries.clear
      post :create, params: { topic_id: topic.id, post: { body: 'Replying for the first time' } }
      _(topic.posts.count).must_equal 2
      _(ActionMailer::Base.deliveries.size).must_equal 1

      email = ActionMailer::Base.deliveries

      _(email.first.to).must_equal [topic.account.email]
      _(email.first.subject).must_equal 'Someone has responded to your post'
      assert_redirected_to topic_path(topic.id)
    end

    it 'users who have posted more than once on a topic receive only one email notification' do
      topic = create(:topic, :with_posts)
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
      assert_difference(['ActionMailer::Base.deliveries.size'], 2) do
        post :create, params: { topic_id: topic.id, post: { body: 'This post should trigger a cascade
                                                                        of emails being sent to all preceding users' } }
      end
      email = ActionMailer::Base.deliveries

      _(email.first.to).must_equal [topic.posts[1].account.email]
      _(email.first.subject).must_equal 'Someone has responded to your post'
      assert_redirected_to topic_path(topic.id)
    end

    it 'a user who replies to his own post will not receive a post notification email while everyone else does.' do
      topic = create(:topic, :with_posts)
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
      post :create, params: { topic_id: topic.id, post: { body: 'last_user replies to his own post' } }

      email = ActionMailer::Base.deliveries

      _(email.first.to).must_equal [topic.posts[2].account.email]
      _(email.first.subject).must_equal 'Someone has responded to your post'
      assert_redirected_to topic_path(topic.id)
    end

    it 'should not send a post notification email respecting their email preference' do
      topic = create(:topic, :with_posts)
      topic.account.update_column('email_master', false)
      topic.posts[0].account = topic.account
      topic.save
      topic.reload

      # Sign in as someone and post it
      login_as create(:account)

      ActionMailer::Base.deliveries.clear
      post :create, params: { topic_id: topic.id, post: { body: 'last_user replies to his own post' } }
      email = ActionMailer::Base.deliveries
      _(email.map(&:to).flatten).wont_include topic.account.email
      assert_redirected_to topic_path(topic.id)
    end

    it 'fails for user with no account' do
      assert_no_difference('Post.count') do
        post :create, params: { topic_id: topic.id, post: { body: 'Creating a post for testing' } }
      end
    end

    it 'must create a post with valid recaptcha' do
      login_as(user)
      topic = create(:topic)
      PostsController.any_instance.expects(:verify_recaptcha).returns(true)
      assert_difference('Post.count', 1) do
        post :create, params: { topic_id: topic, post: { body: 'Post with valid recaptcha' } }
      end
      assert_redirected_to topic_path(topic.id)
    end

    it 'wont create a post for invalid recaptcha' do
      login_as(user)
      topic = create(:topic)
      PostsController.any_instance.expects(:verify_recaptcha).returns(false)
      assert_no_difference('Post.count', 1) do
        post :create, params: { topic_id: topic, post: { body: 'Post with invalid recaptcha' } }
      end
    end

    it 'must allow admin to create posts' do
      login_as admin

      assert_difference('Post.count') do
        post :create, params: { topic_id: topic.id, post: { body: 'Creating a post for testing' } }
      end

      assert_redirected_to topic_path(topic.id)
    end

    it 'must render topic show page on failure' do
      login_as admin

      assert_no_difference('Post.count') do
        post :create, params: { topic_id: topic.id, post: { body: nil } }
      end

      assert_template 'topics/show'
    end

    it 'must allow admin to create post without captcha' do
      login_as(admin)
      topic = create(:topic)
      PostsController.any_instance.stubs(:verify_recaptcha).returns(false)

      assert_difference('Post.count', 1) do
        post :create, params: { topic_id: topic, post: { body: Faker::Lorem.sentence } }
      end
      assert_redirected_to topic_path(topic.id)
    end
  end

  describe 'edit' do
    it 'user edits their own post' do
      login_as post_object.account
      get :edit, params: { topic_id: post_object.topic.id, id: post_object.id }
      assert_response :success
    end

    it 'user cannot edit their own post' do
      login_as user
      get :edit, params: { topic_id: post_object.topic.id, id: post_object.id }
      assert_redirected_to topic_path(post_object.topic)
    end

    it 'user cannot edit someone else\'s post' do
      login_as user
      get :edit, params: { topic_id: post_object.topic.id, id: post_object.id }
      assert_redirected_to topic_path(post_object.topic.id)
    end

    it 'admin edit page' do
      login_as admin
      topic.id = post_object.topic_id
      get :edit, params: { topic_id: topic.id, id: post_object.id }
      assert_response :success
    end

    it 'edit' do
      get :edit, params: { topic_id: topic.id, id: post_object.id }
      assert_response :redirect
      assert_redirected_to new_session_path
    end
  end

  #-------------------Admin-------------------------------
  it 'admin index' do
    login_as admin
    get :index
    assert_response :ok
  end

  it 'admin delete' do
    login_as admin
    post_object2 = create(:post, topic: topic)
    create(:post, topic: topic)

    assert_difference('Post.count', -1) do
      delete :destroy, params: { topic_id: post_object2.topic.id, id: post_object2.id }
    end
    assert_redirected_to topic_path(post_object2.topic.id)
  end

  it 'must redirect to forum path' do
    login_as admin
    post_object2 = create(:post)
    assert_difference('Post.count', -1) do
      delete :destroy, params: { topic_id: post_object2.topic.id, id: post_object2.id }
    end
    assert_redirected_to forums_path
  end

  it 'destroy gracefully handles errors' do
    post_object2 = create(:post)
    login_as create(:admin)
    Post.any_instance.expects(:destroy).returns(false)
    assert_no_difference('Post.count') do
      delete :destroy, params: { topic_id: post_object2.topic.id, id: post_object2.id }
    end
    assert_redirected_to topic_path(post_object2.topic.id)
  end
end
