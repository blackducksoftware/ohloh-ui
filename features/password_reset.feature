Feature: Password Reset
  In order to reset my password
  As an Openhub User
  I must be able to use the password reset functionality

  Scenario: Visiting the password reset page
    Given I am on the sign in page
    When I click on forgot password link
    Then I should be on the password reset page

  Scenario: Requesting a password reset
    Given I have an Openhub account
    And I am on the password reset page
    When I enter my email
    And submit the form
    Then it should send me a password reset email

  Scenario: Resetting my password through the email link
    Given I have an Openhub account
    And I have raised a password reset request
    When I follow the email link to reset my password
    And I submit my new password
    Then it should reset my password
    And it should sign me in
