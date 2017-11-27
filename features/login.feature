Feature: Login
  In order to sign into Openhub
  As an OpenHub user
  I must be allowed access based on my account level

  Scenario: Sign in normal account
    Given I am an OpenHub User
    When I visit the sign in page
    And enter my credentials
    Then it should sign me in

  Scenario: Prevent spam account sign in
    Given I have a spam OpenHub account
    When I visit the sign in page
    And enter my credentials
    Then it should not sign me in
    And it should show me a disabled message
