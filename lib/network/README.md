# Network

## Get started

The network component provides an easy way to interact with API's, including authentication using Bearer token and the OAuth 2 flow.

```dart
import 'package:illuminate/common.dart';
import 'package:illuminate/network.dart';

class ApiClient extends Client {
    ApiClient({
        required this.host,
    }) : super(
          ApiConfig(host: host),
        );

    Future<Team> getList() async {
        final requestObject = Request(
            path: '/api/articles',
            httpMethod: HttpMethod.get,
        );

        try {
            final response = await request(requestObject);

            final data = tryCast<Map<String, dynamic>>(response.data['data']);
            if (data == null) {
                throw ResponseParsingException();
            }

            return Article.fromJson(data);
        } catch (e) {
            print('Error getting articles: $e');
            rethrow;
        }
    }
}
```

## Advanced usage

**Request object**

```dart
// A request object can contain the config below:
Request({
    required String path,
    HttpMethod httpMethod = HttpMethod.get,
    dynamic body,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers, 
    Authentication authentication = Authentication.none,
});
```

### Exception handler

You're able to pass an exception handler, which can be used to track errors with for instance Sentry.

```dart
class ApiClient extends Client { 
    ApiClient({
        required this.host,
    }) : super(
            ApiConfig(host: host),
            exceptionHandler: (exception, stacktrace) async {
                // Do something, like tracking errors with Sentry
            },
        );
}
```

### Bearer token

Sometimes, you're only using a simple bearer token as authentication method. You're able to configure each request as "requires bearer token" via:

```dart
final requestObject = Request(
    path: '/api/articles',
    httpMethod: HttpMethod.get,
    authentication: Authentication.bearerToken,
);
```

You can set the bearer token whenever the user signed in, or you retrieved a token via:

```dart
final bearerToken = 'Token1234';
final client = ApiClient(..);
client.setAccessToken(bearerToken);
```

#### Authentication failure
When, set, this adds the bearer token from storage to the requests. When the request fails, it doesn't automatically refresh the token. That's a manual step. You will receive the error response when executing the request and can do whatever you want according to the status code.

You can also override a method in your ApiClient:

```dart
class ApiClient extends Client { 

    /// This method is executed when the client receives a 401 status code response with a manually configured bearer token.
    @override
    Future<void> onAuthenticationFailure() async {
        // You can for instance clear the user's session:
        await AuthenticationService.instance.sessionExpired();
    }
}
```

#### Signing out
You can manually clear the stored tokens via:

```dart
final client = ApiClient(..);
await client.clear();
```

### Oauth2

First, pass OAuth configuration to your ApiClient:

```dart
class ApiClient extends Client { 
    ApiClient({
        required this.host,
        required oauthConfig,
    }) : super(
            ApiConfig(host: host, oAuthConfig: oauthConfig),
            exceptionHandler: (exception, stacktrace) async {
                // Do something, like tracking errors with Sentry
            },
        );
}

final client = ApiClient(
    host: 'https://api.com',
    oauthConfig: OAuthConfig(
        host: 'https://auth.api.com',
        tokenEndpoint: '/oauth/token',
        clientId: '1',
        authorizeEndpoint: '/oauth/authorize',
        clientSecret: '2',
        pkceEnabled = false,
    ),
);
```

**OAuthConfig**

|**Parameter**|**Required**|**Description**|**Example**|
|-|-|-|-|
|`host`|✔️|The host of the authentication server|https://auth.api.com|
|`tokenEndpoint`|✔️|The endpoint used to retrieve an access or refresh token|`/oauth/token`|
|`authorizeEndpoint`||The endpoint used for authorization, when using the `authorization_code` grant type|`/oauth/authorize`|
|`clientId`|✔️|The client id of the app|`1`|
|`clientSecret`||The client secret of the app|`2`|
|`pkceEnabled`||Whether a Proof Key for Code Exchange is required|`false`|

Adding `OAuthConfig` to the client automatically sets up the OAuth interceptor. It checks if a request needs to be authenticated and passes along the access token from storage. 

It also tries to refresh the access token once it receives an 401 from the API, indicating the token has been revoked.

#### Authentication
Currently, the only supported flows are `authorization_code` and `refresh_token`. 

You can use the `OAuthAuthenticator` to help you create a session for the user.

```dart
final authenticator = OAuthAuthenticator(
    host: 'https://auth.api.com',
    config: OAuthConfig(
        host: 'https://auth.api.com',
        tokenEndpoint: '/oauth/token',
        clientId: '1',
        authorizeEndpoint: '/oauth/authorize',
        clientSecret: '2',
        pkceEnabled = false,
    )
);
```

To start the authorization request, you'll need the url. The authenticator provides a build method to construct it for you:

```dart
final redirectUri = 'scheme://auth/signed_in';
final scopes = 'email';

AuthorizationRequest request = authenticator.buildAuthorizionRequest(
    redirectUri, 
    scopes,
);

// The url you can open start the authorization flow
String url = request.url;
```

The user is now redirected to the url. You can trigger this inside a webview, or the browser. When finished, the OAuth server redirects the user back to the redirectUri you provided. You need to parse the code from the url, to finish the authorization flow.

```dart
final code = Uri.parse(openedRedirectUri).queryParameters['code'];
if (code == null) {
    throw OAuthSignInFailureException(message: 'No token present in return URI');
}

await authenticator.authenticate(
    code, 
    authorizationRequest: request
);

// The user's session is now stored securely, you can execute any request which requires an OAuth2 access token.

// Retrieve the profile
final requestObject = Request(
    path: '/api/users/profile',
    httpMethod: HttpMethod.get,
    authentication: Authentication.oauth2,
);

final response = await request(requestObject);
final profile = User.fromJson(response.data['data']);
```

#### Signing out

Use the same OAuthAuthenticator to clear the session of the user.

```dart
await authenticator.signOut();
```

