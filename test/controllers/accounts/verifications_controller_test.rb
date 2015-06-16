require 'test_helper'

describe 'Accounts::VerificationsController' do
  describe 'new' do
    it 'must require user to be logged in' do
      get :new, account_id: create(:account).id

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must handle disabled account' do
      account = create(:disabled_account)
      login_as account

      get :new, account_id: account.id

      must_respond_with :not_found
    end

    it 'wont allow verifying other account' do
      login_as create(:account)
      get :new, account_id: create(:account).id

      must_respond_with :redirect
      must_redirect_to new_session_path
    end

    it 'must render the view successfully' do
      account = create(:account)
      login_as account

      get :new, account_id: account.id

      must_render_template :new
    end
  end

  describe 'create' do
    let(:account) { create(:account, twitter_id: nil) }
    before { login_as(account) }

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
  end
end
