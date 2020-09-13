@ignore
Feature: Generic feature to delete a given entity created as a fixture for a feature

  Background:
    * url urlBase

  Scenario:

    Given path 'entities/' + uri
    When method delete
    Then status 204
