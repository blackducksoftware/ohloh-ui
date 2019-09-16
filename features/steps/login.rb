# frozen_string_literal: true

class Spinach::Features::Login < Spinach::FeatureSteps
  step 'I am an OpenHub User' do
    @password = 'test_password'
    GithubVerification.any_instance.stubs(:generate_access_token)
    @account = FactoryBot.create(:account, password: @password)
  end

  step 'I visit the sign in page' do
    visit new_session_path
  end

  step 'enter my credentials' do
    fill_in 'Login or Email', with: @account.login
    fill_in 'Password', with: @password
    click_on 'Log In'
  end

  step 'it should sign me in' do
    current_path.must_equal account_path(:me)
  end

  step 'I have a spam OpenHub account' do
    @password = 'test_password'
    GithubVerification.any_instance.stubs(:generate_access_token)
    @account = FactoryBot.create(:account, password: @password)
    @account.access.spam!
  end

  step 'it should not sign me in' do
    current_path.must_equal sessions_path
  end

  step 'it should show me a disabled message' do
    page.must_have_content 'This account is disabled'
  end
end
