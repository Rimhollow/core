Feature: submission command line interface
  In order to submit a sip for ingest
  As an operator
  I want to be able to submit via the command line

  Scenario: normal submission
    Given a good sip
    When I submit
    Then it should print "successfully submitted"
    And it should return status 0
  
  Scenario: bad environment
    Given a bogus DAITSS_WORKSPACE
    When I submit
    Then it should print "DAITSS_WORKSPACE must be set"
    And it should return status 1

  Scenario: no sip specified
    Given no sip as an argument
    When I submit
    Then it should print "sip is required"
    And it should return status 2

  Scenario: any other problem
    Given a systemic problem
    And a good sip
    When I submit
    Then it should print an error message
    And it should print a backtrace
    And it should return status 3
