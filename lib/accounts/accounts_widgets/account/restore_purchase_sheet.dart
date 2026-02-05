import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account/me/settings_connections.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:styled_widget/styled_widget.dart';

class RestorePurchaseSheet extends HookConsumerWidget {
  const RestorePurchaseSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProvider = useState<String?>(null);
    final orderIdController = useTextEditingController();
    final isLoading = useState(false);

    final providers = ['afdian'];

    Future<void> restorePurchase() async {
      if (selectedProvider.value == null ||
          orderIdController.text.trim().isEmpty) {
        showErrorAlert('Please fill in all fields');
        return;
      }

      isLoading.value = true;
      try {
        final client = ref.read(apiClientProvider);
        await client.post(
          '/wallet/subscriptions/order/restore/${selectedProvider.value!}',
          data: {'order_id': orderIdController.text.trim()},
        );

        if (context.mounted) {
          Navigator.pop(context);
          showSnackBar('Purchase restored successfully!');
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoading.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'restorePurchase'.tr(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'restorePurchaseDescription'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(24),

            // Provider Selection
            Text(
              'provider'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedProvider.value,
                  hint: Text('selectProvider'.tr()),
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: providers.map((provider) {
                    return DropdownMenuItem<String>(
                      value: provider,
                      child: Row(
                        children: [
                          getProviderIcon(
                            provider,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const Gap(12),
                          Text(getLocalizedProviderName(provider)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedProvider.value = value;
                  },
                ),
              ),
            ),
            const Gap(16),

            // Order ID Input
            Text(
              'orderId'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(8),
            TextField(
              controller: orderIdController,
              decoration: InputDecoration(
                hintText: 'enterOrderId'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const Gap(24),

            // Restore Button
            FilledButton(
              onPressed: isLoading.value ? null : restorePurchase,
              child: isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('restore'.tr()),
            ),
            const Gap(16),
          ],
        ).padding(all: 16),
      ),
    );
  }
}
