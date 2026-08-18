import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/api_error.dart';
import 'package:island/creators/screens/publishers_form.dart'
    show publishersManagedProvider;
import 'package:island/payments/payment_overlay.dart';
import 'package:island/realms/screens/realms.dart' show realmsJoinedProvider;
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Price of one name change card, in points.
const int kNameChangeCardPrice = 100;

/// The account's name change card purchases.
///
/// Refreshed after purchase, payment, and use; the client reads this to
/// observe fulfilled (`isFulfilled`) and consumed (`isConsumed`) state.
final nameChangeCardsProvider = FutureProvider<List<SnNameChangeCardPurchase>>((
  ref,
) {
  return ref.read(solarNetworkClientProvider).accounts.listNameChangeCards();
});

/// Opens the name change card sheet from any entry point.
Future<void> showNameChangeCardSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const NameChangeCardSheet(),
  );
}

/// Bottom sheet for buying, viewing, and spending name change cards.
///
/// Flow: order (`POST /accounts/me/name-change-card/order`) → pay via the
/// existing Wallet [PaymentOverlay] → poll until `fulfilled_at` is set →
/// use the card (`POST /accounts/me/name-change-card/use`). A failed use
/// never consumes the card, so the user can retry with a different name.
class NameChangeCardSheet extends ConsumerStatefulWidget {
  const NameChangeCardSheet({super.key});

  @override
  ConsumerState<NameChangeCardSheet> createState() =>
      _NameChangeCardSheetState();
}

class _NameChangeCardSheetState extends ConsumerState<NameChangeCardSheet> {
  bool _purchasing = false;

  Future<void> _purchase() async {
    final confirm = await showConfirmAlert(
      'nameChangeCardPurchaseConfirmMessage'.tr(
        namedArgs: {'price': '$kNameChangeCardPrice'},
      ),
      'nameChangeCardPurchaseConfirmTitle'.tr(),
    );
    if (!confirm || !mounted) return;

    setState(() => _purchasing = true);
    try {
      final client = ref.read(solarNetworkClientProvider);
      final created = await client.accounts.orderNameChangeCard();

      SnWalletOrder order;
      try {
        order = (await client.wallet.getOrder(
          created.orderId,
        )).copyWith(amount: created.amount);
      } catch (_) {
        // Order not yet visible in Wallet; synthesize from the creation
        // response so payment can still proceed. Unpaid orders expire in
        // Wallet after 24h, matching the server-side default.
        final now = DateTime.now();
        order = SnWalletOrder(
          id: created.orderId,
          status: 0,
          currency: 'points',
          remarks: null,
          appIdentifier: '',
          meta: const {},
          amount: created.amount,
          expiredAt: now.add(const Duration(hours: 24)),
          payerWalletId: null,
          payeeWalletId: null,
          transactionId: null,
          issuerAppId: null,
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
        );
      }

      if (!mounted) return;
      final paidOrder = await PaymentOverlay.show(
        context: context,
        order: order,
        payerWalletId: order.payerWalletId,
        enableBiometric: true,
      );
      if (paidOrder == null || !mounted) return;

      // The card becomes usable once the Wallet payment event fulfills it;
      // poll briefly, then fall back to a refresh-driven update.
      for (var i = 0; i < 20; i++) {
        final cards = await client.accounts.listNameChangeCards();
        if (cards.any((c) => c.orderId == created.orderId && c.isFulfilled)) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (mounted) showSnackBar('nameChangeCardPurchaseSuccess'.tr());
      ref.invalidate(nameChangeCardsProvider);
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _openUseSheet(
    BuildContext context,
    SnNameChangeCardPurchase card,
  ) async {
    final used = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => NameChangeCardUseSheet(purchase: card),
    );
    if (used == true) {
      ref.invalidate(nameChangeCardsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cardsAsync = ref.watch(nameChangeCardsProvider);

    return SheetScaffold(
      titleText: 'nameChangeCardSheetTitle'.tr(),
      heightFactor: 0.85,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildInfoCard(context),
          const Gap(12),
          FilledButton.icon(
            onPressed: _purchasing ? null : _purchase,
            icon: _purchasing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Symbols.add_card),
            label: Text(
              _purchasing ? 'loading'.tr() : 'nameChangeCardPurchase'.tr(),
            ),
          ),
          const Gap(20),
          Text(
            'nameChangeCardHistory'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Gap(8),
          cardsAsync.when(
            data: (cards) => cards.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Symbols.badge, size: 44, color: scheme.outline),
                        const Gap(12),
                        Text(
                          'nameChangeCardNoCards'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      for (final card in cards) ...[
                        _buildPurchaseRow(context, card),
                        const Gap(8),
                      ],
                    ],
                  ),
            error: (err, _) => ResponseErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(nameChangeCardsProvider),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Symbols.badge, color: scheme.primary),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'nameChangeCardPrice'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(2),
                Text(
                  'nameChangeCardCooldownHint'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseRow(
    BuildContext context,
    SnNameChangeCardPurchase card,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isReady = card.isFulfilled && !card.isConsumed;
    final isConsumed = card.isConsumed;

    final Color iconColor;
    final IconData icon;
    final String title;
    final String? subtitle;
    if (isConsumed) {
      icon = Symbols.check_circle;
      iconColor = scheme.outline;
      title = card.oldName != null && card.newName != null
          ? '${card.oldName} → ${card.newName}'
          : 'nameChangeCardConsumed'.tr();
      subtitle = card.targetType != null
          ? _targetLabel(card.targetType!)
          : null;
    } else if (isReady) {
      icon = Symbols.card_membership;
      iconColor = scheme.primary;
      title = 'nameChangeCardReady'.tr();
      subtitle = null;
    } else {
      icon = Symbols.hourglass_empty;
      iconColor = scheme.tertiary;
      title = 'nameChangeCardPendingPayment'.tr();
      subtitle = null;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const Gap(2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isReady)
            FilledButton.tonal(
              onPressed: () => _openUseSheet(context, card),
              child: Text('nameChangeCardUse'.tr()),
            ),
        ],
      ),
    );
  }

  String _targetLabel(SnNameChangeCardTargetType target) {
    return switch (target) {
      SnNameChangeCardTargetType.account => 'nameChangeCardTargetAccount'.tr(),
      SnNameChangeCardTargetType.realm => 'nameChangeCardTargetRealm'.tr(),
      SnNameChangeCardTargetType.publisher =>
        'nameChangeCardTargetPublisher'.tr(),
    };
  }
}

/// Bottom sheet that spends a fulfilled card on a rename.
///
/// A 400 `NAME_CHANGE_CARD_USE_FAILED` is shown inline (message carries the
/// reason: taken name, not owner, invalid target, ...) and the card stays
/// intact, so the user can retry with a different name.
class NameChangeCardUseSheet extends ConsumerStatefulWidget {
  final SnNameChangeCardPurchase purchase;

  const NameChangeCardUseSheet({super.key, required this.purchase});

  @override
  ConsumerState<NameChangeCardUseSheet> createState() =>
      _NameChangeCardUseSheetState();
}

class _NameChangeCardUseSheetState
    extends ConsumerState<NameChangeCardUseSheet> {
  final _nameController = TextEditingController();
  SnNameChangeCardTargetType _target = SnNameChangeCardTargetType.account;
  String? _targetId;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Realms owned by the current user — realm slugs are owner-changeable only.
  List<SnRealm> _ownedRealms() {
    final accountId = ref.read(userInfoProvider).value?.id;
    if (accountId == null) return const [];
    return (ref.read(realmsJoinedProvider).value ?? const <SnRealm>[])
        .where((realm) => realm.accountId == accountId)
        .toList();
  }

  /// Publishers owned by the current user.
  List<SnPublisher> _ownedPublishers() {
    final accountId = ref.read(userInfoProvider).value?.id;
    if (accountId == null) return const [];
    return (ref.read(publishersManagedProvider).value ?? const <SnPublisher>[])
        .where((publisher) => publisher.accountId == accountId)
        .toList();
  }

  List<SnNameChangeCardTargetType> _availableTargets() {
    return [
      SnNameChangeCardTargetType.account,
      if (_ownedRealms().isNotEmpty) SnNameChangeCardTargetType.realm,
      if (_ownedPublishers().isNotEmpty) SnNameChangeCardTargetType.publisher,
    ];
  }

  bool _validateName(String name) {
    return switch (_target) {
      SnNameChangeCardTargetType.account => RegExp(
        r'^[A-Za-z0-9_-]{2,256}$',
      ).hasMatch(name),
      SnNameChangeCardTargetType.realm => name.isNotEmpty,
      SnNameChangeCardTargetType.publisher =>
        name.isNotEmpty && name.length <= 256,
    };
  }

  String _nameHint() {
    return switch (_target) {
      SnNameChangeCardTargetType.account =>
        'nameChangeCardNameHintAccount'.tr(),
      SnNameChangeCardTargetType.realm => 'nameChangeCardNameHintRealm'.tr(),
      SnNameChangeCardTargetType.publisher =>
        'nameChangeCardNameHintPublisher'.tr(),
    };
  }

  String _targetName(SnNameChangeCardTargetType target) {
    return switch (target) {
      SnNameChangeCardTargetType.account => 'nameChangeCardTargetAccount'.tr(),
      SnNameChangeCardTargetType.realm => 'nameChangeCardTargetRealm'.tr(),
      SnNameChangeCardTargetType.publisher =>
        'nameChangeCardTargetPublisher'.tr(),
    };
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (!_validateName(name)) {
      setState(() => _error = 'nameChangeCardInvalidName'.tr());
      return;
    }
    if (_target != SnNameChangeCardTargetType.account && _targetId == null) {
      setState(() => _error = 'nameChangeCardSelectTarget'.tr());
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.accounts.useNameChangeCard(
        target: _target,
        targetId: _targetId,
        newName: name,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
        showSnackBar('nameChangeCardUseSuccess'.tr());
      }
    } catch (err) {
      if (!mounted) return;
      String? message;
      if (err is DioException) {
        message = ApiError.tryParse(err)?.displayMessage;
      }
      setState(() => _error = message ?? 'nameChangeCardUseFailed'.tr());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final realmsAsync = ref.watch(realmsJoinedProvider);
    final publishersAsync = ref.watch(publishersManagedProvider);
    final accountName = ref.watch(userInfoProvider).value?.name;
    final targets = _availableTargets();
    final selectedTarget = targets.contains(_target) ? _target : targets.first;

    return SheetScaffold(
      titleText: 'nameChangeCardRename'.tr(),
      heightFactor: 0.72,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<SnNameChangeCardTargetType>(
              value: selectedTarget,
              decoration: InputDecoration(
                labelText: 'nameChangeCardTarget'.tr(),
              ),
              items: [
                for (final target in targets)
                  DropdownMenuItem(
                    value: target,
                    child: Text(_targetName(target)),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _target = value;
                  _targetId = null;
                  _error = null;
                  _nameController.clear();
                });
              },
            ),
            const Gap(16),
            if (_target == SnNameChangeCardTargetType.realm)
              _buildRealmPicker(realmsAsync),
            if (_target == SnNameChangeCardTargetType.publisher)
              _buildPublisherPicker(publishersAsync),
            const Gap(16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'nameChangeCardNewName'.tr(),
                helperText: _nameHint(),
                errorText: _error,
              ),
            ),
            if (_target == SnNameChangeCardTargetType.account &&
                accountName != null) ...[
              const Gap(8),
              Text(
                'nameChangeCardCurrentName'.tr(
                  namedArgs: {'name': accountName},
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            const Gap(24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('nameChangeCardUse'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealmPicker(AsyncValue<List<SnRealm>> realmsAsync) {
    final realms = _ownedRealms();
    final selected = realms.any((realm) => realm.id == _targetId)
        ? _targetId
        : null;
    return DropdownButtonFormField<String>(
      value: selected,
      decoration: InputDecoration(labelText: 'nameChangeCardSelectRealm'.tr()),
      items: [
        for (final realm in realms)
          DropdownMenuItem(
            value: realm.id,
            child: Text('${realm.name} (@${realm.slug})'),
          ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _targetId = value;
          _error = null;
        });
      },
    );
  }

  Widget _buildPublisherPicker(AsyncValue<List<SnPublisher>> publishersAsync) {
    final publishers = _ownedPublishers();
    final selected = publishers.any((publisher) => publisher.id == _targetId)
        ? _targetId
        : null;
    return DropdownButtonFormField<String>(
      value: selected,
      decoration: InputDecoration(
        labelText: 'nameChangeCardSelectPublisher'.tr(),
      ),
      items: [
        for (final publisher in publishers)
          DropdownMenuItem(
            value: publisher.id,
            child: Text('${publisher.nick} (@${publisher.name})'),
          ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _targetId = value;
          _error = null;
        });
      },
    );
  }
}
