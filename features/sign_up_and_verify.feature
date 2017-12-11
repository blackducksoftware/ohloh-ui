Feature: Sign up and verify
  In order to use OpenHub
  As a new user
  I must be able to sign up using Github/Phone

  @javascript
  Scenario: Signup for OpenHub using phone number
    Given I am on the OpenHub sign up page
    When I select Phone & Email
    Then I should see a form to enter my phone number
