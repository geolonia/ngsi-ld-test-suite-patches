@entities
Feature: Test implementation of POST /entities (6.4.3.1) with different entity payloads
    TP/NGSI-LD/ContextInformation/Provision/Entities/CreateEntity/SuccessCases

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

Scenario Outline: Create some entities with different payloads
    Given path 'entities'
    And request __row
    And header Content-Type = 'application/ld+json'
    When method post
    Then status 201
    And match header Location == '/ngsi-ld/v1/entities/' + __row.id
Examples:
    | buildings |