require 'test_helper'

describe 'Accounts::VerificationsController' do
  describe 'new' do
    it 'must require user to be logged in' do
      account = create(:account)
      account.update!(twitter_id: nil)
      get :new, account_id: account.id

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must redirect to root_path if account is verified' do
      account = create(:account)
      login_as account

      get :new, account_id: account.id

      must_redirect_to root_path
    end

    it 'must handle disabled account' do
      account = create(:disabled_account)
      login_as account

      get :new, account_id: account.id

      must_respond_with :not_found
    end

    it 'wont allow verifying other account' do
      login_as create(:account)
      account = create(:account)
      account.update!(twitter_id: nil)
      get :new, account_id: account.id

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must render the view successfully' do
      account = create(:account)
      account.update!(twitter_id: nil)
      login_as account

      get :new, account_id: account.id

      must_render_template :new
    end
  end

  describe 'create' do
    let(:account) { create(:account) }
    before do
      account.update!(twitter_id: nil)
      login_as(account)
    end

    it 'must update account with non null twitter_id' do
      service_provider_url = Faker::Internet.url
      credentials = "oauth_consumer_key=#{ Faker::Internet.password }"
      twitter_id = Faker::Internet.password

      TwitterDigits.expects(:get_twitter_id).with(service_provider_url, credentials)
        .returns(twitter_id)

      post :create, account_id: account.id,
                    verification: { service_provider_url: service_provider_url, credentials: credentials }

      account.reload.twitter_id.must_equal twitter_id
    end

    it 'wont report an error when twitter_id is null' do
      TwitterDigits.stubs(:get_twitter_id)

      post :create, account_id: account.id, verification: {}

      flash[:error].must_be :present?
      must_render_template :new
    end

    it 'wont allow verifying a new account with an used twitter_id' do
      verified_account = create(:account)
      unverified_account = create(:account)
      unverified_account.update!(twitter_id: nil)
      login_as unverified_account

      TwitterDigits.stubs(:get_twitter_id).returns(verified_account.twitter_id)

      post :create, account_id: unverified_account.id, verification: {}

      unverified_account.reload.twitter_id.must_be_nil
      flash[:error].must_equal i18n_activerecord(:account, :twitter_id)[:taken]
      must_render_template :new
    end
  end
end
