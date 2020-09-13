@entities
Feature: Test implementation of POST /entities (6.4.3.1) with different entity payloads

Background:
  * url urlBase
  * def buildings = read('classpath:ngsi-ld/payloads/entities/buildings.json')

  * def token = accessToken
  * configure headers = read('classpath:headers.js')
  
  * configure afterFeature =
    """
    function() {
      karate.call('./support/delete-fixture-entity.feature', { uri: 'urn:ngsi-ld:Building:EGM-Office-01' });
      karate.call('./support/delete-fixture-entity.feature', { uri: 'urn:ngsi-ld:Building:EGM-Office-02' });
      karate.call('./support/delete-fixture-entity.feature', { uri: 'urn:ngsi-ld:Building:EGM-Office-04' });
    }
    """

Scenario Outline: Create Buildings with different payloads
    Given path 'entities'
    And request __row
    And header Content-Type = 'application/ld+json'
    When method post
    Then status 201
Examples:
    | buildings |