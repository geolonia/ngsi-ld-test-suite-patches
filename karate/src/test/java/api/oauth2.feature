@ignore
Feature: Get an access token for an user and use it in subsequent requests

Background:
* url authServer

Scenario: Call the token endpoint to get an access token

* path 'token'
* form field grant_type = 'password'
* form field client_id = clientId
* form field client_secret = clientSecret
* form field username = username
* form field password = password
* method post
* status 200

* def accessToken = response.access_token

