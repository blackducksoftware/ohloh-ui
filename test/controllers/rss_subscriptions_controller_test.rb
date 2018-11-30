require 'test_helper'
describe 'RssSubscriptionsController' do
  before do
    @project = create(:project)
    @account = create(:admin)
    login_as @account
  end

  it 'must render the page correctly when no rss_subscriptions' do
    get :index, project_id: @project.to_param

    must_respond_with :ok
  end

  it 'must render projects/deleted when project is deleted' do
    @project.update!(deleted: true, editor_account: @account)

    get :index, project_id: @project.to_param

    must_render_template 'deleted'
  end

  it 'must render the page correctly when rss_subscriptions are present' do
    rss_subscription1 = create(:rss_subscription, project: @project)
    rss_feed = create(:rss_feed, last_fetch: Time.current)
    rss_subscription2 = create(:rss_subscription, project: @project, rss_feed: rss_feed)

    get :index, project_id: @project.to_param

    assigns(:rss_subscriptions).must_equal [rss_subscription1, rss_subscription2]
    must_respond_with :ok
  end

  it 'should render the new form' do
    get :new, project_id: @project.to_param
    must_respond_with :ok
  end

  it 'should create a new rss subscription' do
    post :create, project_id: @project.to_param, rss_feed: { url: 'http://yahoo.com' }
    must_respond_with :redirect
    must_redirect_to project_rss_subscriptions_path(@project)
  end

  it 'should gracefully handle locked projects' do
    Project.any_instance.stubs(:edit_authorized?).returns false
    post :create, project_id: @project.to_param, rss_feed: { url: 'http://yahoo.com' }
    must_respond_with :redirect
    must_redirect_to project_path(@project)
    flash.notice.must_equal I18n.t(:not_authorized)
  end

  it 'should recreate a previously deleted rss_subscription if available' do
    rss_feed = create(:rss_feed, url: 'http://yahoo.com')
    rss_subscription = create(:rss_subscription, project: @project, rss_feed: rss_feed)
    rss_subscription.create_edit.undo!(@account)
    post :create, project_id: @project.to_param, rss_feed: { url: 'http://yahoo.com' }
    must_respond_with :redirect
    must_redirect_to project_rss_subscriptions_path(@project)
    rss_subscription.reload.deleted.must_equal false
  end

  it 'should not create a new rss subscription with invalid param' do
    post :create, project_id: @project.to_param, rss_feed: { url: 'junk' }
    must_render_template 'rss_subscriptions/new'
  end

  it 'should not create a new rss subscription with blank url' do
    post :create, project_id: @project.to_param, rss_feed: { url: '' }
    must_render_template 'rss_subscriptions/new'
    response.body.must_match I18n.t('accounts.invalid_url_format')
  end

  it 'should destroy a rss subscription' do
    rss_subscription = create(:rss_subscription, project: @project)
    login_as rss_subscription.editor_account
    delete :destroy, project_id: @project.to_param, id: rss_subscription.id
    must_respond_with :redirect
    must_redirect_to project_rss_subscriptions_path(@project)
  end
end
