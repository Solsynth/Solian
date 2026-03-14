import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'iap_service.g.dart';

class IapService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final _purchaseController = StreamController<IapPurchaseResult>.broadcast();
  String? _userId;

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Stream<IapPurchaseResult> get purchaseResultStream =>
      _purchaseController.stream;

  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        debugPrint('IAP is not available on this platform');
        return;
      }
      _listenToPurchaseStream();
    } catch (e) {
      debugPrint('Failed to check IAP availability: $e');
      _isAvailable = false;
    }
  }

  void _listenToPurchaseStream() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          if (purchase.status == PurchaseStatus.purchased) {
            final transactionId =
                purchase.verificationData.localVerificationData;
            final productId = purchase.productID;

            await completePurchase(purchase);
            _purchaseController.add(
              IapPurchaseResult(
                success: true,
                transactionId: transactionId,
                productId: productId,
              ),
            );
          } else if (purchase.status == PurchaseStatus.restored) {
            final transactionId =
                purchase.verificationData.localVerificationData;
            final productId = purchase.productID;
            final signedTransactionInfo =
                purchase.verificationData.serverVerificationData;

            _purchaseController.add(
              IapPurchaseResult(
                success: true,
                transactionId: transactionId,
                productId: productId,
                signedTransactionInfo: signedTransactionInfo,
                isRestored: true,
              ),
            );
          } else if (purchase.status == PurchaseStatus.error) {
            _purchaseController.add(
              IapPurchaseResult(
                success: false,
                error: purchase.error?.message ?? 'Purchase error',
                productId: purchase.productID,
              ),
            );
          } else if (purchase.status == PurchaseStatus.canceled) {
            _purchaseController.add(
              IapPurchaseResult(
                success: false,
                error: 'Purchase cancelled',
                productId: purchase.productID,
              ),
            );
          }
        }
      },
      onError: (error) {
        _purchaseController.add(
          IapPurchaseResult(success: false, error: error.toString()),
        );
      },
    );
  }

  Future<bool> loadProducts(Set<String> productIds) async {
    if (!_isAvailable) {
      return false;
    }

    try {
      final response = await _inAppPurchase.queryProductDetails(productIds);
      if (response.error == null) {
        _products = response.productDetails;
        return true;
      }
      debugPrint('Error loading products: ${response.error}');
      return false;
    } catch (e) {
      debugPrint('Failed to load products: $e');
      return false;
    }
  }

  Future<IapPurchaseResult?> purchaseProduct(String productId) async {
    if (!_isAvailable) {
      return IapPurchaseResult(success: false, error: 'IAP not available');
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found: $productId'),
    );

    try {
      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: _userId,
      );
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (success) {
        return IapPurchaseResult(success: true, productId: productId);
      }
      return null;
    } catch (e) {
      return IapPurchaseResult(success: false, error: e.toString());
    }
  }

  Future<bool> completePurchase(PurchaseDetails purchase) async {
    try {
      await _inAppPurchase.completePurchase(purchase);
      return true;
    } catch (e) {
      debugPrint('Failed to complete purchase: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
    }
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseController.close();
  }
}

class IapPurchaseResult {
  final bool success;
  final String? error;
  final String? transactionId;
  final String? productId;
  final String? signedTransactionInfo;
  final bool isRestored;

  IapPurchaseResult({
    required this.success,
    this.error,
    this.transactionId,
    this.productId,
    this.signedTransactionInfo,
    this.isRestored = false,
  });
}

@riverpod
IapService iapService(Ref ref) {
  return IapService();
}

@riverpod
Future<void> iapInitialize(Ref ref) async {
  final service = ref.watch(iapServiceProvider);
  await service.initialize();
}

@riverpod
Future<bool> iapLoadProducts(Ref ref, List<String> productIds) async {
  final service = ref.watch(iapServiceProvider);
  return service.loadProducts(productIds.toSet());
}

@riverpod
Stream<List<PurchaseDetails>> iapPurchaseStream(Ref ref) {
  final service = ref.watch(iapServiceProvider);
  return service.purchaseStream;
}

@riverpod
Stream<IapPurchaseResult> iapPurchaseResultStream(Ref ref) {
  final service = ref.watch(iapServiceProvider);
  return service.purchaseResultStream;
}

@riverpod
Future<IapPurchaseResult?> iapPurchase(Ref ref, String productId) async {
  final service = ref.watch(iapServiceProvider);

  try {
    await service.purchaseProduct(productId);
    return null;
  } catch (e) {
    return IapPurchaseResult(success: false, error: e.toString());
  }
}

@riverpod
Future<List<PurchaseDetails>> iapPastPurchases(Ref ref) async {
  return [];
}
