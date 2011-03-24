Feature: permissions

  Scenario Outline: Access to pages
    Given I am logged in as an "<role>"
    When I goto "<page>"
    Then the response code should be <response>

  Examples:
      | role      | page            | response |
      | operator  | /log            | 200      |
      | operator  | /profile        | 200      |
      | operator  | /rejects        | 200      |
      | operator  | /snafus         | 200      |
      | operator  | /workspace      | 200      |
      | operator  | /stashspace     | 200      |
      | operator  | /admin/accounts | 200      |
      | operator  | /batches        | 200      |
      | operator  | /requests       | 200      |
      | affiliate | /log            | 403      |
      | affiliate | /profile        | 403      |
      | affiliate | /rejects        | 403      |
      | affiliate | /snafus         | 403      |
      | affiliate | /workspace      | 403      |
      | affiliate | /stashspace     | 403      |
      | affiliate | /admin          | 403      |
      | affiliate | /batches        | 403      |
      | affiliate | /requests       | 403      |

  Scenario: affiliate should not have access to batch form
    Given I am logged in as an "affiliate"
    When I goto "/packages"
    Then I should not see "Save as Batch"

  Scenario: operator should have access to batch form
    Given I am logged in as an "operator"
    When I goto "/packages"
    Then I should see "Save as Batch"

  Scenario: affiliate should not have access to request form
    Given I am logged in as an "affiliate"
    Given an archived package
    When I goto its package page
    Then I should not see "submit request"

  Scenario: operator should have access to request form
    Given I am logged in as an "operator"
    Given an archived package
    When I goto its package page
    Then I should see "submit request"

  Scenario: Access to aip details
    Given I am logged in as an "affiliate"
    Given an archived package
    When I goto its package page
    Then I should not see "copy url"
    Then I should not see "copy sha1"
    Then I should not see "copy md5"
    Then I should not see "aip descriptor"

  Scenario: filtering access
    Given I am logged in as an "affiliate"
    Given 1 package under account/project "ACT-FDA"
    Given 1 package under account/project "ACT-PRB"
    Given an account/project "FOO-BAR"
    Given I goto "/packages"
    When I press "Set Scope"
    Then I should have 2 package in the results

  Scenario: affiliate should not see anything batch related
    Given I am logged in as an "affiliate"
    Given an archived package
    When I goto "/packages"
    Then I should not see "batch"
    Then I should not see "Batch"

