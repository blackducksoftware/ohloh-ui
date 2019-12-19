# frozen_string_literal: true

class Spinach::Features::PasswordReset < Spinach::FeatureSteps
  step 'I am on the sign in page' do
    visit new_session_path
  end

  step 'I click on forgot password link' do
    click_link 'Forgot Password'
  end

  step 'I should be on the password reset page' do
    current_path.must_equal new_password_path
  end

  step 'I have an Openhub account' do
    GithubVerification.any_instance.stubs(:generate_access_token)
    @account = FactoryBot.create(:account)
  end

  step 'I am on the password reset page' do
    visit new_password_path
  end

  step 'I enter my email' do
    fill_in 'Email address', with: @account.email
  end

  step 'submit the form' do
    click_on 'Reset password'
  end

  step 'it should send me a password reset email' do
    @account.reload

    delivery = ActionMailer::Base.deliveries.last
    delivery.to.first.must_equal @account.email
    delivery.html_part.body.raw_source.must_include(
      edit_user_password_path(@account, token: @account.confirmation_token)
    )
  end

  step 'I have raised a password reset request' do
    @account.update!(confirmation_token: Clearance::Token.new)
  end

  step 'I follow the email link to reset my password' do
    visit edit_user_password_path(@account, token: @account.confirmation_token)
  end

  step 'I submit my new password' do
    @new_password = Faker::Internet.password
    fill_in 'Choose password', with: @new_password
    click_on 'Save this password'
  end

  step 'it should reset my password' do
    @account.reload
    @account.authenticated?(@new_password).must_equal true
  end

  step 'it should sign me in' do
    current_path.must_equal account_path(:me)
  end

  step 'double click submit button' do
    ActionMailer::Base.deliveries = []
    element = find_button('Reset password')
    page.driver.browser.action.double_click(element.native).perform
  end

  step 'it should send only one password reset email' do
    ActionMailer::Base.deliveries.length.must_equal 1
  end
end
