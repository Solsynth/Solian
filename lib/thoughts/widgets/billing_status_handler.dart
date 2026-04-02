import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// A widget that handles billing status and displays a banner when there are unpaid orders.
///
/// Wraps the child widget and shows a billing error banner at the top when
/// the user has unpaid orders, with a retry button to settle the payment.
class BillingStatusHandler extends HookConsumerWidget {
  /// The widget to display when billing status is OK or still loading
  final Widget child;

  /// Async value containing the billing status
  final AsyncValue<bool> statusAsync;

  /// Callback to invalidate/refresh the billing status provider
  final VoidCallback onRefreshStatus;

  /// Whether to show the child even when status is loading
  final bool showChildWhileLoading;

  const BillingStatusHandler({
    super.key,
    required this.child,
    required this.statusAsync,
    required this.onRefreshStatus,
    this.showChildWhileLoading = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return statusAsync.maybeWhen(
      data: (status) {
        final retry = useMemoized(
          () => () async {
            showLoadingModal(context);
            try {
              await ref
                  .read(solarNetworkClientProvider)
                  .dio
                  .post('/insight/billing/retry');
              showSnackBar('Retried billing process');
              onRefreshStatus();
            } catch (e) {
              showSnackBar('Failed to retry billing');
            }
            if (context.mounted) hideLoadingModal(context);
          },
          [context, ref],
        );

        return status
            ? child
            : Column(
                children: [
                  MaterialBanner(
                    leading: const Icon(Symbols.error),
                    content: Text(
                      'thoughtUnpaidBanner'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      TextButton(onPressed: retry, child: Text('retry'.tr())),
                    ],
                  ),
                  Expanded(child: child),
                ],
              );
      },
      orElse: () => showChildWhileLoading
          ? child
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
