# frozen_string_literal: true

require 'test_helper'

class KudosControllerTest < ActionController::TestCase
  let(:api_key) { create(:api_key) }
  let(:client_id) { api_key.oauth_application.uid }

  before do
    @kudo = create(:kudo)
    create(:kudo_with_name, sender: @kudo.account)
    sent1 = create(:kudo, sender: @kudo.account)
    create(:kudo, account: sent1.account, sender: @kudo.account)
    person = create(:person)
    create(:kudo, sender: @kudo.account, account: sent1.account, name: person.name, project: person.project)
    @request.env['HTTP_REFERER'] = '/'
  end

  # index action
  it 'index should not require a current user' do
    login_as nil
    get :index, params: { account_id: @kudo.account }
    assert_response :ok
  end

  it 'index should not offer way to rescind kudos to unlogged users' do
    login_as nil
    get :index, params: { account_id: @kudo.account }
    assert_select 'i.rescind-kudos', false
  end

  it 'index should offer way to rescind kudos to account' do
    login_as @kudo.account
    get :index, params: { account_id: @kudo.account }
    assert_select 'i.rescind-kudos', true
  end

  it 'index should offer way to rescind kudos to sender' do
    login_as @kudo.sender
    get :index, params: { account_id: @kudo.account }
    assert_select 'i.rescind-kudos', true
  end

  it 'index should offer way to give kudos to random user' do
    login_as create(:account)
    get :index, params: { account_id: @kudo.account }
    assert_select 'i.rescind-kudos', false
  end

  it 'index should render if the account lacks a person for some reason' do
    login_as nil
    account = create(:account)
    account.person.destroy!
    get :index, params: { account_id: account }
    assert_response :ok
  end

  it 'index should not respond to xml format without an api_key' do
    login_as nil
    get :index, params: { account_id: @kudo.account }, format: :xml
    assert_response :bad_request
  end

  it 'index should not respond to xml format with a banned api_key' do
    api_key.update!(status: ApiKey::STATUS_DISABLED)

    get :index, params: { account_id: @kudo.account, api_key: client_id }, format: :xml

    assert_response :bad_request
  end

  it 'index should not respond to xml format with an over-limit api_key' do
    api_key.update! daily_count: 999_999

    get :index, params: { account_id: @kudo.account, api_key: client_id }, format: :xml

    assert_response :unauthorized
  end

  it 'index should respond to xml format' do
    login_as nil
    get :index, params: { account_id: @kudo.account, api_key: client_id }, format: :xml
    assert_response :ok
  end

  # sent action
  it 'sent should not respond to xml format without an api_key' do
    login_as nil
    get :sent, params: { account_id: @kudo.account }, format: :xml
    assert_response :bad_request
  end

  it 'sent should not respond to xml format with a banned api_key' do
    login_as nil
    api_key.update!(status: ApiKey::STATUS_DISABLED)

    get :sent, params: { account_id: @kudo.account, api_key: client_id }, format: :xml
    assert_response :bad_request
  end

  it 'sent should not respond to xml format with an over-limit api_key' do
    login_as nil
    api_key.update! daily_count: 999_999

    get :sent, params: { account_id: @kudo.account, api_key: client_id }, format: :xml
    assert_response :unauthorized
  end

  it 'sent should respond to xml format' do
    login_as nil
    get :sent, params: { account_id: @kudo.account, api_key: client_id }, format: :xml
    assert_response :ok
  end

  # new action
  it 'new should require a current user' do
    login_as nil
    get :new, params: { account_id: create(:account).id }
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  it 'new should accept account_id' do
    login_as create(:account)
    get :new, params: { account_id: create(:account).id }
    assert_response :ok
  end

  it 'new should accept contribution_id' do
    login_as create(:account)
    get :new, params: { contribution_id: create(:person).id }
    assert_response :ok
  end

  # create action
  it 'create should require a current user' do
    login_as nil
    post :create, params: { kudo: { account_id: create(:account).id } }
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  it 'create should not allow user to kudo themselves' do
    account = create(:account)
    login_as account
    post :create, params: { kudo: { account_id: account.id } }
    assert_response :found
    _(flash[:error]).must_equal I18n.t('kudos.cant_kudo_self')
    _(Kudo.where(account_id: account.id).count).must_equal 0
  end

  it 'create should allow user to kudo someone else' do
    account = create(:account)
    login_as create(:account)
    post :create, params: { kudo: { account_id: account.id } }
    assert_response :found
    _(flash[:success]).must_equal I18n.t('kudos.create.success_account', name: account.name)
    _(Kudo.where(account_id: account.id).count).must_equal 1
  end

  it 'create should not allow a kudos with too much text' do
    account = create(:account)
    login_as create(:account)
    post :create, params: { kudo: { account_id: account.id, message: Faker::Lorem.sentences(number: 12) } }
    assert_response :found
    _(flash[:error]).must_equal 'Message is too long (maximum is 80 characters)'
    _(Kudo.where(account_id: account.id).count).must_equal 0
  end

  it 'create should allow user to kudo a contribution' do
    person = create(:person)
    login_as create(:account)
    post :create, params: { kudo: { contribution_id: person.id } }
    assert_response :found
    _(Kudo.where(project_id: person.project_id).count).must_equal 1
  end

  # destroy action
  it 'destroy should require a current user' do
    kudo = create(:kudo)
    login_as nil
    delete :destroy, params: { id: kudo.id }
    assert_response :redirect
    assert_redirected_to new_session_path
    _(Kudo.where(id: kudo.id).count).must_equal 1
  end

  it 'destroy should allow target to delete kudo' do
    kudo = create(:kudo)
    login_as kudo.account
    delete :destroy, params: { id: kudo.id }
    assert_response :found
    _(Kudo.where(id: kudo.id).count).must_equal 0
  end

  it 'destroy should allow sender to delete kudo' do
    kudo = create(:kudo)
    login_as kudo.sender
    delete :destroy, params: { id: kudo.id }
    assert_response :found
    _(Kudo.where(id: kudo.id).count).must_equal 0
  end

  it 'destroy should not allow random user to delete kudo' do
    kudo = create(:kudo)
    login_as create(:account)
    delete :destroy, params: { id: kudo.id }
    assert_response :found
    _(Kudo.where(id: kudo.id).count).must_equal 1
  end
end
