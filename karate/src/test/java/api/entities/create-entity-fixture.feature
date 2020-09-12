@ignore
Feature: Generic feature to create an entity to be used as a fixture for a feature

Background:
  * url urlBase
  * def building = read('../../../../../../samples/building.jsonld')

Scenario:
    Given path 'entities'
    And request building
    And header Content-Type = 'application/ld+json'
    When method post
    Then status 201
