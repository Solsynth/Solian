# Payment API for Mini-Apps

## Overview

Payment API (`lib/modular/api/payment.dart`) provides a simple interface for mini-apps to process payments without needing access to Riverpod or Flutter widget trees.

## Usage

### Basic Setup

```dart
import 'package:island/modular/api/payment.dart';

// Get singleton instance
final paymentAPI = PaymentAPI.instance;
```

### Creating a Payment Order

```dart
final order = await paymentAPI.createOrder(
  CreateOrderRequest(
    amount: 1000, // $10.00 in cents
    currency: 'USD',
    remarks: 'Premium subscription',
    payeeWalletId: 'wallet_123',
    appIdentifier: 'my.miniapp',
  ),
);

// Use the order ID for payment
final orderId = order.id;
```

### Processing Payment with Overlay

```dart
final result = await paymentAPI.processPaymentWithOverlay(
  context: context,
  createOrderRequest: CreateOrderRequest(
    amount: 1000,
    currency: 'USD',
    remarks: 'Premium subscription',
  ),
  enableBiometric: true,
);

if (result.success) {
  print('Payment successful: ${result.order}');
} else {
  print('Payment failed: ${result.error}');
}
```

### Processing Existing Payment

```dart
final result = await paymentAPI.processPaymentWithOverlay(
  context: context,
  request: PaymentRequest(
    orderId: 'order_123',
    amount: 1000,
    currency: 'USD',
    pinCode: '123456',
    enableBiometric: true,
    showOverlay: true,
  ),
);
```

### Processing Payment Without Overlay (Direct)

```dart
final result = await paymentAPI.processDirectPayment(
  PaymentRequest(
    orderId: 'order_123',
    amount: 1000,
    currency: 'USD',
    pinCode: '123456',
    enableBiometric: false, // No biometric for direct
  ),
);

if (result.success) {
  // Handle success
} else {
  // Handle error
}
```

## API Methods

### `createOrder(CreateOrderRequest)`

Creates a new payment order on the server.

**Parameters:**
- `amount` (required): Amount in smallest currency unit (cents for USD, etc.)
- `currency` (required): Currency code (e.g., 'USD', 'EUR')
- `remarks` (optional): Payment description
- `payeeWalletId` (optional): Target wallet ID
- `appIdentifier` (optional): Mini-app identifier
- `meta` (optional): Additional metadata

**Returns:** `SnWalletOrder?` or throws exception

### `processPayment({String orderId, String pinCode, bool enableBiometric})`

Processes a payment for an existing order. Must be called from within mini-app context.

**Parameters:**
- `orderId` (required): Order ID to process
- `pinCode` (required): 6-digit PIN code
- `enableBiometric` (optional, default: true): Allow biometric authentication

**Returns:** `SnWalletOrder?` or throws exception

### `processPaymentWithOverlay({BuildContext, PaymentRequest?, CreateOrderRequest?, bool enableBiometric})`

Shows payment overlay UI and processes payment. Use this for user-facing payments.

**Parameters:**
- `context` (required): BuildContext for showing overlay
- `request` (optional): Existing payment request with orderId
- `createOrderRequest` (optional): New order request (must provide one)
- `enableBiometric` (optional, default: true): Enable biometric authentication

**Returns:** `PaymentResult`

### `processDirectPayment(PaymentRequest)`

Processes payment without showing UI overlay. Use for automatic/background payments.

**Parameters:**
- `request` (required): PaymentRequest with all details including pinCode

**Returns:** `PaymentResult`

## Data Types

### `PaymentRequest`

```dart
const factory PaymentRequest({
    required String orderId,
    required int amount,
    required String currency,
    String? remarks,
    String? payeeWalletId,
    String? pinCode,
    @Default(true) bool showOverlay,
    @Default(true) bool enableBiometric,
});
```

### `CreateOrderRequest`

```dart
const factory CreateOrderRequest({
    required int amount,
    required String currency,
    String? remarks,
    String? payeeWalletId,
    String? appIdentifier,
    @Default({}) Map<String, dynamic> meta,
});
```

### `PaymentResult`

```dart
const factory PaymentResult({
    required bool success,
    SnWalletOrder? order,
    String? error,
    String? errorCode,
});
```

## Error Handling

The API handles common error scenarios:

- **401/403**: Invalid PIN code
- **400**: Payment error with message
- **404**: Order not found
- **503**: Service unavailable/maintenance
- **Network errors**: Connection issues

## Internals

The API:
- Uses a singleton pattern (`PaymentAPI.instance`)
- Manages its own Dio instance with proper interceptors
- Reads server URL and token from SharedPreferences
- Handles authentication automatically
- Reuses existing `PaymentOverlay` widget for UI

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:island/modular/api/payment.dart';

class MiniAppPayment extends StatelessWidget {
  const MiniAppPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _processWithOverlay(context),
              child: const Text('Pay $10.00 (with overlay)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _processDirect(context),
              child: const Text('Pay $10.00 (direct)'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processWithOverlay(BuildContext context) async {
    final api = PaymentAPI.instance;
    
    final result = await api.processPaymentWithOverlay(
      context: context,
      createOrderRequest: CreateOrderRequest(
        amount: 1000, // $10.00
        currency: 'USD',
        remarks: 'Test payment from mini-app',
        appIdentifier: 'com.example.miniapp',
      ),
      enableBiometric: true,
    );

    if (!context.mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${result.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processDirect(BuildContext context) async {
    final api = PaymentAPI.instance;
    
    final result = await api.processDirectPayment(
      PaymentRequest(
        orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        amount: 1000,
        currency: 'USD',
        pinCode: '123456', // Should come from user input
        enableBiometric: false,
      ),
    );

    if (!context.mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${result.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

## Notes

- All methods are async and return Futures
- Errors are thrown as exceptions, catch and handle in your mini-app
- PIN codes must be 6 digits
- Amount is in smallest currency unit (cents for USD)
- Token is managed internally, no need to provide it
- Server URL is loaded from app preferences

## Integration with flutter_eval

To expose this API to mini-apps loaded via flutter_eval:

1. Add to plugin registry:
```dart
// In lib/modular/registry.dart
import 'package:island/modular/api/payment.dart';

Future<PluginLoadResult> loadMiniApp(...) async {
  // ... existing code ...
  
  final runtime = Runtime(ByteData.sublistView(bytecode));
  runtime.addPlugin(flutterEvalPlugin);
  
  // Register Payment API
  final paymentAPI = PaymentAPI.instance;
  // You'll need to create a bridge to expose this to eval
  
  // ... rest of loading code
}
```

2. Mini-app can access API:
```dart
// mini_app/main.dart
final paymentAPI = PaymentAPI.instance; // Will be exposed via bridge
```

## Security Considerations

- **Never hardcode PIN codes**: Always get from user input
- **Use secure storage**: App manages PIN storage securely
- **Validate amounts**: Ensure amounts are reasonable
- **Handle errors gracefully**: Show user-friendly messages
- **Biometric is optional**: Some devices may not support it
