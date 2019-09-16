# frozen_string_literal: true

class Spinach::Features::SignUpAndVerify < Spinach::FeatureSteps
  step 'I am on the OpenHub sign up page' do
    visit new_account_path
    page.must_have_content 'Github'
    page.must_have_content 'Phone & Email'
    page.must_have_selector(:css, 'a#digits-sign-up')
  end

  step 'I select Phone & Email' do
    click_on 'Phone & Email'
  end

  step 'I should see a form to enter my phone number' do
    sleep 1
    page.must_have_content 'Enter your phone number'
  end
end
