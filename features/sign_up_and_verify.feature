Feature: Sign up and verify
  In order to use OpenHub
  As a new user
  I must be able to initiate verification after sign up

  @javascript
  Scenario: Verify for OpenHub using Fabric
    Given I am on the OpenHub sign up page
    And I submit my sign up details
    And I see a verifications page
    When I click on Verify Phone Number
    Then I should see a form to enter my phone number

  @javascript
  Scenario: Verify for OpenHub using Github
    Given I am on the OpenHub sign up page
    And I submit my sign up details
    And I see a verifications page
    When I click on Verify using Github
    Then I should see a form to enter my Github credentials
