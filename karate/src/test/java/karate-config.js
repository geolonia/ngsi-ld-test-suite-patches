function fn() {
  var env = karate.env; // get java system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev'; // a custom 'intelligent' default
  }

  var config = { // base config JSON
    urlBase: karate.properties['datahub.urlBase'],
    authServer: karate.properties['datahub.authServer'],
    clientId: karate.properties['datahub.clientId'],
    clientSecret: karate.properties['datahub.clientSecret']
  };

  if (env == 'integration') {
    config.urlBase = 'http://stellio-dev:8090/ngsi-ld/v1/';
  }

  // calls the OAuth2 token endpoint and gives back an access token to use in requests
  var result = karate.callSingle('classpath:api/oauth2.feature', config);
  config.accessToken = result.accessToken;

  // don't waste time waiting for a connection or if servers don't respond within 5 seconds
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 15000);
  return config;
}