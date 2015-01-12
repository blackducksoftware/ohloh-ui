require 'test_helper'

class ApiKeysControllerTest < ActionController::TestCase
  # index action
  it 'admins should be able to look at the global list of api keys' do
    login_as accounts(:admin)
    get :index
    must_respond_with :ok
  end

  it 'unlogged in users should not be able to look at the global list of api keys' do
    login_as nil
    get :index
    must_respond_with :unauthorized
  end

  it 'normal users should not be able to look at the global list of api keys' do
    login_as accounts(:user)
    get :index
    must_respond_with :unauthorized
  end

  it 'index page should find models whose name match the "q" parameter' do
    api_key1 = create(:api_key, name: 'foobar')
    api_key2 = create(:api_key, name: 'goobaz')
    login_as accounts(:admin)
    get :index, q: 'foobar'
    must_respond_with :ok
    response.body.must_match(api_key1.name)
    response.body.wont_match(api_key2.name)
  end

  it 'index page should find models whose description match the "q" parameter' do
    api_key1 = create(:api_key, description: 'foobar')
    api_key2 = create(:api_key, description: 'goobaz')
    login_as accounts(:admin)
    get :index, q: 'foobar'
    must_respond_with :ok
    response.body.must_match(api_key1.name)
    response.body.wont_match(api_key2.name)
  end

  it 'index page should find models whose key match the "q" parameter' do
    api_key1 = create(:api_key, key: 'foobar')
    api_key2 = create(:api_key, key: 'goobaz')
    login_as accounts(:admin)
    get :index, q: 'foobar'
    must_respond_with :ok
    response.body.must_match(api_key1.name)
    response.body.wont_match(api_key2.name)
  end

  it 'index page should find models whose account name match the "q" parameter' do
    api_key1 = create(:api_key, account_id: accounts(:user).id)
    api_key2 = create(:api_key, account_id: accounts(:admin).id)
    login_as accounts(:admin)
    get :index, q: 'user'
    must_respond_with :ok
    response.body.must_match(api_key1.name)
    response.body.wont_match(api_key2.name)
  end

  it 'index page should accept "query" in place of "q" as a parameter' do
    api_key1 = create(:api_key, name: 'foobar')
    api_key2 = create(:api_key, name: 'goobaz')
    login_as accounts(:admin)
    get :index, query: 'foobar'
    must_respond_with :ok
    response.body.must_match(api_key1.name)
    response.body.wont_match(api_key2.name)
  end

  it 'index page should honor the sort order "most_recent_request"' do
    api_key1 = create(:api_key, last_access_at: Time.now)
    api_key2 = create(:api_key, last_access_at: Time.now - 1.day)
    api_key3 = create(:api_key, last_access_at: Time.now + 1.day)
    login_as accounts(:admin)
    get :index, sort: 'most_recent_request'
    must_respond_with :ok
    response.body.must_match(/#{api_key3.name}.*#{api_key1.name}.*#{api_key2.name}/m)
  end

  it 'index page should honor the sort order "most_requests_today"' do
    api_key1 = create(:api_key, daily_count: 11)
    api_key2 = create(:api_key, daily_count: 10)
    api_key3 = create(:api_key, daily_count: 12)
    login_as accounts(:admin)
    get :index, sort: 'most_requests_today'
    must_respond_with :ok
    response.body.must_match(/#{api_key3.name}.*#{api_key1.name}.*#{api_key2.name}/m)
  end

  it 'index page should honor the sort order "most_requests"' do
    api_key1 = create(:api_key, total_count: 11)
    api_key2 = create(:api_key, total_count: 10)
    api_key3 = create(:api_key, total_count: 12)
    login_as accounts(:admin)
    get :index, sort: 'most_requests'
    must_respond_with :ok
    response.body.must_match(/#{api_key3.name}.*#{api_key1.name}.*#{api_key2.name}/m)
  end

  it 'index page should honor the sort order "newest"' do
    api_key1 = create(:api_key, created_at: Time.now)
    api_key2 = create(:api_key, created_at: Time.now - 1.day)
    api_key3 = create(:api_key, created_at: Time.now + 1.day)
    login_as accounts(:admin)
    get :index, sort: 'newest'
    must_respond_with :ok
    response.body.must_match(/#{api_key3.name}.*#{api_key1.name}.*#{api_key2.name}/m)
  end

  it 'index page should honor the sort order "oldest"' do
    api_key1 = create(:api_key, created_at: Time.now)
    api_key2 = create(:api_key, created_at: Time.now - 1.day)
    api_key3 = create(:api_key, created_at: Time.now + 1.day)
    login_as accounts(:admin)
    get :index, sort: 'oldest'
    must_respond_with :ok
    response.body.must_match(/#{api_key2.name}.*#{api_key1.name}.*#{api_key3.name}/m)
  end

  it 'index page should honor the sort order "account_name"' do
    api_key1 = create(:api_key, account_id: accounts(:user).id)
    api_key2 = create(:api_key, account_id: accounts(:admin).id)
    login_as accounts(:admin)
    get :index, sort: 'account_name'
    must_respond_with :ok
    response.body.must_match(/#{api_key2.name}.*#{api_key1.name}/m)
  end

  it 'index page should assume "newest" when the sort parameter is unsupported' do
    api_key1 = create(:api_key, created_at: Time.now)
    api_key2 = create(:api_key, created_at: Time.now - 1.day)
    api_key3 = create(:api_key, created_at: Time.now + 1.day)
    login_as accounts(:admin)
    get :index, sort: 'I_am_a_banana!'
    must_respond_with :ok
    response.body.must_match(/#{api_key3.name}.*#{api_key1.name}.*#{api_key2.name}/m)
  end

  it 'admins should be able to look at the api keys of someone else' do
    login_as accounts(:admin)
    get :index, account_id: accounts(:user).id
    must_respond_with :ok
  end

  it 'unlogged in users should not be able to look at the api keys of a user' do
    login_as nil
    get :index, account_id: accounts(:user).id
    must_respond_with :unauthorized
  end

  it 'normal users should be able to look at their own api keys' do
    login_as accounts(:user)
    get :index, account_id: accounts(:user).id
    must_respond_with :ok
  end

  it 'normal users should not be able to look at someone elses api keys' do
    login_as accounts(:user)
    get :index, account_id: accounts(:admin).id
    must_respond_with :unauthorized
  end

  it 'normal users should see their api keys, but not others' do
    api_key1 = create(:api_key, account_id: accounts(:user).id)
    api_key2 = create(:api_key, account_id: accounts(:admin).id)
    login_as accounts(:user)
    get :index, account_id: accounts(:user).id
    must_respond_with :ok
    response.body.must_match(api_key1.name)
    response.body.wont_match(api_key2.name)
  end

  it 'admins should be able to download a csv of the global list of api keys' do
    api_key1 = create(:api_key, account_id: accounts(:user).id)
    api_key2 = create(:api_key, account_id: accounts(:admin).id)
    login_as accounts(:admin)
    get :index, format: :csv
    must_respond_with :ok
    response.body.must_match('Open Hub account,Application Name')
    response.body.must_match(api_key1.name)
    response.body.must_match(api_key2.name)
    response.headers['Content-Type'].must_include('text/csv')
    response.headers['Content-Type'].must_include('text/csv')
    response.headers['Content-Disposition'].must_include('attachment')
    response.headers['Content-Disposition'].must_include('api_keys_report.csv')
  end

  # new action
  it 'new should let admins edit daily limit' do
    login_as accounts(:admin)
    get :new, account_id: accounts(:admin).id
    must_respond_with :ok
    response.body.must_match('api_key_daily_limit')
  end

  it 'new should not let users edit daily limit' do
    login_as accounts(:user)
    get :new, account_id: accounts(:user).id
    must_respond_with :ok
    response.body.wont_match('api_key_daily_limit')
  end

  it 'new should not let users who have enough keys make more' do
    (1..ApiKey::KEY_LIMIT_PER_ACCOUNT).each { create(:api_key, account_id: accounts(:user).id) }
    login_as accounts(:user)
    get :new, account_id: accounts(:user).id
    must_respond_with 302
  end

  # create action
  it 'create with valid parameters should create an api key' do
    login_as accounts(:user)
    post :create, account_id: accounts(:user).id, api_key: { name: 'Name',
                                                             description: 'It was the best of times.',
                                                             terms: '1' }
    must_respond_with :found
    ApiKey.where(account_id: accounts(:user).id, description: 'It was the best of times.').first.must_be :present?
  end

  it 'create requires accepting the terms of service' do
    login_as accounts(:user)
    post :create, account_id: accounts(:user).id, api_key: { name: 'Name',
                                                             description: 'I do not accept those terms!',
                                                             terms: '0' }
    must_respond_with :bad_request
    response.body.must_match(I18n.t(:must_accept_terms))
    ApiKey.where(account_id: accounts(:user).id, description: 'I do not accept those terms!').first.wont_be :present?
  end

  # edit action
  it 'edit should populate the form' do
    api_key = create(:api_key, account_id: accounts(:user).id, description: 'A pre-existing API Key.')
    login_as accounts(:user)
    get :edit, account_id: accounts(:user).id, id: api_key.id
    must_respond_with :ok
    response.body.must_match('A pre-existing API Key.')
  end

  it 'edit should 404 attempting to edit a non-existant api key' do
    login_as accounts(:user)
    get :edit, account_id: accounts(:user).id, id: 9876
    must_respond_with :not_found
  end

  # update action
  it 'update should populate the form' do
    api_key = create(:api_key, account_id: accounts(:user).id, description: 'My old crufty API Key.')
    login_as accounts(:user)
    put :update, account_id: accounts(:user).id, id: api_key.id, api_key: { name: 'Name',
                                                                            description: 'Repolished key!',
                                                                            terms: '1' }
    must_respond_with 302
    api_key.reload
    api_key.description.must_equal 'Repolished key!'
  end

  it 'update does not allow unaccepting the terms' do
    api_key = create(:api_key, account_id: accounts(:user).id, description: 'My previous API Key.')
    login_as accounts(:user)
    put :update, account_id: accounts(:user).id, id: api_key.id, api_key: { name: 'Name',
                                                                            description: 'I cleverly unaccept now!',
                                                                            terms: '0' }
    must_respond_with :bad_request
    api_key.reload
    api_key.description.must_equal 'My previous API Key.'
  end

  # destroy action
  it 'destroy should remove the api key from the db' do
    api_key = create(:api_key, account_id: accounts(:user).id, description: 'My doomed key.')
    login_as accounts(:user)
    delete :destroy, account_id: accounts(:user).id, id: api_key.id
    must_respond_with 302
    ApiKey.where(account_id: accounts(:user).id, description: 'My doomed key.').first.wont_be :present?
  end
end
