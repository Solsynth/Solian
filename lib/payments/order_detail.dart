import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/route.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/wallets/wallet.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class WalletOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const WalletOrderDetailScreen({
    super.key,
    @PathParam('id') required this.orderId,
  });

  @override
  ConsumerState<WalletOrderDetailScreen> createState() =>
      _WalletOrderDetailScreenState();
}

class _WalletOrderDetailScreenState
    extends ConsumerState<WalletOrderDetailScreen> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openOverlay();
    });
  }

  Future<void> _openOverlay() async {
    if (_handled || !mounted) return;
    _handled = true;

    try {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get('/wallet/orders/${widget.orderId}');
      final data = Map<String, dynamic>.from(response.data as Map);
      final order = SnWalletOrder.fromJson(data);
      final orderInfo = PaymentOverlayOrderInfo.fromJson(data);
      if (!mounted) return;

      final paidOrder = await PaymentOverlay.show(
        context: context,
        order: order,
        orderInfo: orderInfo,
      );
      if (paidOrder != null) {
        ref.invalidate(walletCurrentProvider);
        ref.invalidate(walletListProvider);
        ref.invalidate(walletStatsProvider);
        showSnackBar('paymentSuccess'.tr());
      }
    } catch (err) {
      if (mounted) showErrorAlert(err);
    }

    if (!mounted) return;
    final router = ref.read(routerProvider);
    if (context.router.canPop()) {
      context.router.pop();
    } else {
      router.navigatePath('/wallet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
