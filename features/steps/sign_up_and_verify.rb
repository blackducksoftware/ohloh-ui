class Spinach::Features::SignUpAndVerify < Spinach::FeatureSteps
  step 'I am on the OpenHub sign up page' do
    visit new_registration_path
  end

  step 'I submit my sign up details' do
    @email = Faker::Internet.email
    password = Faker::Internet.password
    fill_in 'login', with: Faker::Name.first_name.downcase
    fill_in 'email', with: @email
    fill_in 'email_confirmation', with: @email
    fill_in 'password', with: password
    fill_in 'password_confirmation', with: password
    click_on 'Sign Up'
  end

  step 'I see a verifications page' do
    current_path.must_equal new_authentication_path
  end

  step 'I click on Verify Phone Number' do
    click_on 'Verify Phone Number'
  end

  step 'I should see a form to enter my phone number' do
    page.must_have_content 'Enter your phone number'
  end

  step 'I click on Verify using Github' do
    click_on 'Verify using Github'
  end

  step 'I should see a form to enter my Github credentials' do
    page.must_have_content 'Sign in to GitHub'
  end
end
