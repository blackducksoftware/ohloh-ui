# frozen_string_literal: true

require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  let(:forum) { create(:forum) }
  let(:user) { create(:account) }
  let(:admin) { create(:admin) }
  let(:topic) { create(:topic) }
  let(:topic_post) { create(:post) }

  let(:topic_params) do
    { title: Faker::Lorem.sentence, account_id: user.id,
      posts_attributes: { '0' => { account_id: user.id, body: Faker::Lorem.sentence } } }
  end

  #-------------User with no account---------------
  describe 'index' do
    it 'with forum id' do
      get :index, params: { forum_id: forum.id }
      assert_redirected_to forum_path(forum)
    end

    it 'without forum id' do
      get :index
      assert_redirected_to forums_path
    end
  end

  it 'new' do
    get :new, params: { forum_id: forum.id }
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  it 'create should fail if not signed in' do
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params }
    end
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  it 'show with post pagination' do
    create_list(:post, 31, topic: topic)
    create(:topic, forum: topic.forum, sticky: 0)

    get :show, params: { id: topic.id }

    assert_response :success
    _(assigns(:posts).length).must_equal TopicDecorator::PER_PAGE
    assert_select '.posts', TopicDecorator::PER_PAGE
  end

  it 'show responds to atom format' do
    create_list(:post, 5, topic: topic)
    get :show, params: { id: topic, format: 'atom' }
    assert_response :ok
  end

  it 'show responds to rss format' do
    create_list(:post, 5, topic: topic)
    get :show, params: { id: topic, format: 'rss' }
    assert_template 'show.atom.builder'
    assert_response :ok
  end

  it 'show should render markdown as html' do
    post = create(:post, body: '**Markdown Me**')
    get :show, params: { id: post.topic.id }
    assert_response :ok
    _(response.body).must_match '<p><strong>Markdown Me</strong></p>'
  end

  it 'edit' do
    get :edit, params: { id: topic.id }
    assert_response :unauthorized
  end

  it 'admin must be able to update successfully' do
    login_as admin
    title = Faker::Lorem.sentence
    put :update, params: { id: topic.id, topic: { title: title, account_id: user.id } }
    topic.reload
    _(topic.title).must_equal title
  end

  it 'destroy' do
    topic2 = create(:topic)
    assert_no_difference('Topic.count') do
      delete :destroy, params: { id: topic2.id }
    end
  end

  describe 'track views' do
    it 'should increment when not logged in' do
      before_hits = topic.hits
      get :show, params: { id: topic.id }
      assert_response :success
      _(topic.reload.hits).must_equal before_hits + 1
    end

    it 'should increment when topic account does not match current user' do
      before_hits = topic.hits
      get :show, params: { id: topic.id }
      assert_response :success
      _(topic.reload.hits).must_equal before_hits + 1
    end

    it 'should not increment when logged in' do
      login_as user
      get :show, params: { id: topic.id }
      assert_response :success
      _(topic.hits).wont_equal topic.hits += 1
    end
  end

  # #--------------Basic User ----------------------
  describe 'index' do
    it 'with forum id' do
      login_as user
      get :index, params: { forum_id: forum.id }
      assert_redirected_to forum_path(forum)
    end

    it 'without forum id' do
      get :index
      assert_redirected_to forums_path
    end
  end

  it 'user new' do
    login_as user
    get :new, params: { forum_id: forum.id }
    assert_response :success
  end

  it 'user create a topic and an accompanying post' do
    login_as(user)
    assert_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params }
    end
    assert_redirected_to forum_path(forum.id)
  end

  it 'wont create a topic with blank title' do
    login_as(user)

    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params.merge(title: '') }
    end

    _(assigns(:topic).errors.messages[:title]).must_be :present?
    assert_template :new
  end

  it 'wont create a post with blank body' do
    login_as(user)

    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params.deep_merge(
        posts_attributes: { '0' => { body: '', account_id: user.id } }
      ) }
    end

    _(assigns(:topic).errors.messages[:'posts.body']).must_be :present?
    assert_template :new
  end

  it 'wont create a topic under a different user' do
    login_as(user)
    account = create(:account)

    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params.merge(account_id: account.id) }
    end

    assert_redirected_to new_session_path
    _(flash[:error]).must_equal I18n.t(:cant_edit_other_account)
  end

  it 'wont create a topic with post having a different user' do
    login_as(user)
    account = create(:account)

    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params.deep_merge(
        posts_attributes: { '0' => { body: Faker::Lorem.word, account_id: account.id } }
      ) }
    end

    assert_redirected_to new_session_path
    _(flash[:error]).must_equal I18n.t(:cant_edit_other_account)
  end

  it 'user creates a topic/post with valid recaptcha' do
    login_as(user)
    TopicsController.any_instance.expects(:verify_recaptcha).returns(true)
    assert_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params }
    end
    assert_redirected_to forum_path(forum.id)
  end

  test 'user fails to create a topic/post because of invalid recaptcha' do
    login_as(user)
    TopicsController.any_instance.expects(:verify_recaptcha).returns(false)
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params }
    end
  end

  it 'user show with post pagination' do
    create_list(:post, 31, topic: topic)
    login_as user

    get :show, params: { id: topic.id }

    assert_response :success
    assert_select '.posts', TopicDecorator::PER_PAGE
  end

  it 'user show responds to atom format' do
    login_as user
    create_list(:post, 5, topic: topic)
    get :show, params: { id: topic, format: 'atom' }
    assert_response :ok
  end

  it 'user edit' do
    login_as user
    get :edit, params: { id: topic.id }
    assert_response :unauthorized
  end

  it 'user should not be able to update' do
    login_as user
    title = Faker::Lorem.sentence

    put :update, params: { id: topic.id, topic: { title: title } }

    topic.reload
    _(topic.title).wont_equal title
    assert_response :unauthorized
  end

  # #-----------Admin Account------------------------
  describe 'index' do
    it 'with forum id' do
      login_as admin
      get :index, params: { forum_id: forum.id }
      assert_redirected_to forum_path(forum)
    end

    it 'without forum id' do
      get :index
      assert_redirected_to forums_path
    end
  end

  it 'admin new' do
    login_as admin
    get :new, params: { forum_id: forum.id }
    assert_response :success
  end

  it 'admin create a topic and accompanying post' do
    login_as(admin)
    assert_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params }
    end
    assert_redirected_to forum_path(forum.id)
  end

  it 'admin fails create a topic and an accompanying post' do
    login_as(admin)
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: { title: '', posts_attributes: { '0' => { body: '' } } } }
    end
    assert_template :new
  end

  it 'must allow admin to create topic without captcha' do
    login_as(admin)
    TopicsController.any_instance.stubs(:verify_recaptcha).returns(false)

    assert_difference(['Topic.count', 'Post.count']) do
      post :create, params: { forum_id: forum.id, topic: topic_params }
    end
    assert_redirected_to forum_path(forum.id)
  end

  it 'admin show with post pagination' do
    create_list(:post, 26, topic: topic)

    get :show, params: { id: topic.id }

    assert_response :success
    assert_select '.posts', TopicDecorator::PER_PAGE
  end

  it 'admin edit' do
    login_as admin
    get :edit, params: { id: topic.id }
    assert_response :success
  end

  it 'admin update' do
    login_as admin
    title = Faker::Lorem.sentence
    put :update, params: { id: topic.id, topic: { title: title } }
    topic.reload
    _(topic.title).must_equal title
  end

  it 'admin fails to update' do
    login_as admin
    put :update, params: { id: topic.id, topic: { title: '' } }
    topic.reload
    _(topic.title).must_equal topic.title
    assert_template :edit
  end

  it 'admin destroy' do
    login_as admin
    topic2 = create(:topic)
    assert_difference('Topic.count', -1) do
      delete :destroy, params: { id: topic2.id }
    end
    assert_redirected_to forums_path
    _(flash[:notice]).must_equal "Topic '#{topic2.title}' was deleted."
  end

  it 'destroy gracefully handles errors' do
    login_as admin
    topic2 = create(:topic)
    Topic.any_instance.expects(:destroy).returns(false)
    assert_no_difference('Topic.count') do
      delete :destroy, params: { id: topic2.id }
    end
    assert_redirected_to forums_path
  end

  it 'admin can close a topic' do
    login_as admin
    put :update, params: { id: topic.id, topic: { closed: true } }
    topic.reload
    _(topic.closed).must_equal true
  end

  it 'admin can reopen a topic' do
    login_as admin
    topic.closed = true
    topic.reload
    put :update, params: { id: topic.id, topic: { closed: false } }
    _(topic.closed).must_equal false
  end

  it 'admin can move a topic' do
    different_topic = create(:topic)
    login_as admin
    put :update, params: { id: topic.id, topic: { forum_id: different_topic.forum_id } }
    topic.reload
    _(topic.forum_id).must_equal different_topic.forum_id
  end

  it 'admin show responds to atom format' do
    login_as admin
    create_list(:post, 5, topic: topic)
    get :show, params: { id: topic, format: 'atom' }
    assert_response :ok
  end

  describe 'show' do
    before { topic.update!(account: user) }

    it 'must show spam, close and delete links for admin' do
      login_as admin
      create_list(:post, 2, topic: topic)

      get :show, params: { id: topic }

      %w[spam close delete].each do |name|
        text = I18n.t("topics.action_group.#{name}")
        _(response.body).must_match(">#{text}</a>")
      end
    end

    it 'must show reopen link for admin when topic is closed' do
      login_as admin
      create_list(:post, 2, topic: topic)

      topic.update! closed: true
      get :show, params: { id: topic }

      text = I18n.t('topics.reopen')
      _(response.body).must_match(">#{text}</a>")
    end

    it 'wont show spam or close link to non admin' do
      login_as user

      get :show, params: { id: topic }

      %w[spam close].each do |name|
        text = I18n.t("topics.action_group.#{name}")
        _(response.body).wont_match(">#{text}</a>")
      end
    end

    it 'wont show delete link to non admin when post count is more than 1' do
      login_as user
      create_list(:post, 2, topic: topic)

      get :show, params: { id: topic }

      text = I18n.t('topics.action_group.delete')
      _(response.body).wont_match(">#{text}</a>")
    end

    it 'must show delete link to the non admin creator when post count is less than 2' do
      login_as user

      get :show, params: { id: topic }

      text = I18n.t('topics.action_group.delete')
      _(response.body).must_match(">#{text}</a>")
    end

    it 'must show reopen link to non admin creator' do
      login_as user

      topic.update! closed: true
      get :show, params: { id: topic }

      text = I18n.t('topics.reopen')
      _(response.body).must_match(">#{text}</a>")
    end
  end

  describe 'close' do
    it 'must allow access to admin users' do
      login_as admin

      get :close, params: { id: topic }

      assert_redirected_to topic_path(topic)
      _(topic.reload).must_be :closed?
    end

    it 'wont allow access to non admin creator' do
      login_as user
      topic.update!(account: user)

      get :close, params: { id: topic }

      assert_response :unauthorized
      _(topic.reload).wont_be :closed?
    end
  end

  describe 'reopen' do
    it 'must allow access to admin' do
      topic.update!(closed: true)
      login_as admin

      get :reopen, params: { id: topic }

      assert_redirected_to topic_path(topic)
      _(topic.reload).wont_be :closed?
    end

    it 'must allow access to non admin creator' do
      topic.update!(account: user, closed: true)
      login_as user

      get :reopen, params: { id: topic }

      assert_redirected_to topic_path(topic)
      _(topic.reload).wont_be :closed?
    end

    it 'wont allow access to non creator' do
      topic.update!(closed: true)
      login_as user

      get :reopen, params: { id: topic }

      assert_redirected_to new_session_path
      _(topic.reload).must_be :closed?
    end
  end

  describe 'destroy' do
    it 'must allow access to admin' do
      login_as admin

      delete :destroy, params: { id: topic }

      assert_redirected_to forums_path
      _(Topic.find_by(id: topic)).must_be_nil
    end

    it 'must allow access to topic creator' do
      topic.update!(account: user)
      login_as user

      delete :destroy, params: { id: topic }

      assert_redirected_to forums_path
      _(Topic.find_by(id: topic)).must_be_nil
    end

    it 'wont allow access to non admin creator' do
      login_as user

      delete :destroy, params: { id: topic }

      assert_redirected_to new_session_path
      _(topic.reload).must_be :present?
    end
  end
end
