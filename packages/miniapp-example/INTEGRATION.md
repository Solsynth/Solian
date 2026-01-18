# Mini-App Example - Integration Overview

This document explains how the `miniapp-example` package integrates with the main Island application and the plugin registry system.

## Architecture Overview

```
Island Main App
│
├── PluginRegistry (lib/modular/registry.dart)
│   ├── loadMiniApp()       # Downloads and caches .evc files
│   ├── enablePlugin()      # Activates mini-app
│   └── launchMiniApp()     # Runs mini-app in full-screen
│
├── PaymentAPI (lib/modular/api/payment.dart)
│   └── Singleton with internal Dio client
│
└── Eval Bridge
    ├── PaymentAPI instance registered
    └── Available to mini-apps at runtime
```

## Integration Flow

### 1. Mini-App Development

```
Developer creates mini-app in packages/miniapp-example
         ↓
Tests with `flutter test` (17 tests passing)
         ↓
Runs with `flutter run` (debug mode)
         ↓
Compiles with `dart run flutter_eval:compile -i lib/main.dart -o payment_demo.evc`
         ↓
Uploads payment_demo.evc to server
```

### 2. Server Setup

Server provides mini-app metadata:

```json
{
  "id": "payment-demo",
  "name": "Payment Demo",
  "version": "1.0.0",
  "description": "Example payment mini-app",
  "download_url": "https://your-server.com/mini-apps/payment_demo.evc",
  "checksum": "sha256:abc123...",
  "size": 3456,
  "min_host_version": "1.0.0"
}
```

### 3. Main App Discovery

```dart
// In main app startup
final registry = ref.read(pluginRegistryProvider.notifier);

// Register PaymentAPI with eval bridge
registry.registerBridge('PaymentAPI', PaymentAPI.instance);

// Sync with server to discover mini-apps
await registry.syncMiniApps();
```

### 4. User Downloads Mini-App

```dart
// User selects mini-app from list
final miniApp = await registry.loadMiniApp(
  'https://your-server.com/mini-apps/payment_demo.evc',
);

// PluginRegistry handles:
// 1. Download from server
// 2. Save to {appDocuments}/mini_apps/{id}/payment_demo.evc
// 3. Validate checksum
// 4. Cache locally
// 5. Save to SharedPreferences (enabled apps list)
```

### 5. Enable Mini-App

```dart
// User enables mini-app
await registry.enablePlugin('payment-demo');

// PluginRegistry:
// 1. Adds to enabled apps in SharedPreferences
// 2. Prepares for launch
```

### 6. Launch Mini-App

```dart
// User launches mini-app
await registry.launchMiniApp(context, 'payment-demo');

// PluginRegistry:
// 1. Loads .evc bytecode
// 2. Creates Runtime with flutter_eval
// 3. Provides PaymentAPI through eval bridge
// 4. Runs mini-app main() function
// 5. Displays full-screen
```

### 7. Mini-App Uses PaymentAPI

```dart
// Inside mini-app (payment_demo.evc)

// Access PaymentAPI through eval bridge
final paymentApi = PaymentAPI.instance;

// Create order
final order = await paymentApi.createOrder(
  CreateOrderRequest(
    amount: 19.99,
    currency: 'USD',
    description: 'Premium subscription',
  ),
);

// Process payment
final result = await paymentApi.processPaymentWithOverlay(
  orderId: order.orderId,
);

// Show result
if (result.success) {
  print('Payment successful!');
} else {
  print('Payment failed: ${result.errorMessage}');
}
```

## Key Integration Points

### 1. PaymentAPI Registration

**Location**: `lib/modular/registry.dart`

```dart
class PluginRegistry {
  final Map<String, dynamic> _bridge = {};
  
  void registerBridge(String name, dynamic api) {
    _bridge[name] = api;
  }
  
  // Called when loading mini-app
  Runtime _createRuntime() {
    return Runtime(
      bridge: _bridge, // Pass PaymentAPI to mini-app
      // ... other config
    );
  }
}
```

**Usage**: In main app startup

```dart
void main() async {
  final registry = ref.read(pluginRegistryProvider.notifier);
  
  // Register PaymentAPI
  registry.registerBridge('PaymentAPI', PaymentAPI.instance);
  
  runApp(MyApp());
}
```

### 2. Mini-App Loading

**Location**: `lib/modular/registry.dart` - `loadMiniApp()` method

```dart
Future<MiniApp> loadMiniApp(String url) async {
  // 1. Download .evc file
  final bytes = await _downloadFile(url);
  
  // 2. Save to cache
  final path = await _saveToCache(url, bytes);
  
  // 3. Create MiniApp object
  final miniApp = MiniApp(
    id: _extractId(url),
    bytecodePath: path,
    // ... metadata
  );
  
  return miniApp;
}
```

### 3. Mini-App Launch

**Location**: `lib/modular/registry.dart` - `launchMiniApp()` method

```dart
Future<void> launchMiniApp(BuildContext context, String id) async {
  // 1. Get mini-app
  final miniApp = _getMiniApp(id);
  
  // 2. Load bytecode
  final bytecode = await File(miniApp.bytecodePath).readAsBytes();
  
  // 3. Create runtime with PaymentAPI bridge
  final runtime = _createRuntime();
  
  // 4. Execute mini-app
  final program = runtime.loadProgram(bytecode);
  program.execute();
  
  // 5. Navigate to mini-app screen
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MiniAppScreen(program)),
  );
}
```

## Data Flow

### Mini-App Request Flow

```
Mini-App (payment_demo.evc)
         ↓
PaymentAPI instance (from eval bridge)
         ↓
PaymentAPI class (lib/modular/api/payment.dart)
         ↓
Dio client (internal)
         ↓
Server API (your payment server)
         ↓
Response back to mini-app
```

### State Management

```
SharedPreferences (Persistent)
├── enabled_mini_apps: ['payment-demo', ...]
└── last_sync: '2025-01-18T00:00:00Z'

File System (Cached .evc files)
└── {appDocuments}/mini_apps/
    ├── payment-demo/
    │   └── payment_demo.evc
    └── other-miniapp/
        └── app.evc

Runtime (Memory)
├── Loaded mini-apps
└── Bridge APIs (PaymentAPI, etc.)
```

## File Locations

### Main App Files

```
lib/
├── modular/
│   ├── interface.dart          # Plugin interfaces
│   ├── registry.dart           # PluginRegistry class
│   ├── api/
│   │   └── payment.dart        # PaymentAPI implementation
│   └── README.md              # Plugin system docs
└── pods/
    └── plugin_registry.dart    # Riverpod providers
```

### Mini-App Example Files

```
packages/miniapp-example/
├── lib/
│   ├── main.dart              # Mini-app code
│   └── payment_api.dart       # API reference
├── test/
│   └── main_test.dart         # Widget tests
├── README.md                  # API usage docs
├── BUILD_GUIDE.md             # Build instructions
├── SUMMARY.md                 # This document
├── build.sh                   # Build script
└── pubspec.yaml              # Package config
```

### Generated Files

```
build/                         # Build artifacts (ignored)
*.evc                          # Compiled bytecode (optional)
*.freezed.dart                # Generated code
*.g.dart                      # Generated code
```

## Configuration

### Main App Setup

1. **Add to pubspec.yaml**:
```yaml
dependencies:
  flutter_eval: ^0.8.2
```

2. **Initialize PluginRegistry**:
```dart
final registry = ref.read(pluginRegistryProvider.notifier);
await registry.initialize();
registry.registerBridge('PaymentAPI', PaymentAPI.instance);
```

3. **Set up server**:
```dart
final serverInfo = MiniAppServerInfo(
  baseUrl: 'https://your-server.com/api',
  miniAppsPath: '/mini-apps',
);
registry.setServerInfo(serverInfo);
```

### Mini-App Setup

1. **Create package**:
```bash
mkdir packages/my-miniapp
cd packages/my-miniapp
flutter create --org com.example my_miniapp
```

2. **Add flutter_eval**:
```yaml
dependencies:
  flutter_eval: ^0.8.2
```

3. **Write mini-app**:
```dart
import 'package:flutter/material.dart';

class MyMiniApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Hello from Mini-App!')),
      ),
    );
  }
}

void main() => runApp(MyMiniApp());
```

4. **Test and build**:
```bash
flutter test
dart run flutter_eval:compile -i lib/main.dart -o my_miniapp.evc
```

## Testing Strategy

### Unit Tests

Test business logic in isolation:

```dart
test('PaymentAPI should create order', () async {
  final api = PaymentAPI.instance;
  
  final order = await api.createOrder(
    CreateOrderRequest(
      amount: 19.99,
      currency: 'USD',
      description: 'Test',
    ),
  );
  
  expect(order.orderId, isNotEmpty);
});
```

### Widget Tests

Test UI components:

```bash
cd packages/miniapp-example
flutter test
```

### Integration Tests

Test full flow:

```dart
testWidgets('mini-app should process payment', (tester) async {
  // Setup registry
  final registry = PluginRegistry();
  registry.registerBridge('PaymentAPI', PaymentAPI.instance);
  
  // Load mini-app
  final miniApp = await registry.loadMiniApp('test.evc');
  
  // Launch
  await registry.launchMiniApp(tester.element(miniApp), miniApp.id);
  
  // Test payment flow
  await tester.tap(find.text('Pay with Overlay'));
  await tester.pumpAndSettle();
  
  expect(find.text('Payment successful!'), findsOneWidget);
});
```

## Troubleshooting

### Mini-App Won't Load

**Checklist**:
- [ ] .evc file exists at expected path
- [ ] File is not corrupted (verify checksum)
- [ ] PaymentAPI is registered with bridge
- [ ] flutter_eval is properly initialized
- [ ] Mini-app main() function exists

**Debug**:
```dart
// Add logging in registry.dart
print('Loading mini-app from: $path');
print('Bytecode size: ${bytecode.length}');
print('Bridge APIs: ${_bridge.keys}');
```

### PaymentAPI Not Available

**Checklist**:
- [ ] PaymentAPI is registered before mini-app loads
- [ ] Bridge name matches ('PaymentAPI')
- [ ] Singleton instance is not null
- [ ] Dio client is configured

**Debug**:
```dart
// Check bridge
print('Bridge has PaymentAPI: ${_bridge.containsKey('PaymentAPI')}');

// Check instance
print('PaymentAPI.instance: ${PaymentAPI.instance}');
```

### Network Errors

**Checklist**:
- [ ] Server URL is accessible
- [ ] API endpoints are correct
- [ ] Authentication token exists
- [ ] Network permissions granted

**Debug**:
```dart
// Add Dio interceptors for logging
dio.interceptors.add(LogInterceptor(
  request: true,
  response: true,
  error: true,
));
```

## Best Practices

### For Mini-App Developers

1. **Keep it Small**: Mini-apps should be focused and lightweight
2. **Test Thoroughly**: Write comprehensive tests for all user flows
3. **Handle Errors**: Always wrap API calls in try-catch
4. **Show Feedback**: Provide loading states and user feedback
5. **Use Official APIs**: Only use PaymentAPI and other provided APIs
6. **Version Control**: Include version information in metadata
7. **Security**: Never store sensitive data or API keys

### For Main App Developers

1. **Register APIs Early**: Register all bridge APIs before loading mini-apps
2. **Handle Failures**: Gracefully handle mini-app load failures
3. **Cache Wisely**: Implement proper caching for .evc files
4. **Validate Metadata**: Verify server metadata before loading
5. **Secure Bridge**: Only expose necessary APIs to mini-apps
6. **Monitor Usage**: Track mini-app usage and performance
7. **Update System**: Keep flutter_eval and dependencies updated

## Performance Considerations

### Load Time Optimization

1. **Compress .evc files**: Use gzip compression for download
2. **Lazy Loading**: Only load bytecode when needed
3. **Prefetch**: Download popular mini-apps in background
4. **Cache Validation**: Use ETags for cache validation

### Memory Optimization

1. **Unload When Done**: Release mini-app resources when closed
2. **Limit Concurrent Apps**: Only load one mini-app at a time
3. **Clean Up Runtime**: Dispose runtime after mini-app exits
4. **Monitor Memory**: Track memory usage during operation

### Network Optimization

1. **Batch Requests**: Combine multiple requests when possible
2. **Retry Logic**: Implement exponential backoff for retries
3. **Offline Support**: Cache responses for offline use
4. **Compression**: Enable compression for API responses

## Security Considerations

### Mini-App Sandbox

Mini-apps run in a sandboxed environment:
- Limited file system access
- No direct network access (through bridge APIs only)
- No access to other mini-apps
- Limited device permissions

### PaymentAPI Security

- Internal Dio client (no external dependencies)
- Token management via SharedPreferences
- HTTPS-only connections
- Automatic error logging
- No sensitive data in logs

### Best Practices

1. **Validate Inputs**: Always validate user inputs
2. **Encrypt Data**: Encrypt sensitive data at rest
3. **Use HTTPS**: Always use HTTPS for API calls
4. **Minimize Permissions**: Request minimum necessary permissions
5. **Regular Updates**: Keep dependencies updated
6. **Audit Logs**: Review audit logs regularly

## Future Enhancements

### Planned Features

1. **Hot Reload**: Support live reloading during development
2. **Plugin System**: Allow mini-apps to use plugins
3. **Version Management**: Automatic version checking and updates
4. **Analytics**: Built-in analytics for mini-app usage
5. **Marketplace**: Mini-app marketplace UI
6. **Permissions System**: Fine-grained permissions for mini-apps

### Potential Improvements

1. **Smaller Bytecode**: Reduce .evc file size
2. **Faster Compilation**: Improve compilation speed
3. **Better Debugging**: Enhanced debugging tools
4. **Offline Support**: Better offline functionality
5. **Background Tasks**: Support for background operations

## Resources

### Documentation

- **Plugin System**: `lib/modular/README.md`
- **Payment API**: `lib/modular/api/README.md`
- **Build Guide**: `packages/miniapp-example/BUILD_GUIDE.md`
- **API Reference**: `packages/miniapp-example/lib/payment_api.dart`

### Code Examples

- **Mini-App Example**: `packages/miniapp-example/lib/main.dart`
- **Widget Tests**: `packages/miniapp-example/test/main_test.dart`
- **Plugin Registry**: `lib/modular/registry.dart`
- **Payment API**: `lib/modular/api/payment.dart`

### Tools

- **Build Script**: `packages/miniapp-example/build.sh`
- **Flutter Eval**: https://pub.dev/packages/flutter_eval
- **Flutter Docs**: https://flutter.dev/docs

## Support

For issues or questions:

1. Check documentation files
2. Review code examples
3. Check test cases
4. Review PaymentAPI interface
5. Consult build guide

## Conclusion

The mini-app example demonstrates a complete integration between:
- Main app with PluginRegistry
- PaymentAPI with internal Dio client
- Mini-app compiled to .evc bytecode
- Eval bridge providing API access

This architecture enables:
- Dynamic loading of mini-apps
- Secure API access through bridge
- Full-screen mini-app experience
- Version management and updates
- Caching and offline support

For more details, see the documentation files listed above.
