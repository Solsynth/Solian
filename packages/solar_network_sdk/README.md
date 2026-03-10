# Solar Network SDK

A Flutter SDK for interacting with the Solar Network API.

## Features

- **Web Authentication**: Local HTTP server for web-based authentication flows
- **Token Management**: Secure token storage with SharedPreferences support
- **Network Status**: Track online/offline/maintenance states
- **Device Info**: Platform-aware user agent generation

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  solar_network_sdk:
    path: ../packages/solar_network_sdk
```

## Usage

### Initialization

```dart
import 'package:solar_network_sdk/solar_network_sdk.dart';

final tokenStorage = SharedPreferencesTokenStorage(key: 'solar_token');
final sdk = SolarNetworkSDK.create(
  serverUrl: 'https://api.solian.app',
  tokenStorage: tokenStorage,
);
```

### Web Authentication

```dart
final server = WebAuthServer(
  getToken: () => tokenStorage.getToken(),
  webUrl: 'https://app.solian.fr',
  getDio: () => sdk.apiClient,
);

final port = await server.start();
final authUrl = 'https://app.solian.fr/auth/web?port=$port';

// Open authUrl in browser, then wait for auth
final result = await WebAuthClient(
  baseUrl: 'http://127.0.0.1',
  port: port,
  webUrl: 'https://app.solian.fr',
).waitForAuth();
```

### Native App Connect (solian://)

For native apps (iOS/Android), you can use the `solian://auth/web` protocol
to request a challenge and exchange a signed challenge with redirect callbacks.

```dart
final client = WebAuthClient(
  baseUrl: 'http://127.0.0.1',
  port: port,
  webUrl: 'https://app.solian.fr',
);

// Step 1: request challenge (opens Solian app)
final challengeUrl = client.getProtocolChallengeUrl(
  appSlug: 'sopush',
  redirectUri: 'acme://auth/callback',
  state: 'request-123',
);

// launch challengeUrl with url_launcher
// callback example:
// acme://auth/callback?status=ok&challenge=...&state=request-123

// Step 2: sign challenge in your app, then request exchange
final exchangeUrl = client.getProtocolExchangeUrl(
  signedChallenge: signedChallenge,
  redirectUri: 'acme://auth/callback',
  secretId: 'optional-secret-id',
  state: 'request-123',
);

// launch exchangeUrl
// callback example:
// acme://auth/callback?status=success&token=...&refresh_token=...&expires_in=3600&refresh_expires_in=2592000&state=request-123
```

Callback query fields:

- `status`: `ok` | `denied` | `success` | `error`
- `challenge`: present when `status=ok`
- `token`: present when `status=success`
- `refresh_token`: may be present when `status=success`
- `expires_in`: may be present when `status=success`
- `refresh_expires_in`: may be present when `status=success`
- `error`: present when `status=error`
- `state`: echoed when you pass `state` in request URL

See full protocol details in `docs/web_auth_protocol.md`.

### Token Management

```dart
// Get stored token
final token = await tokenStorage.getToken();

// Clear token on logout
await tokenStorage.clearToken();
```

## Dependencies

- `dio: ^5.9.1`
- `shared_preferences: ^2.5.4`
- `device_info_plus: ^11.3.0`
- `package_info_plus: ^9.0.0`
