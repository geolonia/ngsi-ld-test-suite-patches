@entities
Feature: Test implementation of POST /entities (6.4.3.1) with existing entity

Background:
  * url urlBase
  * def fixtures = callonce read('support/create-entity-fixture.feature')
  * def building = read('classpath:ngsi-ld/payloads/entities/building.jsonld')

Scenario:
    Given path 'entities'
    And request building
    And header Content-Type = 'application/ld+json'
    When method post
    Then status 409
