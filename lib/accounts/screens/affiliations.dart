import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/alert.dart';
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
        onPressed: () => _showCreateSpellSheet(context, ref),
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
                        Symbols.auto_fix_high,
                        color: colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spell.spell,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
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

  void _showCreateSpellSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateSpellSheet(),
    );
  }
}

class CreateSpellSheet extends StatefulWidget {
  const CreateSpellSheet({super.key});

  @override
  State<CreateSpellSheet> createState() => _CreateSpellSheetState();
}

class _CreateSpellSheetState extends State<CreateSpellSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'affiliationCreate',
            style: Theme.of(context).textTheme.titleLarge,
          ).tr(),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'affiliationCustomWord'.tr(),
              hintText: 'affiliationCustomWordHint'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'affiliationCustomWordDescription',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ).tr(),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    try {
                      final container = ProviderScope.containerOf(context);
                      final client = container.read(solarNetworkClientProvider);
                      await client.accounts.createAffiliationSpell(
                        spell: _controller.text.isNotEmpty
                            ? _controller.text
                            : null,
                      );
                      container.invalidate(affiliationsNotifierProvider);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) showErrorAlert(e);
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('create').tr(),
          ),
        ],
      ),
    );
  }
}
