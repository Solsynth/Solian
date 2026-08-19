import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
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
        fallbackName: post.publisher!.nick,
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

    final colorScheme = Theme.of(context).colorScheme;

    return SheetScaffold(
      title: _SupportSheetTitle(
        icon: mode.value == SupportMode.sponsor
            ? Symbols.trending_up
            : Symbols.star,
        title: mode.value == SupportMode.sponsor
            ? 'sponsorPost'.tr()
            : 'awardPost'.tr(),
        accent: mode.value == SupportMode.sponsor
            ? colorScheme.tertiary
            : colorScheme.primary,
      ),
      heightFactor: 0.92,
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPostPreview(context),
                const Gap(16),
                _SupportModeSwitcher(
                  value: mode.value,
                  onChanged: (value) => mode.value = value,
                ),
                const Gap(16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: mode.value == SupportMode.sponsor
                      ? _SponsorSummaryCard(
                          key: const ValueKey('sponsor-summary'),
                          postId: post.id,
                          onViewHistory: () =>
                              _openHistory(context, ref, SupportMode.sponsor),
                        )
                      : _AwardSummaryCard(
                          key: const ValueKey('award-summary'),
                          postId: post.id,
                          onViewHistory: () =>
                              _openHistory(context, ref, SupportMode.award),
                        ),
                ),
                const Gap(12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
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
              ]),
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
      builder: (_) =>
          PostSupportHistorySheet(postId: post.id, initialMode: initialMode),
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
        _FieldLabel(text: 'awardMessage'.tr()),
        const Gap(8),
        TextField(
          controller: messageController,
          maxLines: 3,
          textInputAction: TextInputAction.newline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'awardMessageHint'.tr(),
            alignLabelWithHint: true,
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
        const Gap(20),
        _FieldLabel(text: 'awardAttitude'.tr()),
        const Gap(8),
        _AttitudeSelector(
          selectedAttitude: selectedAttitude.value,
          onChanged: (value) => selectedAttitude.value = value,
        ),
        const Gap(16),
        _FieldLabel(text: 'awardAmount'.tr()),
        const Gap(8),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'awardAmountHint'.tr(),
            suffixText: 'Bits',
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
        const Gap(16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
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
        _FieldLabel(text: 'sponsorAmount'.tr()),
        const Gap(8),
        TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'sponsorAmountHint'.tr(),
            helperText: 'sponsorMinAmount'.tr(),
            suffixText: 'walletCurrencyShortGolds'.tr(),
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
        const Gap(16),
        FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => _submitSponsor(context, ref, amountController),
          icon: const Icon(Symbols.trending_up),
          label: Text('sponsorSubmit'.tr()),
        ),
      ],
    );
  }

  Widget _buildPostPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.article, size: 18, color: colorScheme.primary),
              const Gap(8),
              Text(
                'awardPostPreview'.tr(),
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Icon(
                Symbols.arrow_outward,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const Gap(12),
          Text(
            post.content ?? 'awardNoContent'.tr(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(
              height: 1.35,
              color: colorScheme.onSurface,
            ),
          ),
          const Gap(12),
          Row(
            children: [
              _buildProfilePicture(context, radius: 10),
              const Gap(8),
              Expanded(
                child: Text(
                  'awardByPublisher'.tr(args: ['@${_getPublisherName()}']),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
          payerWalletId: order.payerWalletId,
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
        payerWalletId: order.payerWalletId,
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

class _SupportSheetTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;

  const _SupportSheetTitle({
    required this.icon,
    required this.title,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: accent),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'supportHistory'.tr(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupportModeSwitcher extends StatelessWidget {
  final SupportMode value;
  final ValueChanged<SupportMode> onChanged;

  const _SupportModeSwitcher({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _SupportModeOption(
            icon: Symbols.star,
            label: 'award'.tr(),
            accent: colorScheme.primary,
            selected: value == SupportMode.award,
            onTap: () => onChanged(SupportMode.award),
          ),
        ),
        const Gap(10),
        Expanded(
          child: _SupportModeOption(
            icon: Symbols.trending_up,
            label: 'sponsor'.tr(),
            accent: colorScheme.tertiary,
            selected: value == SupportMode.sponsor,
            onTap: () => onChanged(SupportMode.sponsor),
          ),
        ),
      ],
    );
  }
}

class _SupportModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _SupportModeOption({
    required this.icon,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? accent.withOpacity(0.14)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withOpacity(0.2)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: selected ? accent : colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected) Icon(Symbols.check, size: 18, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttitudeSelector extends StatelessWidget {
  final int selectedAttitude;
  final ValueChanged<int> onChanged;

  const _AttitudeSelector({
    required this.selectedAttitude,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _AttitudeOption(
            icon: Symbols.thumb_up,
            label: 'awardAttitudePositive'.tr(),
            accent: colorScheme.primary,
            selected: selectedAttitude == 0,
            onTap: () => onChanged(0),
          ),
        ),
        const Gap(10),
        Expanded(
          child: _AttitudeOption(
            icon: Symbols.thumb_down,
            label: 'awardAttitudeNegative'.tr(),
            accent: colorScheme.error,
            selected: selectedAttitude == 2,
            onTap: () => onChanged(2),
          ),
        ),
      ],
    );
  }
}

class _AttitudeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _AttitudeOption({
    required this.icon,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? accent.withOpacity(0.12)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? accent : colorScheme.onSurfaceVariant,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected) Icon(Symbols.check, size: 17, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Gap(8),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
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
    final count = awards.value?.totalCount ?? awards.value?.items.length ?? 0;

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
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              stat,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton.icon(
            onPressed: onViewHistory,
            icon: const Icon(Symbols.history, size: 17),
            label: Text('supportViewHistory'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: iconColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}
