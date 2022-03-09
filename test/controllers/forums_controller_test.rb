# frozen_string_literal: true

require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  let(:forum) { create(:forum) }
  let(:admin) { create(:admin) }
  let(:user) { create(:account) }

  #----------------Admin functionality----------
  it 'admin index' do
    get :index
    assert_response :success
  end

  it 'admin new' do
    login_as admin
    get :new
    assert_response :success
  end

  it 'admin create' do
    login_as admin
    assert_difference('Forum.count', 1) do
      post :create, params: { forum: { name: 'Ruby vs. Javascript, who will win?' } }
    end
    assert_redirected_to forums_path
  end

  it 'admin fails create for blank name' do
    login_as admin
    assert_no_difference('Forum.count') do
      post :create, params: { forum: { name: '' } }
    end
    assert_template :new
    _(flash[:alert]).must_equal 'There was a problem!'
  end

  it 'admin fails create for position field with text' do
    login_as admin
    assert_no_difference('Forum.count') do
      post :create, params: { forum: { name: 'Valid Forum Name', position: 'abcdef' } }
    end
    assert_template :new
    _(flash[:alert]).must_equal 'There was a problem!'
  end

  it 'admin fails create for position field for floating point' do
    login_as admin
    assert_no_difference('Forum.count') do
      post :create, params: { forum: { name: 'Valid Forum Name', position: 1.2 } }
    end
    assert_template :new
    _(flash[:alert]).must_equal 'There was a problem!'
  end

  it 'admin fails create for position field for floating point' do
    login_as admin
    assert_no_difference('Forum.count') do
      post :create, params: { forum: { name: 'Valid Forum Name', position: 9_987_654_321 } }
    end
    assert_template :new
    _(flash[:alert]).must_equal 'There was a problem!'
  end

  it 'admin show with pagination' do
    create_list(:topic, 20, :with_posts, forum: forum)
    login_as create(:account)
    assert_response :success

    get :show, params: { id: forum.id }
    # Should have 15 topics per page
    html = 'table.table.table-striped tbody tr'
    assert_select html, 15
  end

  it 'admin edit' do
    login_as admin
    get :edit, params: { id: forum.id }
    assert_response :success
  end

  it 'admin update' do
    login_as admin
    put :update,
        params: { id: forum.id, forum: { name: 'Ruby vs. Python vs. Javascript deathmatch', description: 'Ruby' } }
    forum.reload
    _(forum.name).must_equal 'Ruby vs. Python vs. Javascript deathmatch'
    _(forum.description).must_equal 'Ruby'
  end

  it 'admin fails to update' do
    login_as admin
    put :update, params: { id: forum.id, forum: { name: '' } }
    forum.reload
    _(forum.name).must_equal forum.name
    _(flash[:alert]).must_equal 'There was a problem saving!'
  end

  it 'admin destroy' do
    forum = create(:forum)
    login_as admin
    assert_difference('Forum.count', -1) do
      delete :destroy, params: { id: forum.id }
    end
    assert_redirected_to forums_path
  end

  #------------------User Functionality----------------------
  it 'index' do
    login_as user
    get :index
    assert_response :success
  end

  it 'new' do
    login_as user
    get :new
    assert_response :unauthorized
  end

  it 'create fails for a regular user' do
    login_as user
    assert_no_difference('Forum.count') do
      post :create, params: { forum: { name: 'Ruby vs. Javascript, who will win?' } }
    end
    assert_response :unauthorized
  end

  it 'show should render for unlogged user' do
    create_list(:topic, 20)
    login_as nil
    get :show, params: { id: forum.id }
    assert_response :success
  end

  it 'show with pagination' do
    create_list(:topic, 20, :with_posts, forum: forum)
    login_as create(:account)

    get :show, params: { id: forum.id }

    assert_response :success

    # Should have 15 topics per page
    html = 'table.table.table-striped tbody tr'
    assert_select html, 15
  end

  it 'edit' do
    login_as user
    get :edit, params: { id: forum.id }
    assert_response :unauthorized
  end

  it 'update' do
    login_as user
    put :update, params: { id: forum.id, forum: { name: 'Ruby vs. Python vs. Javascript deathmatch' } }
    forum.reload
    _(forum.name).must_equal forum.name
    assert_response :unauthorized
  end

  it 'destroy' do
    forum = create(:forum)
    login_as user
    assert_no_difference('Forum.count') do
      delete :destroy, params: { id: forum.id }
    end
    assert_response :unauthorized
  end

  it 'destroy gracefully handles errors' do
    forum = create(:forum)
    login_as create(:admin)
    Forum.any_instance.expects(:destroy).returns(false)
    assert_no_difference('Forum.count') do
      delete :destroy, params: { id: forum.id }
    end
    assert_redirected_to forums_path
  end
end
