# frozen_string_literal: true

class Spinach::Features::SignUpAndVerify < Spinach::FeatureSteps
  step 'I am on the OpenHub sign up page' do
    visit new_account_path
    page.must_have_content 'Github'
    page.must_have_content 'Email'
    page.must_have_selector(:css, 'a#email-sign-up')
  end

  step 'I select Email' do
    click_on 'Email'
  end

  step 'I should see a form to enter my email address' do
    sleep 1
    page.must_have_content 'Email Address'
  end
end
