# frozen_string_literal: true

require 'test_helper'

class ApiKeysControllerTest < ActionController::TestCase
  before do
    @admin = create(:admin, name: 'xyzzy-admin')
    @user = create(:account, name: 'user_api_keys_test')
  end

  it 'admins should be able to look at the api keys of someone else' do
    login_as @admin
    get :index, params: { account_id: @user.id }
    assert_response :ok
  end

  it 'unlogged in users should not be able to look at the api keys of a user' do
    login_as nil
    get :index, params: { account_id: @user.id }
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  it 'normal users should be able to look at their own api keys' do
    login_as @user
    get :index, params: { account_id: @user.id }
    assert_response :ok
  end

  it 'normal users should not be able to look at someone elses api keys' do
    login_as @user
    get :index, params: { account_id: @admin.id }
    assert_response :unauthorized
  end

  it 'normal users should see their api keys, but not others' do
    api_key1 = create(:api_key, account_id: @user.id)
    api_key2 = create(:api_key, account_id: @admin.id)
    login_as @user
    get :index, params: { account_id: @user.id }
    assert_response :ok
    _(response.body).must_match(api_key1.oauth_application.name)
    _(response.body).wont_match(api_key2.oauth_application.name)
  end

  # new action
  it 'new should let admins edit daily limit' do
    login_as @admin
    get :new, params: { account_id: @admin.id }
    assert_response :ok
    _(response.body).must_match('api_key_daily_limit')
  end

  it 'new should not let users edit daily limit' do
    login_as @user
    get :new, params: { account_id: @user.id }
    assert_response :ok
    _(response.body).wont_match('api_key_daily_limit')
  end

  it 'new should not let users who have enough keys make more' do
    (1..ApiKey::KEY_LIMIT_PER_ACCOUNT).each { |i| create(:api_key, account_id: @user.id, key: "max_keys_test_#{i}") }
    login_as @user
    get :new, params: { account_id: @user.id }
    assert_response 302
  end

  it 'new should understand the me user for logged users' do
    login_as @user
    get :new, params: { account_id: 'me' }
    assert_response :ok
    _(response.body).must_match 'foo'
  end

  it 'new should understand the me user' do
    get :new, params: { account_id: 'me' }
    assert_redirected_to new_session_path
  end

  # create action
  it 'create with valid parameters should create an api key' do
    login_as @user
    post :create, params: { account_id: @user.id, api_key: { name: 'Name',
                                                             description: 'It was the best of times.',
                                                             terms: '1' } }
    assert_response :found
    _(ApiKey.where(account_id: @user.id, description: 'It was the best of times.').first).must_be :present?
  end

  it 'create requires accepting the terms of service' do
    login_as @user
    post :create, params: { account_id: @user.id, api_key: { name: 'Name',
                                                             description: 'I do not accept those terms!',
                                                             terms: '0' } }
    assert_response :bad_request
    _(response.body).must_match(I18n.t(:must_accept_terms))
    _(ApiKey.where(account_id: @user.id, description: 'I do not accept those terms!').first).wont_be :present?
  end

  # edit action
  it 'edit should populate the form' do
    api_key = create(:api_key, account_id: @user.id, description: 'A pre-existing API Key.')
    login_as @user
    get :edit, params: { account_id: @user.id, id: api_key.id }
    assert_response :ok
    _(response.body).must_match('A pre-existing API Key.')
  end

  it 'edit should 404 attempting to edit a non-existant api key' do
    login_as @user
    get :edit, params: { account_id: @user.id, id: 9876 }
    assert_response :not_found
  end

  # update action
  it 'update should populate the form' do
    api_key = create(:api_key, account_id: @user.id, description: 'My old crufty API Key.')
    login_as @user
    put :update, params: { account_id: @user.id, id: api_key.id, api_key: { name: 'Name',
                                                                            description: 'Repolished key!',
                                                                            terms: '1' } }
    assert_response 302
    api_key.reload
    _(api_key.description).must_equal 'Repolished key!'
  end

  it 'update does not allow unaccepting the terms' do
    api_key = create(:api_key, account_id: @user.id, description: 'My previous API Key.')
    login_as @user
    put :update, params: { account_id: @user.id, id: api_key.id, api_key: { name: 'Name',
                                                                            description: 'I cleverly unaccept now!',
                                                                            terms: '0' } }
    assert_response :bad_request
    api_key.reload
    _(api_key.description).must_equal 'My previous API Key.'
  end

  # destroy action
  it 'destroy should remove the api key from the db' do
    api_key = create(:api_key, account_id: @user.id, description: 'My doomed key.')
    login_as @user
    delete :destroy, params: { account_id: @user.id, id: api_key.id }
    assert_response 302
    _(ApiKey.where(account_id: @user.id, description: 'My doomed key.').first).wont_be :present?
  end

  # destroy action
  it 'destroy gracefully handle error cconditions' do
    api_key = create(:api_key, account_id: @user.id, description: 'My safe key.')
    ApiKey.any_instance.stubs(:destroy).returns(false)
    login_as @user
    delete :destroy, params: { account_id: @user.id, id: api_key.id }
    assert_response 302
    _(ApiKey.where(account_id: @user.id, description: 'My safe key.').first).must_be :present?
  end
end
