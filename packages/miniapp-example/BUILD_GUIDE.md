# Mini-App Example: Building for Production

This guide shows how to build and deploy the Payment Demo mini-app.

## Prerequisites

- Flutter SDK installed
- flutter_eval package installed
- Access to the PluginRegistry in your main app

## Development

### Running the Example

Run the example app directly:

```bash
cd packages/miniapp-example
flutter run
```

### Running Tests

Run the test suite:

```bash
flutter test
```

## Building for Production

### Step 1: Compile to Bytecode

Use flutter_eval to compile the mini-app to bytecode (.evc file):

```bash
cd packages/miniapp-example
flutter pub get
dart run flutter_eval:compile -i lib/main.dart -o payment_demo.evc
```

This will create `payment_demo.evc` in the current directory.

### Step 2: Upload to Server

Upload the `.evc` file to your server:

```bash
# Example: Upload to your mini-apps server
curl -X POST https://your-server.com/api/mini-apps/upload \
  -F "file=@payment_demo.evc" \
  -F "metadata={\"name\":\"Payment Demo\",\"version\":\"1.0.0\",\"description\":\"Example payment mini-app\"}"
```

### Step 3: Configure Server Metadata

Ensure your server returns the mini-app metadata in the correct format:

```json
{
  "id": "payment-demo",
  "name": "Payment Demo",
  "version": "1.0.0",
  "description": "Example payment mini-app",
  "download_url": "https://your-server.com/mini-apps/payment-demo.evc",
  "checksum": "sha256:abc123...",
  "size": 12345,
  "min_host_version": "1.0.0"
}
```

## Integration with Main App

### Load the Mini-App

Use the PluginRegistry to load and run the mini-app:

```dart
import 'package:island/modular/registry.dart';
import 'package:island/pods/plugin_registry.dart';

// Get the registry
final registry = ref.read(pluginRegistryProvider.notifier);

// Load the mini-app from server
final miniApp = await registry.loadMiniApp(
  'https://your-server.com/mini-apps/payment-demo.evc',
);

// Enable the mini-app
await registry.enablePlugin(miniApp.id);

// Launch the mini-app
await registry.launchMiniApp(context, miniApp.id);
```

### Provide PaymentAPI to Mini-App

Ensure the PaymentAPI is available to the mini-app through the eval bridge:

```dart
import 'package:island/modular/api/payment.dart';

// When loading the mini-app, register the PaymentAPI
final registry = PluginRegistry();

// Register PaymentAPI with the eval bridge
registry.registerBridge('PaymentAPI', PaymentAPI.instance);
```

## Mini-App Development Guide

### Project Structure

```
packages/miniapp-example/
├── lib/
│   ├── main.dart              # Main mini-app entry point
│   └── payment_api.dart       # PaymentAPI interface (for reference)
├── test/
│   └── main_test.dart         # Widget tests
├── pubspec.yaml               # Package configuration
└── README.md                  # This file
```

### Key Files

#### `lib/main.dart`
- Contains the main mini-app widget
- Implements the UI for testing PaymentAPI
- Can be run standalone or compiled to bytecode

#### `lib/payment_api.dart`
- Shows the PaymentAPI interface
- Used as a reference for API usage
- Not compiled into the final .evc file

### Writing Your Own Mini-App

1. Create a new Flutter package:

```bash
mkdir packages/my-miniapp
cd packages/my-miniapp
flutter create --org com.example my_miniapp
```

2. Add flutter_eval to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_eval: ^0.8.2
```

3. Write your mini-app in `lib/main.dart`
4. Test with `flutter test`
5. Compile to `.evc`:

```bash
dart run flutter_eval:compile -i lib/main.dart -o my_miniapp.evc
```

## API Usage Examples

### Creating an Order

```dart
final paymentApi = PaymentAPI.instance;

final order = await paymentApi.createOrder(
  CreateOrderRequest(
    amount: 19.99,
    currency: 'USD',
    description: 'Premium subscription',
    metadata: {'plan': 'premium', 'duration': '1m'},
  ),
);

print('Order created: ${order.orderId}');
```

### Processing Payment with Overlay

```dart
final result = await paymentApi.processPaymentWithOverlay(
  orderId: order.orderId,
);

if (result.success) {
  print('Payment successful: ${result.transactionId}');
  // Navigate to success screen
} else {
  print('Payment failed: ${result.errorMessage}');
  // Show error to user
}
```

### Processing Direct Payment

```dart
final result = await paymentApi.processDirectPayment(
  orderId: order.orderId,
  paymentMethod: 'credit_card',
  paymentToken: 'tok_abc123',
);

if (result.success) {
  print('Payment successful: ${result.transactionId}');
} else {
  print('Payment failed: ${result.errorMessage}');
}
```

## Testing Strategy

### Unit Tests
Test business logic and API interactions:

```dart
test('should create order with correct amount', () {
  final request = CreateOrderRequest(
    amount: 19.99,
    currency: 'USD',
    description: 'Test order',
  );
  
  expect(request.amount, 19.99);
  expect(request.currency, 'USD');
});
```

### Widget Tests
Test UI components:

```bash
flutter test test/main_test.dart
```

### Integration Tests
Test the mini-app with the eval bridge:

```dart
testWidgets('should process payment through eval bridge', (tester) async {
  // Setup eval bridge
  final eval = EvalCompiler();
  eval.addPlugin(PaymentAPIPlugin());
  
  // Load mini-app
  final program = eval.compile(await File('main.dart').readAsString());
  
  // Run mini-app
  await tester.pumpWidget(program.build());
  
  // Test payment flow
  await tester.tap(find.text('Pay with Overlay'));
  await tester.pumpAndSettle();
  
  expect(find.text('Payment successful!'), findsOneWidget);
});
```

## Troubleshooting

### Compilation Errors

**Error**: `Method not found in eval bridge`
**Solution**: Ensure PaymentAPI is registered with the eval bridge before loading the mini-app.

**Error**: `Permission denied` when accessing storage
**Solution**: Add the following to `AndroidManifest.xml` (Android):

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

And `Info.plist` (iOS):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to save payment receipts</string>
```

### Runtime Errors

**Error**: `PaymentAPI.instance is null`
**Solution**: Ensure PaymentAPI is initialized before the mini-app starts.

**Error**: `Network timeout`
**Solution**: Increase timeout in PaymentAPI configuration or check network connectivity.

### Testing Errors

**Error**: `Widget not found`
**Solution**: Ensure you're pumping the widget tree with `await tester.pump()` after state changes.

**Error**: `Multiple widgets found`
**Solution**: Use more specific finders or add keys to widgets.

## Best Practices

1. **Keep Mini-Apps Small**: Mini-apps should be focused and lightweight
2. **Handle Errors Gracefully**: Always wrap API calls in try-catch blocks
3. **Show Loading States**: Provide feedback for long-running operations
4. **Test Thoroughly**: Write comprehensive tests for all user flows
5. **Version Management**: Include version information in metadata
6. **Security**: Never store sensitive data in the mini-app
7. **Network Handling**: Implement retry logic for network failures
8. **User Feedback**: Always show success/error messages to users

## Performance Tips

1. **Lazy Loading**: Load resources only when needed
2. **Image Optimization**: Compress images before including in mini-app
3. **Code Splitting**: Split large mini-apps into smaller modules
4. **Caching**: Cache API responses to reduce network calls
5. **Debouncing**: Debounce user inputs to reduce API calls

## Security Considerations

1. **Input Validation**: Always validate user inputs
2. **API Keys**: Never include API keys in the mini-app code
3. **HTTPS Only**: Always use HTTPS for API calls
4. **Data Encryption**: Encrypt sensitive data stored locally
5. **Permissions**: Request minimum necessary permissions
6. **Updates**: Always update to the latest version of dependencies

## Support

For issues or questions:
1. Check the main README in `lib/modular/README.md`
2. Review PaymentAPI documentation in `lib/modular/api/README.md`
3. Check test examples in `test/main_test.dart`
4. Review the PaymentAPI interface in `lib/payment_api.dart`
