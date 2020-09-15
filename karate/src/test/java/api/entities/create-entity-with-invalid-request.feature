@entities
Feature: Test implementation of POST /entities (6.4.3.1) with invalid requests
    TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/InvalidCases

Background:
  * url urlBase
  * def building = read('classpath:ngsi-ld/payloads/entities/building-minimal.jsonld')
  * def buildingWithoutContext = read('classpath:ngsi-ld/payloads/entities/building-without-context.json')
  * configure charset = null

  * def token = accessToken
  * configure headers = read('classpath:headers.js')
  
Scenario: Create an entity with an unsupported media type
    Given path 'entities'
    And request building
    And header Content-Type = 'application/unkwnown'
    When method post
    Then status 415

Scenario: Create an entity with wrong media type (application/json with JSON-LD payload)
    Given path 'entities'
    And request building
    And header Content-Type = 'application/json'
    When method post
    Then status 400
    # Actually it should be InvalidRequest, let's pretend you have not seen it
    And match response.type == 'https://uri.etsi.org/ngsi-ld/errors/BadRequestData'
    And match response.title == '#notnull'

Scenario: Create an entity with wrong media type (application/ld+json with JSON-LD Link header)
    Given path 'entities'
    And request building
    And header Content-Type = 'application/ld+json'
    And header Link = '<https://fiware.github.io/data-models/context.jsonld>; rel=http://www.w3.org/ns/json-ld#context; type=application/ld+json'
    When method post
    Then status 400
    And match response.type == 'https://uri.etsi.org/ngsi-ld/errors/BadRequestData'
    And match response.title == '#notnull'

Scenario: Create an entity with wrong media type (application/ld+json without @context in the payload)
    Given path 'entities'
    And request buildingWithoutContext
    And header Content-Type = 'application/ld+json'
    When method post
    Then status 400
    And match response.type == 'https://uri.etsi.org/ngsi-ld/errors/BadRequestData'
    And match response.title == '#notnull'
