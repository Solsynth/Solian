import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/core/network.dart';
import 'package:dio/dio.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PaymentOverlay extends HookConsumerWidget {
  final SnWalletOrder order;
  final String? payerWalletId;
  final Function(SnWalletOrder completedOrder)? onPaymentSuccess;
  final Function(String error)? onPaymentError;
  final VoidCallback? onCancel;
  final bool enableBiometric;

  const PaymentOverlay({
    super.key,
    required this.order,
    this.payerWalletId,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.onCancel,
    this.enableBiometric = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SheetScaffold(
          titleText: 'Solarpay',
          heightFactor: 0.7,
          child: _PaymentContent(
            order: order,
            payerWalletId: payerWalletId,
            onPaymentSuccess: onPaymentSuccess,
            onPaymentError: onPaymentError,
            onCancel: onCancel,
            enableBiometric: enableBiometric,
          ),
        ),
      ),
    );
  }

  static Future<SnWalletOrder?> show({
    required BuildContext context,
    required SnWalletOrder order,
    String? payerWalletId,
    bool enableBiometric = true,
  }) {
    return showModalBottomSheet<SnWalletOrder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => PaymentOverlay(
        order: order,
        payerWalletId: payerWalletId,
        enableBiometric: enableBiometric,
        onPaymentSuccess: (completedOrder) {
          Navigator.of(context).pop(completedOrder);
        },
        onPaymentError: (err) {
          Navigator.of(context).pop();
          showErrorAlert(err);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _PaymentContent extends ConsumerStatefulWidget {
  final SnWalletOrder order;
  final String? payerWalletId;
  final Function(SnWalletOrder)? onPaymentSuccess;
  final Function(String)? onPaymentError;
  final VoidCallback? onCancel;
  final bool enableBiometric;

  const _PaymentContent({
    required this.order,
    this.payerWalletId,
    this.onPaymentSuccess,
    this.onPaymentError,
    this.onCancel,
    this.enableBiometric = true,
  });

  @override
  ConsumerState<_PaymentContent> createState() => _PaymentContentState();
}

class _PaymentContentState extends ConsumerState<_PaymentContent> {
  static const String _pinStorageKey = 'app_pin_code';
  static final _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();

  String _pin = '';
  bool _isPinMode = true;
  bool _hasBiometricSupport = false;
  bool _hasStoredPin = false;

  @override
  void initState() {
    super.initState();
    _initializeBiometric();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeBiometric() async {
    try {
      // Check if biometric is available
      final isAvailable = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      _hasBiometricSupport = isAvailable && canCheckBiometrics;

      // Check if PIN is stored
      final storedPin = await _secureStorage.read(key: _pinStorageKey);
      _hasStoredPin = storedPin != null && storedPin.isNotEmpty;

      // Set initial mode based on stored PIN and biometric support
      if (_hasStoredPin && _hasBiometricSupport && widget.enableBiometric) {
        _isPinMode = false;
      } else {
        _isPinMode = true;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Fallback to PIN mode if biometric setup fails
      _isPinMode = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onPinSubmit(String pin) {
    _pin = pin;
    if (pin.length == 6) {
      _processPaymentWithPin(pin);
    }
  }

  Future<void> _processPaymentWithPin(String pin) async {
    showLoadingModal(context);

    try {
      // Store PIN securely for future biometric authentication
      if (_hasBiometricSupport && widget.enableBiometric && !_hasStoredPin) {
        await _secureStorage.write(key: _pinStorageKey, value: pin);
        _hasStoredPin = true;
      }

      await _makePaymentRequest(pin);
    } catch (err) {
      widget.onPaymentError?.call(err.toString());
      _pin = '';
    } finally {
      if (mounted) {
        hideLoadingModal(context);
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    showLoadingModal(context);

    try {
      // Perform biometric authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'biometricPrompt'.tr(),
        biometricOnly: true,
      );

      if (didAuthenticate) {
        // Retrieve stored PIN and process payment
        final storedPin = await _secureStorage.read(key: _pinStorageKey);
        if (storedPin != null && storedPin.isNotEmpty) {
          await _makePaymentRequest(storedPin);
        } else {
          // Fallback to PIN mode if no stored PIN
          _fallbackToPinMode('noStoredPin'.tr());
        }
      } else {
        // Biometric authentication failed, fallback to PIN mode
        _fallbackToPinMode('biometricAuthFailed'.tr());
      }
    } catch (err) {
      // Handle biometric authentication errors
      String errorMessage = 'biometricAuthFailed'.tr();
      if (err is PlatformException) {
        switch (err.code) {
          case 'NotAvailable':
            errorMessage = 'biometricNotAvailable'.tr();
            break;
          case 'NotEnrolled':
            errorMessage = 'biometricNotEnrolled'.tr();
            break;
          case 'LockedOut':
          case 'PermanentlyLockedOut':
            errorMessage = 'biometricLockedOut'.tr();
            break;
          default:
            errorMessage = 'biometricAuthFailed'.tr();
        }
      }
      _fallbackToPinMode(errorMessage);
    } finally {
      if (mounted) {
        hideLoadingModal(context);
      }
    }
  }

  /// Unified method for making payment requests with PIN
  Future<void> _makePaymentRequest(String pin) async {
    try {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.post(
        '/wallet/orders/${widget.order.id}/pay',
        data: {
          'pin_code': pin,
          if (widget.payerWalletId != null) 'payer_wallet_id': widget.payerWalletId,
        },
      );

      final completedOrder = SnWalletOrder.fromJson(response.data);
      widget.onPaymentSuccess?.call(completedOrder);
    } catch (err) {
      String errorMessage = 'paymentFailed'.tr();
      if (err is DioException) {
        if (err.response?.statusCode == 403 ||
            err.response?.statusCode == 401) {
          // PIN is invalid
          errorMessage = 'invalidPin'.tr();
          // If this was a biometric attempt with stored PIN, remove the stored PIN
          if (!_isPinMode) {
            await _secureStorage.delete(key: _pinStorageKey);
            _hasStoredPin = false;
            _fallbackToPinMode(errorMessage);
            return;
          }
        } else if (err.response?.statusCode == 400) {
          errorMessage = err.response?.data?['error'] ?? errorMessage;
        } else {
          rethrow;
        }
      }
      throw errorMessage;
    }
  }

  void _fallbackToPinMode(String? message) {
    setState(() {
      _isPinMode = true;
    });
    if (message != null && message.isNotEmpty) {
      showSnackBar(message);
    }
  }

  String _formatCurrency(int amount, String currency) {
    final value = amount;
    return '${value.toStringAsFixed(2)} $currency';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order Summary
          _buildOrderSummary(),
          const Gap(32),

          // Authentication Content
          Expanded(
            child: _isPinMode ? _buildPinInput() : _buildBiometricAuth(),
          ),

          // Action Buttons
          const Gap(24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.receipt, color: colorScheme.primary),
                const Gap(8),
                Text(
                  'paymentSummary'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'amount'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _formatCurrency(widget.order.amount, widget.order.currency),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (widget.order.remarks != null) ...[
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'description'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.order.remarks!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPinInput() {
    return Column(
      children: [
        Text(
          'enterPinToConfirmPayment'.tr(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const Gap(24),
        Pinput(
          length: 6,
          obscureText: true,
          keyboardType: TextInputType.number,
          onSubmitted: _onPinSubmit,
          onChanged: (String code) {
            _pin = code;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildBiometricAuth() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Symbols.fingerprint, size: 48, color: colorScheme.primary),
            const Gap(16),
            Text(
              'useBiometricToConfirm'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const Gap(4),
            Text(
              'The biometric data will only be processed on your device',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(28),
            FilledButton.tonalIcon(
              onPressed: _authenticateWithBiometric,
              icon: const Icon(Symbols.fingerprint),
              label: Text('authenticateNow'.tr()),
            ),
            TextButton(
              onPressed: () => _fallbackToPinMode(null),
              child: Text('usePinInstead'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            child: Text('cancel'.tr()),
          ),
        ),
        if (_isPinMode && _pin.length == 6) ...[
          const Gap(12),
          Expanded(
            child: FilledButton(
              onPressed: () => _processPaymentWithPin(_pin),
              child: Text('confirm'.tr()),
            ),
          ),
        ],
      ],
    );
  }
}
