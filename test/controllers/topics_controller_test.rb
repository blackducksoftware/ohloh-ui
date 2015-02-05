require 'test_helper'

describe TopicsController do
  let(:forum) { create(:forum) }
  let(:user) { create(:account) }
  let(:admin) { create(:admin) }
  let(:topic) { create(:topic) }
  let(:topic_post) { create(:post) }

  #-------------User with no account---------------
  it 'index' do
    get :index, forum_id: forum.id
    must_redirect_to forum_path(forum)
  end

  it 'new' do
    get :new, forum_id: forum.id
    must_respond_with :unauthorized
  end

  it 'create should fail if not signed in' do
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: 'Example Topic title', posts_attributes:
                                                [{ body: 'Example Post body', account_id: nil }] }
    end
    must_respond_with :unauthorized
  end

  it 'show with post pagination' do
    create_list(:post, 31)
    get :show, id: topic.id
    must_respond_with :success
    # There should be 25 posts max per page
    css_select 'html body div#page.container div#page-contents div#topics_show_page.col-md-13 div.span12 div', 25
  end

  it 'edit' do
    get :edit, id: topic.id
    must_respond_with :unauthorized
  end

  it 'update' do
    put :update, id: topic.id, topic: { title: 'Changed title for test purposes' }
    topic.reload
    topic.title.must_equal topic.title
  end

  it 'destroy' do
    topic2 = create(:topic)
    assert_no_difference('Topic.count') do
      delete :destroy, id: topic2.id
    end
  end

  # #--------------Basic User ----------------------
  it 'user index' do
    login_as user
    get :index, forum_id: forum.id
    must_redirect_to forum_path(forum)
  end

  it 'user new' do
    login_as user
    get :new, forum_id: forum.id
    must_respond_with :success
  end

  it 'user create a topic and an accompanying post' do
    login_as(user)
    assert_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: 'Example Forum', posts_attributes:
                                                [{ body: 'Post object that comes by default' }] }
    end
    must_redirect_to forum_path(forum.id)
    flash[:notice].must_equal 'Topic successfully created'
  end

  it 'user fails to create a topic and an accompanying post' do
    login_as(user)
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: '', posts_attributes:
                                                [{ body: '' }] }
    end
    must_render_template :new
  end

  test 'user creates a topic/post with valid recaptcha' do
    # TODO: Message might be changed
    login_as(user)
    TopicsController.any_instance.expects(:verify_recaptcha).returns(true)
    assert_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: 'Example Forum', posts_attributes:
                                                [{ body: 'Post object that comes by default' }] }
    end
    must_redirect_to forum_path(forum.id)
    flash[:notice].must_equal 'Topic successfully created'
  end

  test 'user fails to create a topic/post because of invalid recaptcha' do
    # TODO: message might be changed.
    login_as(user)
    TopicsController.any_instance.expects(:verify_recaptcha).returns(false)
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: 'Example Forum', posts_attributes:
                                                [{ body: 'Post object that comes by default' }] }
    end
  end

  it 'user show with post pagination' do
    create_list(:post, 31)
    login_as user
    get :show, id: topic.id
    must_respond_with :success
    # There should be 25 posts max per page
    css_select 'html body div#page.container div#page-contents div#topics_show_page.col-md-13 div.span12 div', 25
  end

  it 'user edit' do
    login_as user
    get :edit, id: topic.id
    must_respond_with :unauthorized
  end

  it 'user update' do
    login_as user
    put :update, id: topic.id, topic: { title: 'Changed title for test purposes' }
    topic.reload
    topic.title.must_equal topic.title
    must_respond_with :unauthorized
  end

  it 'user destroy' do
    login_as user
    topic2 = create(:topic)
    assert_no_difference('Topic.count') do
      post :destroy, id: topic2.id
    end
    must_respond_with :unauthorized
  end

  # #-----------Admin Account------------------------
  it 'admin index' do
    login_as admin
    get :index, forum_id: forum.id
    must_redirect_to forum_path(forum)
  end

  it 'admin new' do
    login_as admin
    get :new, forum_id: forum.id
    must_respond_with :success
  end

  it 'admin create a topic and accompanying post' do
    login_as(admin)
    assert_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: 'Example Topic', posts_attributes:
                                                [{ body: 'Post object that comes by default' }] }
    end
    must_redirect_to forum_path(forum.id)
    flash[:notice].must_equal 'Topic successfully created'
  end

  it 'admin fails create a topic and an accompanying post' do
    login_as(admin)
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: '', posts_attributes:
                                                [{ body: '' }] }
    end
    must_render_template :new
  end

  it 'admin creates a topic/post with valid recaptcha' do
    # TODO: Message might change
    login_as(admin)
    TopicsController.any_instance.expects(:verify_recaptcha).returns(true)
    assert_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: 'Example Forum', posts_attributes:
                                                [{ body: 'Post object that comes by default' }] }
    end
    assert_redirected_to forum_path(forum.id)
  end

  it 'admin fails to create a topic/post because of invalid recaptcha' do
    # TODO: Message might change.
    login_as(admin)
    TopicsController.any_instance.expects(:verify_recaptcha).returns(false)
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: 'Example Forum', posts_attributes:
                                                [{ body: 'Post object that comes by default' }] }
    end
  end

  it 'admin show with post pagination' do
    create_list(:post, 26)
    get :show, id: topic.id
    must_respond_with :success
    # There should be 25 posts max per page
    css_select 'html body div#page.container div#page-contents div#topics_show_page.col-md-13 div.span12 div', 25
  end

  it 'admin edit' do
    login_as admin
    get :edit, id: topic.id
    must_respond_with :success
  end

  it 'admin update' do
    login_as admin
    put :update, id: topic.id, topic: { title: 'Changed title for test purposes' }
    topic.reload
    topic.title.must_equal 'Changed title for test purposes'
    flash[:notice].must_equal 'Topic updated'
  end

  it 'admin fails to update' do
    login_as admin
    put :update, id: topic.id, topic: { title: '' }
    topic.reload
    topic.title.must_equal topic.title
    flash[:notice].must_equal 'Sorry, there was a problem updating the topic'
  end

  it 'admin destroy' do
    login_as admin
    topic2 = create(:topic)
    assert_difference('Topic.count', -1) do
      delete :destroy, id: topic2.id
    end
    must_redirect_to forums_path
  end

  it 'admin can close a topic' do
    # TODO: Will need to change the message for this
    login_as admin
    put :update, id: topic.id, topic: { closed: true }
    topic.reload
    topic.closed.must_equal true
  end

  it 'admin can reopen a topic' do
    # TODO: Will need to change the message for this
    login_as admin
    topic.closed = true
    topic.reload
    put :update, id: topic.id, topic: { closed: false }
    topic.closed.must_equal false
  end

  it 'admin can move a topic' do
    different_topic = create(:topic)
    login_as admin
    put :update, id: topic.id, topic: { forum_id: different_topic.forum_id }
    topic.reload
    topic.forum_id.must_equal different_topic.forum_id
  end
end
