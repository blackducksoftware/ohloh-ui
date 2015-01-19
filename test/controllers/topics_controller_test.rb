require 'test_helper'

describe TopicsController do
  let(:forum) { forums(:rails) }
  let(:user) { accounts(:user) }
  let(:admin) { accounts(:admin) }
  let(:topic) { topics(:ponies) }

  #-------------User with no account---------------
  it 'index' do
    get :index, forum_id: forum.id
    must_redirect_to forum_path(forum)
  end

  it 'new' do
    get :new, forum_id: forum.id
    must_respond_with :unauthorized
  end

  it 'create' do
    assert_no_difference(['Topic.count', 'Post.count']) do
      post :create, forum_id: forum.id, topic: { title: 'Example Forum', posts_attributes:
                                                [{ body: 'Post object that comes by default', account_id: admin.id }] }
    end
  end

  it 'show' do
    get :show, forum_id: forum.id, id: topic.id
    must_respond_with :success
  end

  it 'edit' do
    get :edit, forum_id: forum.id, id: topic.id
    must_respond_with :unauthorized
  end

  it 'update' do
    assert_no_difference('Topic.count', 'Post.count') do
      put :update, forum_id: forum.id, id: topic.id, topic: { title: 'Example Forum' }
    end
  end

  it 'destroy' do
    assert_no_difference('Topic.count') do
      delete :destroy, forum_id: forum.id, id: topic.id
    end
  end

  #--------------Basic User ----------------------
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
  end

  it 'user show' do
    login_as user
    get :show, forum_id: forum.id, id: topic.id
    must_respond_with :success
  end

  it 'user edit' do
    login_as user
    get :edit, forum_id: forum.id, id: topic.id
    must_respond_with :unauthorized
  end

  it 'user update' do
    login_as user
    put :update, id: topic.id, forum_id: forum.id, topic: { title: 'Changed title for test purposes' }
    topic.reload
    topic.title.must_equal 'ponies'
  end

  it 'user destroy' do
    login_as user
    assert_no_difference('Topic.count') do
      delete :destroy, forum_id: forum.id, id: topic.id
    end
  end

  #-----------Admin Account------------------------
  it 'admin index' do
    login_as admin
    get :index, forum_id: forum.id
    must_redirect_to forum_path(forum)
  end

  it 'admin new' do
    login_as(admin)
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
  end

  it 'admin show' do
    login_as admin
    get :show, forum_id: forum.id, id: topic.id
    must_respond_with :success
  end

  it 'admin edit' do
    login_as(admin)
    get :edit, forum_id: forum.id, id: topic.id
    must_respond_with :success
  end

  it 'admin update' do
    login_as(admin)
    put :update, forum_id: forum.id, id: topic.id, topic: { title: 'Changed title for test purposes' }
    topic.reload
    topic.title.must_equal 'Changed title for test purposes'
  end

  it 'admin destroy' do
    login_as admin
    assert_difference('Topic.count', -1) do
      delete :destroy, forum_id: forum.id, id: topic.id
    end
    must_redirect_to forums_path
  end

  it 'admin destryoing a topic deletes the associated posts' do
    login_as admin
    topic.destroy
    topic.posts_count.must_equal 0
  end

  it 'admin can close a topic' do
    login_as admin
    put :update, forum_id: forum.id, id: topic.id, topic: { closed: true }
    topic.reload
    topic.closed.must_equal true
  end

  it 'admin can reopen a topic' do
    login_as admin
    topic.closed = true
    topic.reload
    put :update, forum_id: forum.id, id: topic.id, topic: { closed: false }
    topic.closed.must_equal false
  end

  it 'admin can move a topic' do
    new_forum = forums(:ponies)
    login_as admin
    put :update, forum_id: forum.id, id: topic.id, topic: { forum_id: new_forum.id }
    topic.reload
    new_forum.id.must_equal topic.forum_id
    topic.title.must_equal new_forum.topics.first.title
    new_forum.topics.count.must_equal 1
  end
end
