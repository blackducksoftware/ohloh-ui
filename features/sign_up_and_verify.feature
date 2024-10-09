Feature: Sign up and verify
  In order to use OpenHub
  As a new user
  I must be able to sign up using Github/Email

  @javascript
  Scenario: Signup for OpenHub using email
    Given I am on the OpenHub sign up page
    When I select Email
    Then I should see a form to enter my email
