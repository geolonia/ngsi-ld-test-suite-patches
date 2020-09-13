@entities
Feature: Test implementation of POST /entities (6.4.3.1) with invalid request

Background:
  * url urlBase
  * def building = read('classpath:ngsi-ld/payloads/entities/building.jsonld')
  * def buildingWithoutContext = read('classpath:ngsi-ld/payloads/entities/building-without-context.json')
  * configure charset = null

Scenario: Create Building with unsupported Media type
    Given path 'entities'
    And request building
    And header Content-Type = 'application/unkwnown'
    When method post
    Then status 415

Scenario: Create Building with wrong Media type (application/json with JSON-LD payload)
    Given path 'entities'
    And request building
    And header Content-Type = 'application/json'
    When method post
    Then status 400
    And match response.title == 'The request includes input data which does not meet the requirements of the operation'
    And match response.detail == '#notnull'

Scenario: Create Building with wrong Media type (application/ld+json with JSON-LD Link header)
    Given path 'entities'
    And request building
    And header Content-Type = 'application/ld+json'
    And header Link = '<https://fiware.github.io/data-models/context.jsonld>; rel=http://www.w3.org/ns/json-ld#context; type=application/ld+json'
    When method post
    Then status 400
    And match response.title == 'The request includes input data which does not meet the requirements of the operation'
    And match response.detail == '#notnull'

Scenario: Create Building with wrong Media type (application/ld+json without @context in the payload)
    Given path 'entities'
    And request buildingWithoutContext
    And header Content-Type = 'application/ld+json'
    When method post
    Then status 400
    And match response.title == 'The request includes input data which does not meet the requirements of the operation'
    And match response.detail == '#notnull'