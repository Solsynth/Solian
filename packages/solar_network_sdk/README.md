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
