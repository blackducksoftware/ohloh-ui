require 'test_helper'

describe ForumsController do
  let(:forum) { create(:forum) }
  let(:admin) { create(:admin) }
  let(:user) { create(:account) }

  #----------------Admin functionality----------
  it 'admin index' do
    get :index
    must_respond_with :success
  end

  it 'admin new' do
    login_as admin
    get :new
    must_respond_with :success
  end

  it 'admin create' do
    login_as admin
    assert_difference('Forum.count', 1) do
      post :create, forum: { name: 'Ruby vs. Javascript, who will win?' }
    end
    must_redirect_to forums_path
  end

  it 'admin fails create' do
    login_as admin
    assert_no_difference('Forum.count') do
      post :create, forum: { name: '' }
    end
    must_render_template :new
    flash[:alert].must_equal 'There was a problem!'
  end

  it 'admin show with pagination' do
    create_list(:topic, 20)
    login_as user
    get :show, id: forum.id
    must_respond_with :success
    # Should have 15 topics per page
    html = 'div#forums_show_page.col-md-13 table.table.table-striped tbody tr'
    css_select html, 15
  end

  it 'admin edit' do
    login_as admin
    get :edit, id: forum.id
    must_respond_with :success
  end

  it 'admin update' do
    login_as admin
    put :update, id: forum.id, forum: { name: 'Ruby vs. Python vs. Javascript deathmatch' }
    forum.reload
    forum.name.must_equal 'Ruby vs. Python vs. Javascript deathmatch'
  end

  it 'admin fails to update' do
    login_as admin
    put :update, id: forum.id, forum: { name: '' }
    forum.reload
    forum.name.must_equal forum.name
    flash[:alert].must_equal 'There was a problem saving!'
  end

  it 'admin destroy' do
    forum = create(:forum)
    login_as admin
    assert_difference('Forum.count', -1) do
      delete :destroy, id: forum.id
    end
    must_redirect_to forums_path
  end

  #------------------User Functionality----------------------
  it 'index' do
    login_as user
    get :index
    must_respond_with :success
  end

  it 'new' do
    login_as user
    get :new
    must_respond_with :unauthorized
  end

  it 'create fails for a regular user' do
    login_as user
    assert_no_difference('Forum.count') do
      post :create, forum: { name: 'Ruby vs. Javascript, who will win?' }
    end
    must_respond_with :unauthorized
  end

  it 'show with pagination' do
    create_list(:topic, 20)
    login_as user
    get :show, id: forum.id
    must_respond_with :success
    # Should have 15 topics per page
    html = 'div#forums_show_page.col-md-13 table.table.table-striped tbody tr'
    css_select html, 15
  end

  it 'edit' do
    login_as user
    get :edit, id: forum.id
    must_respond_with :unauthorized
  end

  it 'update' do
    login_as user
    put :update, id: forum.id, forum: { name: 'Ruby vs. Python vs. Javascript deathmatch' }
    forum.reload
    forum.name.must_equal forum.name
    must_respond_with :unauthorized
  end

  it 'destroy' do
    forum = create(:forum)
    login_as user
    assert_no_difference('Forum.count') do
      delete :destroy, id: forum.id
    end
    must_respond_with :unauthorized
  end
end
