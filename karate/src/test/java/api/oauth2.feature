@ignore
Feature: Get an access token for an user and use it in subsequent requests

Background:
* url authServer

Scenario: Call the token endpoint to get an access token

* path 'token'
* form field grant_type = 'client_credentials'
* form field client_id = clientId
* form field client_secret = clientSecret
* method post
* status 200

* def accessToken = response.access_token

