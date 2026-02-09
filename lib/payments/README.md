# Payment Overlay Widget

A reusable payment verification overlay that supports both 6-digit PIN input and biometric authentication for secure payment processing.

## Features

- **6-digit PIN Input**: Secure numeric PIN entry with automatic focus management
- **Biometric Authentication**: Support for fingerprint and face recognition
- **Order Summary**: Display payment details including amount, description, and remarks
- **Integrated API Calls**: Automatically handles payment processing via `/orders/{orderId}/pay`
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Loading States**: Visual feedback during payment processing
- **Responsive Design**: Adapts to different screen sizes and orientations
- **Customizable**: Flexible callbacks and styling options
- **Accessibility**: Screen reader support and proper focus management
- **Localization**: Full i18n support with easy_localization

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:solian/models/wallet.dart';
import 'package:solian/widgets/payment/payment_overlay.dart';

// Create an order
final order = SnWalletOrder(
  id: 'order_123',
  amount: 2500, // $25.00 in cents
  currency: 'USD',
  description: 'Premium Subscription',
  remarks: 'Monthly billing',
  status: 'pending',
);

// Show payment overlay
PaymentOverlay.show(
  context: context,
  order: order,
  onPaymentSuccess: (completedOrder) {
    // Handle successful payment
    print('Payment completed: ${completedOrder.id}');
    // Navigate to success page or update UI
  },
  onPaymentError: (error) {
    // Handle payment error
    print('Payment failed: $error');
    // Show error message to user
  },
  onCancel: () {
    Navigator.of(context).pop();
    print('Payment cancelled');
  },
  enableBiometric: true,
);
```

### Advanced Usage with Loading States

```dart
bool isLoading = false;

PaymentOverlay.show(
  context: context,
  order: order,
  enableBiometric: true,
  isLoading: isLoading,
  onPinSubmit: (String pin) async {
    setState(() => isLoading = true);
    try {
      await processPaymentWithPin(pin);
      Navigator.of(context).pop();
    } catch (e) {
      showErrorDialog(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  },
  onBiometricAuth: () async {
    setState(() => isLoading = true);
    try {
      final authenticated = await authenticateWithBiometrics();
      if (authenticated) {
        await processPaymentWithBiometrics();
        Navigator.of(context).pop();
      }
    } catch (e) {
      showErrorDialog(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  },
);
```

## Parameters

### PaymentOverlay.show()

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `context` | `BuildContext` | ✅ | The build context for showing the overlay |
| `order` | `SnWalletOrder` | ✅ | The order to be paid |
| `onPaymentSuccess` | `Function(SnWalletOrder)?` | ❌ | Callback when payment succeeds with completed order |
| `onPaymentError` | `Function(String)?` | ❌ | Callback when payment fails with error message |
| `onCancel` | `VoidCallback?` | ❌ | Callback when payment is cancelled |
| `enableBiometric` | `bool` | ❌ | Whether to show biometric option (default: true) |

## API Integration

The PaymentOverlay automatically handles payment processing by calling the `/orders/{orderId}/pay` endpoint with the following request body:

### PIN Payment
```json
{
  "pin": "123456"
}
```

### Biometric Payment
```json
{
  "biometric": true
}
```

### Response
The API should return the completed `SnWalletOrder` object:

```json
{
  "id": "order_123",
  "amount": 2500,
  "currency": "USD",
  "description": "Premium Subscription",
  "status": "completed",
  "processorReference": "txn_abc123",
  // ... other order fields
}
```

### Error Handling
The widget handles common HTTP status codes:
- `401`: Invalid PIN or biometric authentication failed
- `400`: Bad request with custom error message
- Other errors: Generic payment failed message

### Implementation Example

```dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    final isAvailable = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to complete payment',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
}
```

## Localization

Add these keys to your localization files:

```json
{
  "paymentVerification": "Payment Verification",
  "paymentSummary": "Payment Summary",
  "amount": "Amount",
  "description": "Description",
  "pinCode": "PIN Code",
  "biometric": "Biometric",
  "enterPinToConfirmPayment": "Enter your 6-digit PIN to confirm payment",
  "clearPin": "Clear PIN",
  "useBiometricToConfirm": "Use biometric authentication to confirm payment",
  "touchSensorToAuthenticate": "Touch the sensor to authenticate",
  "authenticating": "Authenticating...",
  "authenticateNow": "Authenticate Now",
  "confirm": "Confirm",
  "cancel": "Cancel",
  "paymentFailed": "Payment failed. Please try again.",
  "invalidPin": "Invalid PIN. Please try again.",
  "biometricAuthFailed": "Biometric authentication failed. Please try again.",
  "paymentSuccess": "Payment completed successfully!",
  "paymentError": "Payment failed: {error}"
}
```

## Styling

The widget automatically adapts to your app's theme. It uses:

- `Theme.of(context).colorScheme.primary` for primary elements
- `Theme.of(context).colorScheme.surface` for backgrounds
- `Theme.of(context).textTheme` for typography

## Security Considerations

1. **PIN Handling**: The PIN is passed as a string to your callback. Ensure you handle it securely and don't log it.
2. **Biometric Authentication**: Always verify biometric authentication on your backend.
3. **Network Security**: Use HTTPS for all payment-related API calls.
4. **Data Validation**: Validate all payment data on your backend before processing.

## Example Integration

See `payment_overlay_example.dart` for a complete working example that demonstrates:

- How to show the overlay
- Handling PIN and biometric authentication
- Processing payments
- Error handling
- Loading states

## Dependencies

- `flutter/material.dart` - Material Design components
- `flutter/services.dart` - Input formatters and system services
- `flutter_riverpod/flutter_riverpod.dart` - State management and dependency injection
- `gap/gap.dart` - Spacing widgets
- `material_symbols_icons/symbols.dart` - Material Symbols icons
- `easy_localization/easy_localization.dart` - Internationalization
- `dio/dio.dart` - HTTP client for API calls
- `solian/models/wallet.dart` - Wallet order model
- `solian/widgets/common/sheet_scaffold.dart` - Sheet scaffold widget
- `solian/pods/network.dart` - API client provider