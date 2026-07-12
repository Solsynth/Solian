import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/core/network.dart';
import 'package:dio/dio.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:island/developers/models/custom_app.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/wallets/pin_status.dart';
import 'package:styled_widget/styled_widget.dart';

class PaymentOverlayOrderInfo {
  final String? productIdentifier;
  final PaymentOverlayOrderApp? app;
  final PaymentOverlayOrderDeveloper? developer;
  final List<PaymentOverlayOrderItem> items;

  const PaymentOverlayOrderInfo({
    this.productIdentifier,
    this.app,
    this.developer,
    this.items = const [],
  });

  factory PaymentOverlayOrderInfo.fromJson(Map<String, dynamic> json) {
    return PaymentOverlayOrderInfo(
      productIdentifier:
          json['productIdentifier'] as String? ??
          json['product_identifier'] as String?,
      app: json['app'] is Map
          ? PaymentOverlayOrderApp.fromJson(
              Map<String, dynamic>.from(json['app'] as Map),
            )
          : null,
      developer: json['developer'] is Map
          ? PaymentOverlayOrderDeveloper.fromJson(
              Map<String, dynamic>.from(json['developer'] as Map),
            )
          : null,
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => PaymentOverlayOrderItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}

class PaymentOverlayOrderApp {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final SnCloudFileReference? picture;
  final SnCloudFileReference? background;

  const PaymentOverlayOrderApp({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.picture,
    required this.background,
  });

  factory PaymentOverlayOrderApp.fromJson(Map<String, dynamic> json) {
    return PaymentOverlayOrderApp(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      picture: json['picture'] is Map
          ? SnCloudFileReference.fromJson(
              Map<String, dynamic>.from(json['picture'] as Map),
            )
          : null,
      background: json['background'] is Map
          ? SnCloudFileReference.fromJson(
              Map<String, dynamic>.from(json['background'] as Map),
            )
          : null,
    );
  }
}

class PaymentOverlayOrderDeveloper {
  final String id;
  final String publisherId;
  final String publisherName;

  const PaymentOverlayOrderDeveloper({
    required this.id,
    required this.publisherId,
    required this.publisherName,
  });

  factory PaymentOverlayOrderDeveloper.fromJson(Map<String, dynamic> json) {
    return PaymentOverlayOrderDeveloper(
      id: json['id'] as String? ?? '',
      publisherId:
          json['publisherId'] as String? ??
          json['publisher_id'] as String? ??
          '',
      publisherName:
          json['publisherName'] as String? ??
          json['publisher_name'] as String? ??
          '',
    );
  }
}

class PaymentOverlayOrderItem {
  final String productIdentifier;
  final int quantity;
  final int unitPrice;
  final String currency;

  const PaymentOverlayOrderItem({
    required this.productIdentifier,
    required this.quantity,
    required this.unitPrice,
    required this.currency,
  });

  factory PaymentOverlayOrderItem.fromJson(Map<String, dynamic> json) {
    return PaymentOverlayOrderItem(
      productIdentifier:
          json['productIdentifier'] as String? ??
          json['product_identifier'] as String? ??
          '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice:
          (json['unitPrice'] as num?)?.toInt() ??
          (json['unit_price'] as num?)?.toInt() ??
          0,
      currency: json['currency'] as String? ?? '',
    );
  }
}

class PaymentOverlayAppProduct {
  final String id;
  final String identifier;
  final String? displayName;
  final String? description;
  final String currency;
  final int price;
  final SnCloudFileReference? picture;

  const PaymentOverlayAppProduct({
    required this.id,
    required this.identifier,
    required this.displayName,
    required this.description,
    required this.currency,
    required this.price,
    required this.picture,
  });

  factory PaymentOverlayAppProduct.fromJson(Map<String, dynamic> json) {
    return PaymentOverlayAppProduct(
      id: json['id'] as String? ?? '',
      identifier: json['identifier'] as String? ?? '',
      displayName:
          json['display_name'] as String? ?? json['displayName'] as String?,
      description: json['description'] as String?,
      currency: json['currency'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      picture: json['picture'] is Map
          ? SnCloudFileReference.fromJson(
              Map<String, dynamic>.from(json['picture'] as Map),
            )
          : null,
    );
  }
}

class PaymentOverlay extends HookConsumerWidget {
  final SnWalletOrder order;
  final PaymentOverlayOrderInfo? orderInfo;
  final String? payerWalletId;
  final Function(SnWalletOrder completedOrder)? onPaymentSuccess;
  final Function(String error)? onPaymentError;
  final VoidCallback? onCancel;
  final bool enableBiometric;

  const PaymentOverlay({
    super.key,
    required this.order,
    this.orderInfo,
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
            orderInfo: orderInfo,
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
    PaymentOverlayOrderInfo? orderInfo,
    String? payerWalletId,
    bool enableBiometric = true,
  }) {
    return showModalBottomSheet<SnWalletOrder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => PaymentOverlay(
        order: order,
        orderInfo: orderInfo,
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
  final PaymentOverlayOrderInfo? orderInfo;
  final String? payerWalletId;
  final Function(SnWalletOrder)? onPaymentSuccess;
  final Function(String)? onPaymentError;
  final VoidCallback? onCancel;
  final bool enableBiometric;

  const _PaymentContent({
    required this.order,
    this.orderInfo,
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
  bool _isInitializingAuth = true;
  bool _requiresPinValidation = true;
  bool _hasBiometricSupport = false;
  bool _hasStoredPin = false;
  SnPublisher? _publisher;
  CustomApp? _appDetails;
  List<PaymentOverlayAppProduct> _products = const [];

  bool get _isOrderExpired => widget.order.expiredAt.isBefore(DateTime.now());
  bool get _isOrderPayable => widget.order.status == 0 && !_isOrderExpired;

  @override
  void initState() {
    super.initState();
    if (!_isOrderPayable) {
      _isInitializingAuth = false;
    } else {
      _initializeBiometric();
    }
    _loadEnrichment();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeBiometric() async {
    try {
      final pinStatus = await fetchWalletPinStatus(ref);
      _requiresPinValidation = pinStatus.validationRequired;

      if (!_requiresPinValidation) {
        _hasBiometricSupport = false;
        _hasStoredPin = false;
        _isPinMode = false;
        _isInitializingAuth = false;
        if (mounted) {
          setState(() {});
        }
        return;
      }

      final isAvailable = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      _hasBiometricSupport = isAvailable && canCheckBiometrics;

      final storedPin = await _secureStorage.read(key: _pinStorageKey);
      _hasStoredPin = storedPin != null && storedPin.isNotEmpty;

      if (_hasStoredPin && _hasBiometricSupport && widget.enableBiometric) {
        _isPinMode = false;
      } else {
        _isPinMode = true;
      }

      _isInitializingAuth = false;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _isPinMode = true;
      _isInitializingAuth = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadEnrichment() async {
    final appSlug = widget.orderInfo?.app?.slug;
    final publisherName = widget.orderInfo?.developer?.publisherName;
    if ((appSlug == null || appSlug.isEmpty) &&
        (publisherName == null || publisherName.isEmpty)) {
      return;
    }

    try {
      final client = ref.read(solarNetworkClientProvider);
      final results = await Future.wait<dynamic>([
        if (publisherName != null && publisherName.isNotEmpty)
          client.sphere.getPublisher(publisherName)
        else
          Future<SnPublisher?>.value(null),
        if (appSlug != null && appSlug.isNotEmpty)
          client.dio.get('/develop/apps/$appSlug')
        else
          Future<Response<dynamic>?>.value(null),
        if (appSlug != null && appSlug.isNotEmpty)
          client.dio.get('/develop/apps/$appSlug/products')
        else
          Future<Response<dynamic>?>.value(null),
      ]);

      final publisher = results[0] as SnPublisher?;
      final appResponse = results[1] as Response<dynamic>?;
      final productsResponse = results[2] as Response<dynamic>?;
      final appDetails = appResponse?.data is Map
          ? CustomApp.fromJson(
              Map<String, dynamic>.from(appResponse!.data as Map),
            )
          : null;
      final products = (productsResponse?.data as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => PaymentOverlayAppProduct.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _publisher = publisher;
        _appDetails = appDetails;
        _products = products;
      });
    } catch (err) {
      Logger.root.log(.SEVERE, 'Order enrichment failed...', err);
      showErrorAlert(err);
      // Ignore enrichment failures.
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
      if (_requiresPinValidation &&
          _hasBiometricSupport &&
          widget.enableBiometric &&
          !_hasStoredPin) {
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

  Future<void> _processPaymentWithoutPin() async {
    showLoadingModal(context);

    try {
      await _makePaymentRequest();
    } catch (err) {
      widget.onPaymentError?.call(err.toString());
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
        final storedPin = await _secureStorage.read(key: _pinStorageKey);
        if (storedPin != null && storedPin.isNotEmpty) {
          await _makePaymentRequest(storedPin);
        } else {
          _fallbackToPinMode('noStoredPin'.tr());
        }
      } else {
        _fallbackToPinMode('biometricAuthFailed'.tr());
      }
    } catch (err) {
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

  Future<void> _makePaymentRequest([String? pin]) async {
    try {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.post(
        '/wallet/orders/${widget.order.id}/pay',
        data: {
          'pin_code': pin,
          if (widget.payerWalletId != null)
            'payer_wallet_id': widget.payerWalletId,
        },
      );

      final completedOrder = SnWalletOrder.fromJson(response.data);
      widget.onPaymentSuccess?.call(completedOrder);
    } catch (err) {
      String errorMessage = 'paymentFailed'.tr();
      if (err is DioException) {
        if (err.response?.statusCode == 403 ||
            err.response?.statusCode == 401) {
          errorMessage = 'invalidPin'.tr();
          if (_requiresPinValidation && !_isPinMode) {
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

  String _formatProductIdentifier(String value) {
    final parts = value.split('.');
    return parts.isNotEmpty ? parts.last : value;
  }

  PaymentOverlayAppProduct? _findProduct(PaymentOverlayOrderItem item) {
    final parts = item.productIdentifier.split('.');
    final identifier = parts.isNotEmpty ? parts.last : item.productIdentifier;
    for (final product in _products) {
      if (product.identifier == identifier ||
          product.identifier == item.productIdentifier) {
        return product;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasAppId = widget.orderInfo?.app?.id.isNotEmpty == true;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasAppId) _buildContextInfoCard(),
                    if (widget.orderInfo?.items.isNotEmpty ?? false) ...[
                      if (hasAppId) const Gap(16),
                      _buildItemsCard(),
                    ],
                    const Gap(16),
                    _buildOrderSummary(),
                    const Gap(24),
                    _buildAuthenticationContent(),
                  ],
                ),
              ),
            ),
            const Gap(16),
            _buildActionButtons(),
          ],
        ),
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
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'orderId'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Flexible(
                  child: Text(
                    widget.order.id,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'expired'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  DateFormat.yMd().add_Hm().format(widget.order.expiredAt),
                  style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildContextInfoCard() {
    final app = _appDetails;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (_publisher?.background != null || _appDetails?.background != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.18,
                child: CloudImageWidget(
                  file: _appDetails?.background ?? _publisher?.background,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfilePictureWidget(
                      file: _appDetails?.picture,
                      fallbackIcon: Symbols.apps,
                      borderRadius: 8,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (app != null || widget.orderInfo?.app != null) ...[
                            Text(
                              app?.name ?? widget.orderInfo!.app!.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if ((app?.slug ?? widget.orderInfo?.app?.slug ?? '')
                                .isNotEmpty)
                              Text(
                                app?.slug ?? widget.orderInfo!.app!.slug,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                          ],
                          const Gap(4),
                          Row(
                            spacing: 4,
                            children: [
                              Text(
                                'from',
                                style: TextStyle(fontSize: 11),
                              ).opacity(0.8),
                              ProfilePictureWidget(
                                file: _publisher?.picture,
                                radius: 8,
                              ),
                              Text(
                                _publisher?.nick ?? 'unknown'.tr(),
                                style: TextStyle(fontSize: 11),
                              ).opacity(0.8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_appDetails?.description?.isNotEmpty ?? false) ...[
                  const Gap(12),
                  Text(
                    _appDetails!.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.orderInfo!.items.map((item) {
              final product = _findProduct(item);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: product?.picture != null
                          ? CloudFileWidget(
                              item: product!.picture!,
                              noBlurhash: true,
                            )
                          : Icon(
                              Symbols.package_2,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.displayName?.trim().isNotEmpty == true
                                ? product!.displayName!
                                : _formatProductIdentifier(
                                    item.productIdentifier,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Gap(2),
                          if (product?.description?.trim().isNotEmpty == true)
                            Text(
                              product!.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          Text(
                            '${item.quantity} × ${_formatCurrency(item.unitPrice, item.currency)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatCurrency(
                        item.unitPrice * item.quantity,
                        item.currency,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationContent() {
    if (!_isOrderPayable) {
      return _buildOrderStateContent();
    }

    if (_isInitializingAuth) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_requiresPinValidation) {
      return _buildNoPinConfirmation();
    }

    return _isPinMode ? _buildPinInput() : _buildBiometricAuth();
  }

  Widget _buildOrderStateContent() {
    final colorScheme = Theme.of(context).colorScheme;
    final (IconData icon, String message) = switch (widget.order.status) {
      1 => (Symbols.check_circle, 'paymentSuccess'.tr()),
      2 => (Symbols.task_alt, 'completed'.tr()),
      3 => (Symbols.cancel, 'cancelled'.tr()),
      _ => (Symbols.schedule, 'expired'.tr()),
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: colorScheme.primary),
          const Gap(16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPinInput() {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
    );

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
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyDecorationWith(
            border: Border.all(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          submittedPinTheme: defaultPinTheme.copyDecorationWith(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          onSubmitted: _onPinSubmit,
          onChanged: (String code) {
            _pin = code;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildNoPinConfirmation() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.verified_user, size: 48, color: colorScheme.primary),
          const Gap(16),
          Text(
            'paymentSummary'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            'paymentNoPinRequired'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricAuth() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            child: Text(_isOrderPayable ? 'cancel'.tr() : 'close'.tr()),
          ),
        ),
        if (_isOrderPayable &&
            !_isInitializingAuth &&
            !_requiresPinValidation) ...[
          const Gap(12),
          Expanded(
            child: FilledButton(
              onPressed: _processPaymentWithoutPin,
              child: Text('confirm'.tr()),
            ),
          ),
        ],
        if (_isOrderPayable && _isPinMode && _pin.length == 6) ...[
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
