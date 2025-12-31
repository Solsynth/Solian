import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/models/wallet.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/payment/payment_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';

class PostAwardSheet extends HookConsumerWidget {
  final SnPost post;
  const PostAwardSheet({super.key, required this.post});

  Widget _buildProfilePicture(BuildContext context, {double radius = 16}) {
    // Handle publisher case
    if (post.publisher != null) {
      return ProfilePictureWidget(
        file:
            post.publisher!.picture ?? post.publisher!.account?.profile.picture,
        radius: radius,
      );
    }
    // Handle actor case
    if (post.actor != null) {
      final avatarUrl = post.actor!.avatarUrl;
      if (avatarUrl != null) {
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Symbols.account_circle,
                  size: radius,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              },
            ),
          ),
        );
      }
    }
    // Fallback
    return ProfilePictureWidget(fileId: null, radius: radius);
  }

  String _getPublisherName() {
    // Handle publisher case
    if (post.publisher != null) {
      return post.publisher!.name;
    }
    // Handle actor case
    if (post.actor != null) {
      return post.actor!.username ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final amountController = useTextEditingController();
    final selectedAttitude = useState<int>(0); // 0 for positive, 2 for negative

    return SheetScaffold(
      titleText: 'awardPost'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Post Preview Section
            _buildPostPreview(context),
            const Gap(20),

            // Award Result Explanation
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
              'awardAttitude'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: 0,
                  label: Text('awardAttitudePositive'.tr()),
                  icon: const Icon(Symbols.thumb_up),
                ),
                ButtonSegment<int>(
                  value: 2,
                  label: Text('awardAttitudeNegative'.tr()),
                  icon: const Icon(Symbols.thumb_down),
                ),
              ],
              selected: {selectedAttitude.value},
              onSelectionChanged: (Set<int> selection) {
                selectedAttitude.value = selection.first;
              },
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
                  selectedAttitude.value,
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

  Widget _buildPostPreview(BuildContext context) {
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
                Symbols.article,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(8),
              Text(
                'awardPostPreview'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Gap(8),
          Text(
            post.content ?? 'awardNoContent'.tr(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ...[
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
    int selectedAttitude,
  ) async {
    // Get values from controllers
    final message = messageController.text.trim();
    final amountText = amountController.text.trim();

    // Validate inputs
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

      // Send award request
      final awardResponse = await client.post(
        '/sphere/posts/${post.id}/awards',
        data: {
          'amount': amount,
          'attitude': selectedAttitude,
          if (message.isNotEmpty) 'message': message,
        },
      );

      final orderId = awardResponse.data['order_id'] as String;

      // Fetch order details
      final orderResponse = await client.get('/pass/orders/$orderId');
      final order = SnWalletOrder.fromJson(orderResponse.data);

      if (context.mounted) {
        hideLoadingModal(context);

        // Show payment overlay
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
