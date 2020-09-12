# How to run the tests

* Launch the tests

```
./gradlew test
```

* Launch the tests against a specific environment:

```
./gradlew -Dkarate.env=dev test
```

* Launch the tests with authentication settings:

```
./gradlew -Dkarate.env=dev -Ddatahub.clientId=<client_id> -Ddatahub.clientSecret=<client_secret> -Ddatahub.authServer=<auth_server> test
```