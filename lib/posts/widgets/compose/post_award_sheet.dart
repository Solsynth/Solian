import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

import 'post_award_history_sheet.dart';

/// Minimum sponsorship bid in golds.
const int _kSponsorMinAmount = 5;

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
    return ProfilePictureWidget(file: null, radius: radius);
  }

  String _getPublisherName() {
    // Handle publisher case
    if (post.publisher != null) {
      return post.publisher!.name;
    }
    // Handle actor case
    if (post.actor != null) {
      return post.actor!.username;
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final awardAmountController = useTextEditingController();
    final sponsorAmountController = useTextEditingController();
    final mode = useState<SupportMode>(SupportMode.award);
    final selectedAttitude = useState<int>(0); // 0 positive, 2 negative

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SheetScaffold(
      titleText: mode.value == SupportMode.sponsor
          ? 'sponsorPost'.tr()
          : 'awardPost'.tr(),
      actions: [
        IconButton(
          tooltip: 'supportViewHistory'.tr(),
          icon: const Icon(Symbols.history),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: () => _openHistory(context, ref, mode.value),
        ),
      ],
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPostPreview(context),
                  const Gap(16),
                  SegmentedButton<SupportMode>(
                    segments: [
                      ButtonSegment<SupportMode>(
                        value: SupportMode.award,
                        label: Text('award'.tr()),
                        icon: const Icon(Symbols.star),
                      ),
                      ButtonSegment<SupportMode>(
                        value: SupportMode.sponsor,
                        label: Text('sponsor'.tr()),
                        icon: const Icon(Symbols.trending_up),
                      ),
                    ],
                    selected: {mode.value},
                    onSelectionChanged: (selection) =>
                        mode.value = selection.first,
                  ),
                  const Gap(16),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: mode.value == SupportMode.sponsor
                    ? _SponsorSummaryCard(
                        key: const ValueKey('sponsor-summary'),
                        postId: post.id,
                        onViewHistory: () => _openHistory(
                          context,
                          ref,
                          SupportMode.sponsor,
                        ),
                      )
                    : _AwardSummaryCard(
                        key: const ValueKey('award-summary'),
                        postId: post.id,
                        onViewHistory: () => _openHistory(
                          context,
                          ref,
                          SupportMode.award,
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: mode.value == SupportMode.sponsor
                    ? _buildSponsorForm(
                        context,
                        ref,
                        colorScheme,
                        sponsorAmountController,
                      )
                    : _buildAwardForm(
                        context,
                        ref,
                        colorScheme,
                        messageController,
                        awardAmountController,
                        selectedAttitude,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openHistory(
    BuildContext context,
    WidgetRef ref,
    SupportMode initialMode,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => PostSupportHistorySheet(
        postId: post.id,
        initialMode: initialMode,
      ),
    ).then((_) {
      // Refresh totals/bids after returning from the history sheet.
      ref.invalidate(postSponsorTotalProvider(post.id));
    });
  }

  Widget _buildAwardForm(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    TextEditingController messageController,
    TextEditingController amountController,
    ValueNotifier<int> selectedAttitude,
  ) {
    return Column(
      key: const ValueKey('award-form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BenefitsCard(
          icon: Symbols.info,
          title: 'awardBenefits'.tr(),
          description: 'awardBenefitsDescription'.tr(),
          accentColor: colorScheme.primary,
          containerColor: colorScheme.primaryContainer.withOpacity(0.3),
        ),
        const Gap(20),
        _FieldLabel(text: 'awardMessage'.tr()),
        const Gap(8),
        TextField(
          controller: messageController,
          maxLines: 3,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'awardMessageHint'.tr(),
            alignLabelWithHint: true,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        const Gap(16),
        _FieldLabel(text: 'awardAttitude'.tr()),
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
          onSelectionChanged: (selection) =>
              selectedAttitude.value = selection.first,
        ),
        const Gap(16),
        _FieldLabel(text: 'awardAmount'.tr()),
        const Gap(8),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'awardAmountHint'.tr(),
            suffixText: 'NSP',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        const Gap(24),
        FilledButton.icon(
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
      ],
    );
  }

  Widget _buildSponsorForm(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    TextEditingController amountController,
  ) {
    return Column(
      key: const ValueKey('sponsor-form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BenefitsCard(
          icon: Symbols.trending_up,
          title: 'sponsorBenefits'.tr(),
          description: 'sponsorBenefitsDescription'.tr(),
          accentColor: colorScheme.tertiary,
          containerColor: colorScheme.tertiaryContainer.withOpacity(0.3),
        ),
        const Gap(20),
        _FieldLabel(text: 'sponsorAmount'.tr()),
        const Gap(8),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'sponsorAmountHint'.tr(),
            helperText: 'sponsorMinAmount'.tr(),
            suffixText: 'walletCurrencyShortGolds'.tr(),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        const Gap(24),
        FilledButton.tonalIcon(
          onPressed: () =>
              _submitSponsor(context, ref, amountController),
          icon: const Icon(Symbols.trending_up),
          label: Text('sponsorSubmit'.tr()),
        ),
      ],
    );
  }

  Widget _buildPostPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.article,
                size: 20,
                color: colorScheme.primary,
              ),
              const Gap(8),
              Text(
                'awardPostPreview'.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                    color: colorScheme.onSurfaceVariant,
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

      final client = ref.read(solarNetworkClientProvider);

      // Send award request (use raw Dio call for award with amount)
      final awardResponse = await client.dio.post(
        '/sphere/posts/${post.id}/awards',
        data: {'amount': amount, if (message.isNotEmpty) 'message': message},
      );

      final orderId = awardResponse.data['order_id'] as String;

      // Fetch order details
      final order = await client.wallet.getOrder(orderId);

      if (context.mounted) {
        hideLoadingModal(context);

        // Show payment overlay
        final paidOrder = await PaymentOverlay.show(
          context: context,
          order: order,
          enableBiometric: true,
        );

        if (paidOrder != null && context.mounted) {
          ref.invalidate(postAwardListNotifierProvider(post.id));
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

  Future<void> _submitSponsor(
    BuildContext context,
    WidgetRef ref,
    TextEditingController amountController,
  ) async {
    final amountText = amountController.text.trim();

    if (amountText.isEmpty) {
      showSnackBar('sponsorAmountRequired'.tr());
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      showSnackBar('sponsorAmountInvalid'.tr());
      return;
    }

    if (amount < _kSponsorMinAmount) {
      showSnackBar('sponsorMinAmount'.tr());
      return;
    }

    try {
      showLoadingModal(context);

      final client = ref.read(solarNetworkClientProvider);

      // Create a sponsorship bid order (golds).
      final response = await client.dio.post(
        '/sphere/posts/${post.id}/sponsor',
        data: {'amount': amount},
      );

      final orderId = response.data['order_id'] as String;

      // Fetch order details then present the payment overlay.
      final order = await client.wallet.getOrder(orderId);

      if (!context.mounted) return;
      hideLoadingModal(context);

      final paidOrder = await PaymentOverlay.show(
        context: context,
        order: order,
        enableBiometric: true,
      );

      if (paidOrder != null && context.mounted) {
        ref.invalidate(postSponsorTotalProvider(post.id));
        ref.invalidate(postSponsorBidListNotifierProvider(post.id));
        showSnackBar('sponsorSuccess'.tr());
        Navigator.of(context).pop();
      }
    } catch (err) {
      if (context.mounted) {
        hideLoadingModal(context);
        showErrorAlert(err);
      }
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final Color containerColor;

  const _BenefitsCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accentColor),
              const Gap(8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact summary card for the award mode: shows the total award count and
/// offers a shortcut to open the unified history sheet.
class _AwardSummaryCard extends HookConsumerWidget {
  final String postId;
  final VoidCallback onViewHistory;

  const _AwardSummaryCard({
    super.key,
    required this.postId,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awards = ref.watch(postAwardListNotifierProvider(postId));
    final count =
        awards.value?.totalCount ?? awards.value?.items.length ?? 0;

    return _SummaryCard(
      icon: Symbols.star,
      iconColor: Theme.of(context).colorScheme.primary,
      stat: 'awardCount'.tr(args: ['$count']),
      onViewHistory: onViewHistory,
    );
  }
}

/// Compact summary card for the sponsor mode: shows the active sponsorship
/// total (golds) and a shortcut to open the bid history.
class _SponsorSummaryCard extends HookConsumerWidget {
  final String postId;
  final VoidCallback onViewHistory;

  const _SponsorSummaryCard({
    super.key,
    required this.postId,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(postSponsorTotalProvider(postId));

    final value = total.maybeWhen(
      data: (v) => v.toStringAsFixed(0),
      orElse: () => '—',
    );

    return _SummaryCard(
      icon: Symbols.trending_up,
      iconColor: Theme.of(context).colorScheme.tertiary,
      stat: 'sponsorBidAmount'.tr(args: [value]),
      onViewHistory: onViewHistory,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String stat;
  final VoidCallback onViewHistory;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.stat,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              stat,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onViewHistory,
            icon: const Icon(Symbols.history, size: 18),
            label: Text('supportViewHistory'.tr()),
          ),
        ],
      ),
    );
  }
}
