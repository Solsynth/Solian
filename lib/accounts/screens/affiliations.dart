import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/server_compatibility.dart';
import 'package:island/core/services/time.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/wallets/wallet.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final affiliationsNotifierProvider = AsyncNotifierProvider.autoDispose(
  AffiliationsNotifier.new,
);

class AffiliationsNotifier
    extends AsyncNotifier<PaginationState<SnAffiliationSpell>>
    with
        AsyncPaginationController<SnAffiliationSpell>,
        AsyncPaginationFilter<String, SnAffiliationSpell> {
  static const int pageSize = 20;

  @override
  String currentFilter = 'date';

  @override
  FutureOr<PaginationState<SnAffiliationSpell>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnAffiliationSpell>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final result = await client.accounts.listAffiliationSpells(
      order: currentFilter,
      desc: true,
      offset: fetchedCount,
      take: pageSize,
    );

    totalCount = result.totalCount;
    return result.items;
  }
}

@RoutePage()
class AffiliationScreen extends HookConsumerWidget {
  const AffiliationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.watch(affiliationsNotifierProvider.notifier);
    final capabilities = ref.watch(serverCapabilitiesProvider).value;
    // DELETE /api/affiliations/{id} (and create) require the
    // `affiliations.manage` permission. The client has no permission listing,
    // so superuser is the proxy: the server bypasses permission checks for
    // superusers.
    final canManage = ref.watch(userInfoProvider).value?.isSuperuser == true;

    if (!serverFeatureEnabled(capabilities, 'affiliations')) {
      return AppScaffold(
        appBar: AppBar(title: Text('affiliations').tr(), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.block,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'affiliationFeatureUnavailable',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ).tr(),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('affiliations').tr(),
        centerTitle: true,
        scrolledUnderElevation: 4,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Symbols.sort),
            onSelected: (value) {
              notifier.applyFilter(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Text('affiliationSortByDate').tr(),
              ),
              PopupMenuItem(
                value: 'usage',
                child: Text('affiliationSortByUsage').tr(),
              ),
            ],
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showCreateSpellSheet(context, ref, canManage: canManage),
        child: const Icon(Symbols.add),
      ),
      body: PaginationList(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        provider: affiliationsNotifierProvider,
        notifier: affiliationsNotifierProvider.notifier,
        itemBuilder: (context, idx, spell) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.router.push(AffiliationDetailRoute(id: spell.id));
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        spell.isRegistrationInvite
                            ? Symbols.card_giftcard
                            : Symbols.auto_fix_high,
                        color: colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  spell.spell,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (spell.isRegistrationInvite) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'affiliationTypeInvite',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color:
                                              colorScheme.onSecondaryContainer,
                                        ),
                                  ).tr(),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Symbols.schedule,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                spell.createdAt.toLocal().formatSystem(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Symbols.more_vert,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'copy',
                          child: ListTile(
                            leading: const Icon(Symbols.content_copy),
                            title: Text('affiliationCopy').tr(),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (canManage)
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Symbols.delete,
                                color: colorScheme.error,
                              ),
                              title: Text('affiliationDelete').tr(),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                      onSelected: (value) async {
                        if (value == 'copy') {
                          await Clipboard.setData(
                            ClipboardData(text: spell.spell),
                          );
                          if (context.mounted) {
                            showSnackBar('affiliationCopied'.tr());
                          }
                        } else if (value == 'delete') {
                          _confirmDelete(context, ref, spell);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SnAffiliationSpell spell,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('affiliationDelete').tr(),
        content: Text('affiliationDeleteConfirm').tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel').tr(),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final client = ref.read(solarNetworkClientProvider);
                await client.accounts.deleteAffiliationSpell(spell.id);
                ref.invalidate(affiliationsNotifierProvider);
              } catch (e) {
                if (context.mounted) showErrorAlert(e);
              }
            },
            child: Text('delete').tr(),
          ),
        ],
      ),
    );
  }

  void _showCreateSpellSheet(
    BuildContext context,
    WidgetRef ref, {
    required bool canManage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => CreateSpellSheet(canManage: canManage),
    );
  }
}

/// The kind of spell the create sheet produces. Tracking spells are
/// conversion-tracking codes created by admins; registration invites are
/// purchased and consumed during signup.
enum _SpellKind { tracking, invite }

class CreateSpellSheet extends StatefulWidget {
  /// Whether the current user holds `affiliations.manage` (superuser proxy).
  final bool canManage;

  const CreateSpellSheet({super.key, required this.canManage});

  @override
  State<CreateSpellSheet> createState() => _CreateSpellSheetState();
}

class _CreateSpellSheetState extends State<CreateSpellSheet> {
  final _controller = TextEditingController();
  final _maxUsagesController = TextEditingController();
  _SpellKind _kind = _SpellKind.tracking;
  bool _skipTests = true;
  bool _isLoading = false;

  /// True when the max-usages field is empty (unlimited) or a value >= 1.
  bool get _maxUsagesValid {
    final text = _maxUsagesController.text.trim();
    if (text.isEmpty) return true;
    final parsed = int.tryParse(text);
    return parsed != null && parsed >= 1;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.canManage) {
      _kind = _SpellKind.invite;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _maxUsagesController.dispose();
    super.dispose();
  }

  Future<void> _createSpell() async {
    // Tracking-spell creation requires `affiliations.manage` (superuser
    // proxy); the invite flow is the only option for regular users.
    if (!widget.canManage) return;

    final maxUsagesText = _maxUsagesController.text.trim();
    final maxUsages = maxUsagesText.isEmpty
        ? null
        : int.tryParse(maxUsagesText);
    if (maxUsagesText.isNotEmpty && (maxUsages == null || maxUsages < 1)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final container = ProviderScope.containerOf(context);
      final client = container.read(solarNetworkClientProvider);
      await client.accounts.createAffiliationSpell(
        spell: _controller.text.isNotEmpty ? _controller.text : null,
        maxUsages: maxUsages,
        skipTests: _skipTests,
      );
      container.invalidate(affiliationsNotifierProvider);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) showErrorAlert(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseInvite() async {
    final confirmed = await showConfirmAlert(
      'affiliationPurchaseConfirm'.tr(),
      'affiliationPurchase'.tr(),
      icon: Symbols.card_giftcard,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final container = ProviderScope.containerOf(context);
      final client = container.read(solarNetworkClientProvider);
      // Creates the Wallet order (paid in points); the single-use invite
      // spell appears once the order is fulfilled.
      final purchase = await client.accounts.purchaseAffiliationSpell();
      final order = await client.wallet.getOrder(purchase.orderId);
      if (!mounted) return;

      final paidOrder = await PaymentOverlay.show(
        context: context,
        order: order,
        payerWalletId: order.payerWalletId,
        enableBiometric: true,
      );
      if (paidOrder == null) {
        // Cancelled or failed — keep the sheet open so the user can retry.
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      container.invalidate(affiliationsNotifierProvider);
      container.invalidate(walletCurrentProvider);
      container.invalidate(walletListProvider);
      container.invalidate(walletStatsProvider);
      if (!mounted) return;
      Navigator.pop(context);
      showInfoAlert(
        'affiliationPurchaseSuccess'.tr(
          namedArgs: {'amount': _formatAmount(order.amount.toDouble())},
        ),
        'affiliationPurchase'.tr(),
        icon: Symbols.check_circle,
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) showErrorAlert(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'affiliationCreate'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.canManage) ...[
              SegmentedButton<_SpellKind>(
                segments: [
                  ButtonSegment(
                    value: _SpellKind.tracking,
                    icon: const Icon(Symbols.auto_fix_high),
                    label: Text('affiliationKindTracking').tr(),
                  ),
                  ButtonSegment(
                    value: _SpellKind.invite,
                    icon: const Icon(Symbols.card_giftcard),
                    label: Text('affiliationTypeInvite').tr(),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (selection) {
                  setState(() => _kind = selection.first);
                },
              ),
              const SizedBox(height: 16),
            ],
            if (_kind == _SpellKind.tracking) ...[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'affiliationCustomWord'.tr(),
                  hintText: 'affiliationCustomWordHint'.tr(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'affiliationCustomWordDescription',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).tr(),
              const SizedBox(height: 16),
              TextField(
                controller: _maxUsagesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'affiliationMaxUsages'.tr(),
                  hintText: 'affiliationMaxUsagesHint'.tr(),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('affiliationSkipTests').tr(),
                subtitle: Text('affiliationSkipTestsDescription').tr(),
                value: _skipTests,
                onChanged: (value) => setState(() => _skipTests = value),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading || !_maxUsagesValid ? null : _createSpell,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('create').tr(),
              ),
            ] else ...[
              Text(
                'affiliationInviteDescription',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).tr(),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isLoading ? null : _purchaseInvite,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.card_giftcard),
                label: Text('affiliationPurchase').tr(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Formats a decimal points amount without trailing zeros
/// (e.g. 100.0 -> "100", 99.5 -> "99.5").
String _formatAmount(double amount) => amount == amount.roundToDouble()
    ? amount.toStringAsFixed(0)
    : amount.toString();
