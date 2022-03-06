# frozen_string_literal: true

require 'test_helper'
class RssSubscriptionsControllerTest < ActionController::TestCase
  before do
    @project = create(:project)
    @account = create(:admin)
    login_as @account
  end

  it 'must render the page correctly when no rss_subscriptions' do
    get :index, params: { project_id: @project.to_param }

    assert_response :ok
  end

  it 'must render projects/deleted when project is deleted' do
    @project.update!(deleted: true, editor_account: @account)

    get :index, params: { project_id: @project.to_param }

    assert_template 'deleted'
  end

  it 'must render the page correctly when rss_subscriptions are present' do
    rss_subscription1 = create(:rss_subscription, project: @project)
    rss_feed = create(:rss_feed, last_fetch: Time.current)
    rss_subscription2 = create(:rss_subscription, project: @project, rss_feed: rss_feed)

    get :index, params: { project_id: @project.to_param }

    _(assigns(:rss_subscriptions)).must_equal [rss_subscription1, rss_subscription2]
    assert_response :ok
  end

  it 'should render the new form' do
    get :new, params: { project_id: @project.to_param }
    assert_response :ok
  end

  it 'should create a new rss subscription' do
    post :create, params: { project_id: @project.to_param, rss_feed: { url: 'http://yahoo.com' } }
    assert_response :redirect
    assert_redirected_to project_rss_subscriptions_path(@project)
  end

  it 'should gracefully handle locked projects' do
    Project.any_instance.stubs(:edit_authorized?).returns false
    post :create, params: { project_id: @project.to_param, rss_feed: { url: 'http://yahoo.com' } }
    assert_response :redirect
    assert_redirected_to project_path(@project)
    _(flash.notice).must_equal I18n.t(:not_authorized)
  end

  it 'should recreate a previously deleted rss_subscription if available' do
    rss_feed = create(:rss_feed, url: 'http://yahoo.com')
    rss_subscription = create(:rss_subscription, project: @project, rss_feed: rss_feed)
    rss_subscription.create_edit.undo!(@account)
    post :create, params: { project_id: @project.to_param, rss_feed: { url: 'http://yahoo.com' } }
    assert_response :redirect
    assert_redirected_to project_rss_subscriptions_path(@project)
    _(rss_subscription.reload.deleted).must_equal false
  end

  it 'should not create a new rss subscription with invalid param' do
    post :create, params: { project_id: @project.to_param, rss_feed: { url: 'junk' } }
    assert_template 'rss_subscriptions/new'
  end

  it 'should not create a new rss subscription with blank url' do
    post :create, params: { project_id: @project.to_param, rss_feed: { url: '' } }
    assert_template 'rss_subscriptions/new'
    _(response.body).must_match I18n.t('accounts.invalid_url_format')
  end

  it 'should destroy a rss subscription' do
    rss_subscription = create(:rss_subscription, project: @project)
    login_as rss_subscription.editor_account
    delete :destroy, params: { project_id: @project.to_param, id: rss_subscription.id }
    assert_response :redirect
    assert_redirected_to project_rss_subscriptions_path(@project)
  end
end
