import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class LivestreamAwardSheet extends HookConsumerWidget {
  final SnLiveStream livestream;
  const LivestreamAwardSheet({super.key, required this.livestream});

  Widget _buildProfilePicture(BuildContext context, {double radius = 16}) {
    final publisher = livestream.publisher;
    if (publisher != null) {
      return ProfilePictureWidget(file: publisher.picture, radius: radius);
    }
    return ProfilePictureWidget(file: null, radius: radius);
  }

  String _getPublisherName() {
    final publisher = livestream.publisher;
    if (publisher != null) {
      return publisher.name;
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final amountController = useTextEditingController();

    return SheetScaffold(
      titleText: 'awardLivestream'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLivestreamPreview(context),
            const Gap(20),
            _buildAwardResultExplanation(context),
            const Gap(20),
            Text(
              'awardMessage'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(8),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'awardMessageHint'.tr(),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            const Gap(16),
            Text(
              'awardAmount'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'awardAmountHint'.tr(),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                suffixText: 'NSP',
              ),
            ),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _submitAward(
                  context,
                  ref,
                  messageController,
                  amountController,
                ),
                icon: const Icon(Symbols.star),
                label: Text('awardSubmit'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivestreamPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.live_tv,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(8),
              Text(
                'awardLivestreamPreview'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Gap(8),
          Text(
            livestream.title ?? 'awardNoTitle'.tr(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(4),
          Row(
            spacing: 6,
            children: [
              Text(
                'awardByPublisher'.tr(args: ['@${_getPublisherName()}']),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              _buildProfilePicture(context, radius: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAwardResultExplanation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.info,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(8),
              Text(
                'awardBenefits'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'awardBenefitsDescription'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAward(
    BuildContext context,
    WidgetRef ref,
    TextEditingController messageController,
    TextEditingController amountController,
  ) async {
    final message = messageController.text.trim();
    final amountText = amountController.text.trim();

    if (amountText.isEmpty) {
      showSnackBar('awardAmountRequired'.tr());
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      showSnackBar('awardAmountInvalid'.tr());
      return;
    }

    if (message.length > 4096) {
      showSnackBar('awardMessageTooLong'.tr());
      return;
    }

    try {
      showLoadingModal(context);

      final client = ref.read(apiClientProvider);

      final awardResponse = await client.post(
        '/sphere/livestreams/${livestream.id}/awards',
        data: {'amount': amount, if (message.isNotEmpty) 'message': message},
      );

      final orderId = awardResponse.data['order_id'] as String;

      final orderResponse = await client.get('/wallet/orders/$orderId');
      final order = SnWalletOrder.fromJson(orderResponse.data);

      if (context.mounted) {
        hideLoadingModal(context);

        final paidOrder = await PaymentOverlay.show(
          context: context,
          order: order,
          enableBiometric: true,
        );

        if (paidOrder != null && context.mounted) {
          showSnackBar('awardSuccess'.tr());
          Navigator.of(context).pop();
        }
      }
    } catch (err) {
      if (context.mounted) {
        hideLoadingModal(context);
        showErrorAlert(err);
      }
    }
  }
}
