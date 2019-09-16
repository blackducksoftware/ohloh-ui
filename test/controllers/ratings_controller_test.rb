# frozen_string_literal: true

require 'test_helper'

class RatingsControllerTest < ActionController::TestCase
  before do
    @account = create(:account)
    @project = create(:project)
  end

  it 'does not allow rating a project by unlogged users' do
    login_as nil
    post :rate, id: @project.to_param, score: '5'
    must_respond_with :redirect
    must_redirect_to new_session_path
  end

  it 'allows rating a project with logged in users' do
    login_as @account
    post :rate, id: @project.to_param, score: '5', show: 'projects/show/community_rating'
    must_respond_with :ok
  end

  it 'must render projects/deleted when project is deleted' do
    login_as @account
    @project.update!(deleted: true, editor_account: @account)

    post :rate, id: @project.to_param, score: '5', show: 'projects/show/community_rating'

    must_render_template 'deleted'
  end

  it 'does not allow rating a project to silly values' do
    rating_score = @project.ratings
    login_as @account
    post :rate, id: @project.to_param, score: 'silly', show: 'projects/show/community_rating'
    must_respond_with :ok
    @project.ratings.must_equal rating_score
  end

  it 'gracefully handles rating of non-existant projects' do
    login_as @account
    post :rate, id: 'I_am_a_banana', score: '5'
    must_respond_with :not_found
  end

  it 'allows changing a rating on a project' do
    rating = create(:rating, account: @account, project: @project, score: '3')
    login_as @account
    post :rate, id: @project.to_param, score: '5', show: 'projects/show/community_rating'
    must_respond_with :ok
    @project.reload
    @project.ratings.map(&:id).must_equal [rating.id]
    @project.ratings.map(&:score).must_equal [5]
    @project.rating_average.must_equal 5.0
  end

  it 'does not allow unrating a project by unlogged users' do
    login_as nil
    post :unrate, id: @project.to_param
    must_respond_with :redirect
    must_redirect_to new_session_path
  end

  it 'allows unrating a project with logged in users even if they never rated it' do
    login_as @account
    post :unrate, id: @project.to_param, show: 'projects/show/community_rating'
    must_respond_with :ok
  end

  it 'gracefully handles unrating of non-existant projects' do
    login_as @account
    post :unrate, id: 'I_am_a_banana'
    must_respond_with :not_found
  end

  it 'allows unrating a project' do
    create(:rating, account: @account, project: @project, score: '3')
    login_as @account
    post :unrate, id: @project.to_param, show: 'projects/show/community_rating'
    must_respond_with :ok
    @project.ratings.must_equal []
  end

  it 'must raise an exception when partial is not allowed' do
    create(:rating, account: @account, project: @project, score: '3')
    login_as @account
    -> { post :unrate, id: @project.to_param, show: 'undefined' }.must_raise(StandardError)
  end
end
