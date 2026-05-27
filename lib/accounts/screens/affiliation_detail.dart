import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final affiliationSpellProvider = FutureProvider.autoDispose
    .family<SnAffiliationSpell, String>((ref, id) async {
      final client = ref.watch(solarNetworkClientProvider);
      return client.accounts.getAffiliationSpell(id);
    });

@RoutePage()
class AffiliationDetailScreen extends HookConsumerWidget {
  final String id;

  const AffiliationDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final spellAsync = ref.watch(affiliationSpellProvider(id));

    return AppScaffold(
      appBar: AppBar(
        title: Text('affiliationDetail').tr(),
        centerTitle: true,
        scrolledUnderElevation: 4,
        actions: [
          spellAsync.whenOrNull(
                data: (spell) => PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'copy',
                      child: ListTile(
                        leading: const Icon(Symbols.content_copy),
                        title: Text('affiliationCopyWord').tr(),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Symbols.delete, color: colorScheme.error),
                        title: Text('affiliationDelete').tr(),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'copy') {
                      await Clipboard.setData(ClipboardData(text: spell.spell));
                      if (context.mounted) {
                        showSnackBar('affiliationCopied'.tr());
                      }
                    } else if (value == 'delete') {
                      _confirmDelete(context, ref, spell);
                    }
                  },
                ),
              ) ??
              const SizedBox.shrink(),
          const Gap(8),
        ],
      ),
      body: spellAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.error, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('error').tr(),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ref.invalidate(affiliationSpellProvider(id)),
                child: Text('retry').tr(),
              ),
            ],
          ),
        ),
        data: (spell) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: spell.spell),
                        );
                        if (context.mounted) {
                          showSnackBar('affiliationCopied'.tr());
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              spell.spell,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Symbols.content_copy,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'affiliationCreatedBy'.tr(
                        namedArgs: {
                          'date': spell.createdAt.toLocal().formatSystem(),
                        },
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Text(
                    'affiliationResults',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ).tr(),
                ],
              ),
            ),
            Expanded(child: _ResultsList(spellId: id)),
          ],
        ),
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
                if (context.mounted) context.router.maybePop();
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
}

class _ResultsList extends StatefulWidget {
  final String spellId;

  const _ResultsList({required this.spellId});

  @override
  State<_ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends State<_ResultsList> {
  final List<SnAffiliationResult> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _totalCount = 0;
  bool _isInitialLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _fetchMore();
  }

  Future<void> _fetchMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final client = ProviderScope.containerOf(
        context,
      ).read(solarNetworkClientProvider);
      final result = await client.accounts.listAffiliationResults(
        widget.spellId,
        desc: true,
        offset: _items.length,
        take: 20,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _totalCount = result.totalCount;
        _hasMore = _items.length < _totalCount;
        _isLoading = false;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
        _isInitialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.error, size: 32, color: colorScheme.error),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isInitialLoading = true;
                });
                _fetchMore();
              },
              child: Text('retry').tr(),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.inbox, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'affiliationEmpty',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).tr(),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, idx) {
        if (idx == _items.length) {
          if (!_isLoading) _fetchMore();
          return _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }

        final result = _items[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Symbols.person,
                color: colorScheme.onSecondaryContainer,
                size: 20,
              ),
            ),
            title: Text(
              result.resourceIdentifier,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              result.createdAt.toLocal().formatSystem(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),
        );
      },
    );
  }
}
