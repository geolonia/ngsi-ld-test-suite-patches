@entities
Feature: Test implementation of POST /entities (6.4.3.1) with different entity payloads

Background:
  * url urlBase
  * def buildings = read('classpath:ngsi-ld/payloads/entities/buildings.json')

Scenario Outline: Create Buildings with different payloads
    Given path 'entities'
    And request __row
    And header Content-Type = 'application/ld+json'
    When method post
    Then status 201
Examples:
    | buildings |