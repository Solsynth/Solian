import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/thoughts/ai_console_api.dart';
import 'package:island/thoughts/personality_api.dart';
import 'package:island/thoughts/plugins/plugin_registry.dart';
import 'package:island/thoughts/plugins/web_tools_plugin.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// The AI console: the account side of the Thoughts tab.
///
/// Four surfaces share one page, because each answers a question the others
/// raise. The catalogue says what an agent can be run against; the billing tab
/// says whether it may be run at all; usage says what running it cost and which
/// call spent it; and the skills tab is what the agent can reach on this
/// device. Every read is the server's own (`/persona`), so the figures here are
/// the charges that were actually metered rather than a client-side tally.
@RoutePage()
class AiConsoleScreen extends HookConsumerWidget {
  const AiConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text('thoughtsConsoleTitle'.tr()),
        actions: [
          IconButton(
            tooltip: 'thoughtsConsoleCredentials'.tr(),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const AiConsoleCredentialsSheet(),
            ),
            icon: const Icon(Symbols.key_rounded),
          ),
          const Gap(SolSpace.sm),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(
                  icon: const Icon(Symbols.extension),
                  text: 'thoughtsConsoleCatalog'.tr(),
                ),
                Tab(
                  icon: const Icon(Symbols.receipt_long),
                  text: 'thoughtsConsoleBilling'.tr(),
                ),
                Tab(
                  icon: const Icon(Symbols.query_stats),
                  text: 'thoughtsConsoleUsage'.tr(),
                ),
                Tab(
                  icon: const Icon(Symbols.handyman),
                  text: 'thoughtsConsoleSkills'.tr(),
                ),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _CatalogTab(),
                  _BillingTab(),
                  _UsageTab(),
                  _SkillsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

/// A section heading: the page's own scale, in the accent, so a long tab reads
/// as groups rather than as one scroll.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: SolSpace.xs, bottom: SolSpace.sm),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// One labelled fact inside a card.
class _KeyValue extends StatelessWidget {
  const _KeyValue(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 104,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}

/// A card with this page's inset and radius, so a tab's blocks line up.
class _ConsoleCard extends StatelessWidget {
  const _ConsoleCard({required this.child, this.padding = true});

  final Widget child;
  final bool padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: SolRadius.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ? const EdgeInsets.all(SolSpace.lg) : EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

/// A failed read, with the one action that can help.
class _ReadError extends StatelessWidget {
  const _ReadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Symbols.error_outline,
      title: 'failedToLoad'.tr(),
      description: personalityErrorMessage(error),
      action: TextButton(onPressed: onRetry, child: Text('retry'.tr())),
      compact: true,
    );
  }
}

// Vertical inset on the scroll; horizontal is handled by _ConsoleBody so the
// content stays centred at a fixed max width rather than stretching to fill.
const _consoleScrollPadding = EdgeInsets.only(
  top: SolSpace.lg,
  bottom: SolSpace.xxxl,
);

/// Centres tab content and pins it to a comfortable reading width.
///
/// Mirrors how [RealmListScreen] wraps each list item in a [ConstrainedBox] and
/// centres it: all four console tabs feel narrow and focused on a wide display
/// while still filling the screen on a phone.
class _ConsoleBody extends StatelessWidget {
  const _ConsoleBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: _consoleScrollPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SolSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// A ledger amount as a reader reads it: two decimals, with a charge too small
/// to show kept visible rather than rounded to a free-looking zero.
String formatLedgerAmount(String raw) {
  final value = double.tryParse(raw.trim()) ?? 0;
  if (value == 0) return '0';
  if (value.abs() < 0.01) return '<0.01';
  return value.toStringAsFixed(2);
}

/// The ledger's name for a charge, in a reader's words. The raw value is a
/// machine key (`generation`, `web_search/tavily`) and is still what a filter
/// sends.
String ledgerActionLabel(String action) {
  final parts = action.split('/');
  switch (parts.first) {
    case 'generation':
      return 'thoughtsConsoleActionReply'.tr();
    case 'web_search':
      final engine = parts.length > 1 ? parts[1].trim() : '';
      final perTokens = parts.length > 2 && parts[2] == 'tokens';
      final label = perTokens
          ? 'thoughtsConsoleActionSearchTokens'.tr()
          : 'thoughtsConsoleActionSearch'.tr();
      return engine.isEmpty ? label : '$label · $engine';
    default:
      return action.isEmpty ? 'thoughtsConsoleActionCharge'.tr() : action;
  }
}

String _ledgerDimensionLabel(String key) => switch (key) {
  'action' => 'thoughtsConsoleDimensionAction'.tr(),
  'surface' => 'thoughtsConsoleDimensionEndpoint'.tr(),
  'device' => 'thoughtsConsoleDimensionDevice'.tr(),
  'ip' => 'thoughtsConsoleDimensionAddress'.tr(),
  'credential' => 'thoughtsConsoleDimensionCredential'.tr(),
  _ => key,
};

/// The rolling windows the audit offers.
const Map<int, String> _ledgerWindowKeys = {
  1: 'thoughtsConsoleWindow24h',
  7: 'thoughtsConsoleWindow7d',
  30: 'thoughtsConsoleWindow30d',
};

/// How many rows of a breakdown are listed before the rest are counted up.
const int _kBreakdownRows = 4;

String _currencyLabel(String currency) {
  final normalized = currency.trim().toLowerCase();
  if (normalized.isEmpty) return currency;
  return currency.trim();
}

/// A compact absolute timestamp, for a receipt line.
String _formatTimestamp(DateTime time) {
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

// ---------------------------------------------------------------------------
// Catalogue — what can be run, and what it costs
// ---------------------------------------------------------------------------

class _CatalogTab extends ConsumerWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(personalityAgentsProvider);
    final models = ref.watch(personaModelsProvider);

    return _ConsoleBody(
      children: [
        _SectionTitle('thoughtsConsoleAgents'.tr()),
        agents.when(
          data: (list) => list.isEmpty
              ? EmptyState(
                  icon: Symbols.psychology_rounded,
                  title: 'thoughtsConsoleNoAgents'.tr(),
                  compact: true,
                )
              : Column(
                  spacing: SolSpace.sm,
                  children: [
                    for (final agent in list) _AgentCard(agent: agent),
                  ],
                ),
          error: (error, _) => _ReadError(
            error: error,
            onRetry: () => ref.invalidate(personalityAgentsProvider),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(SolSpace.xl),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        const Gap(SolSpace.lg),
        _SectionTitle('thoughtsConsoleModels'.tr()),
        models.when(
          data: (list) => list.isEmpty
              ? EmptyState(
                  icon: Symbols.memory_rounded,
                  title: 'thoughtsConsoleNoModels'.tr(),
                  compact: true,
                )
              : Column(
                  spacing: SolSpace.sm,
                  children: [
                    for (final model in list) _ModelCard(model: model),
                  ],
                ),
          error: (error, _) => _ReadError(
            error: error,
            onRetry: () => ref.invalidate(personaModelsProvider),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(SolSpace.xl),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgentCard extends ConsumerWidget {
  const _AgentCard({required this.agent});

  final SnPersonalityAgent agent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final description = agent.description?.trim() ?? '';
    return _ConsoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                agent.enabled
                    ? Symbols.check_circle_rounded
                    : Symbols.block_rounded,
                size: 18,
                color: agent.enabled ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const Gap(SolSpace.sm),
              Expanded(
                child: Text(
                  agent.name.trim().isEmpty ? agent.id : agent.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                agent.enabled
                    ? 'thoughtsConsoleAgentEnabled'.tr()
                    : 'thoughtsConsoleAgentDisabled'.tr(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const Gap(SolSpace.sm),
            Text(description, style: theme.textTheme.bodySmall),
          ],
          if ((agent.model ?? '').isNotEmpty) ...[
            const Gap(SolSpace.sm),
            _KeyValue('thoughtsConsoleModel'.tr(), agent.model!),
          ],
          if (agent.abilities.isNotEmpty) ...[
            const Gap(SolSpace.sm),
            Wrap(
              spacing: SolSpace.xs,
              runSpacing: SolSpace.xs,
              children: [
                for (final ability in agent.abilities)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    labelStyle: theme.textTheme.labelSmall,
                    label: Text(ability),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.model});

  final SnPersonaModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pricing = model.pricing;
    final price = pricing == null
        ? ''
        : [
            if ((pricing.input ?? '').isNotEmpty) pricing.input!,
            if ((pricing.output ?? '').isNotEmpty) pricing.output!,
          ].join(' / ');
    return _ConsoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  model.name.trim().isEmpty ? model.id : model.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (model.readsImages)
                Icon(
                  Symbols.image_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
          const Gap(SolSpace.xs),
          _KeyValue('thoughtsConsoleProvider'.tr(), model.provider),
          if ((model.type ?? '').isNotEmpty)
            _KeyValue('thoughtsConsoleModelType'.tr(), model.type!),
          if (model.modalities.isNotEmpty)
            _KeyValue(
              'thoughtsConsoleModalities'.tr(),
              model.modalities.join(', '),
            ),
          if (price.isNotEmpty)
            _KeyValue(
              'thoughtsConsolePricing'.tr(),
              '${price.trim()} ${_currencyLabel(pricing!.currency ?? '')}',
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Billing — whether the account may run, and what it has spent
// ---------------------------------------------------------------------------

class _BillingTab extends HookConsumerWidget {
  const _BillingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billing = ref.watch(personaBillingProvider);
    final quotaController = useTextEditingController();
    final initialized = useState(false);
    final quotaText = useValueListenable(quotaController).text.trim();

    return billing.when(
      data: (value) {
        // Seeded once: seeding on every rebuild would overwrite what is being
        // typed the moment any other read refreshes.
        if (!initialized.value) {
          quotaController.text = value.spendingQuota ?? '0';
          initialized.value = true;
        }
        final saved = (value.spendingQuota ?? '0').trim();
        return _ConsoleBody(
          children: [
            _StandingCard(
              blacklisted: value.blacklisted,
              onSettle: () => _settle(context, ref),
            ),
            const Gap(SolSpace.md),
            _ConsoleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'thoughtsConsoleSpendingQuota'.tr(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Gap(SolSpace.xs),
                  Text(
                    'thoughtsConsoleSpendingQuotaHint'.tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Gap(SolSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quotaController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (quotaText.isNotEmpty && quotaText != saved) {
                              _saveQuota(context, ref, quotaText);
                            }
                          },
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ),
                      const Gap(SolSpace.sm),
                      FilledButton(
                        onPressed: quotaText.isEmpty || quotaText == saved
                            ? null
                            : () => _saveQuota(context, ref, quotaText),
                        child: Text('save'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(SolSpace.md),
            _MeteredUsageCard(usage: value.usage),
          ],
        );
      },
      error: (error, _) => _ReadError(
        error: error,
        onRetry: () => ref.invalidate(personaBillingProvider),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _saveQuota(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    try {
      await saveSpendingQuota(ref.container, value);
      if (context.mounted) showSnackBar('settingsSaved'.tr());
    } catch (error) {
      showErrorAlert(error);
    }
  }

  Future<void> _settle(BuildContext context, WidgetRef ref) async {
    try {
      await settleBilling(ref.container);
      if (context.mounted) showSnackBar('thoughtsConsoleUsageSettled'.tr());
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

/// Whether the account can run at all, and the way back when it cannot.
class _StandingCard extends StatelessWidget {
  const _StandingCard({required this.blacklisted, required this.onSettle});

  final bool blacklisted;
  final VoidCallback onSettle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = blacklisted ? scheme.error : scheme.primary;
    return _ConsoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                blacklisted
                    ? Symbols.block_rounded
                    : Symbols.check_circle_rounded,
                color: accent,
                size: 20,
              ),
              const Gap(SolSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blacklisted
                          ? 'thoughtsConsoleBillingSuspended'.tr()
                          : 'thoughtsConsoleBillingActive'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: blacklisted ? scheme.error : null,
                      ),
                    ),
                    Text(
                      blacklisted
                          ? 'thoughtsConsoleBillingSuspendedHint'.tr()
                          : 'thoughtsConsoleBillingActiveHint'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (blacklisted) ...[
            const Gap(SolSpace.md),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onSettle,
                icon: const Icon(Symbols.paid_rounded, size: 18),
                label: Text('thoughtsConsoleSettleUsage'.tr()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// What the account spent this hour and today, per currency, against the
/// configured interval limit when there is one.
class _MeteredUsageCard extends StatelessWidget {
  const _MeteredUsageCard({required this.usage});

  final SnPersonaBillingUsage usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = usage.hourly.isEmpty && usage.daily.isEmpty;
    return _ConsoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'thoughtsConsoleMeteredUsage'.tr(),
            style: theme.textTheme.titleSmall,
          ),
          const Gap(SolSpace.md),
          if (empty)
            Text(
              'thoughtsConsoleNothingMetered'.tr(),
              style: theme.textTheme.bodySmall,
            )
          else ...[
            _UsageInterval(
              label: 'thoughtsConsoleThisHour'.tr(),
              usage: usage.hourly,
            ),
            const Gap(SolSpace.md),
            _UsageInterval(
              label: 'thoughtsConsoleToday'.tr(),
              usage: usage.daily,
            ),
          ],
        ],
      ),
    );
  }
}

class _UsageInterval extends StatelessWidget {
  const _UsageInterval({required this.label, required this.usage});

  final String label;
  final Map<String, SnPersonaRunUsage> usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(SolSpace.xs),
        if (usage.isEmpty)
          Text(
            'thoughtsConsoleNothingMetered'.tr(),
            style: theme.textTheme.bodySmall,
          )
        else
          for (final entry in usage.entries)
            _UsageRow(label: _currencyLabel(entry.key), usage: entry.value),
      ],
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({required this.label, required this.usage});

  final String label;
  final SnPersonaRunUsage usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = usage.max == null ? null : double.tryParse(usage.max!.trim());
    final used = double.tryParse(usage.used.trim()) ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: SolSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
              Text(
                max == null
                    ? '${formatLedgerAmount(usage.used)} '
                          '${'thoughtsConsoleUsedSuffix'.tr()}'
                    : '${formatLedgerAmount(usage.used)} / '
                          '${formatLedgerAmount(usage.max!)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (max != null && max > 0) ...[
            const Gap(SolSpace.xs),
            LinearProgressIndicator(
              value: (used / max).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Usage — where searches run, and what the calls cost
// ---------------------------------------------------------------------------

class _UsageTab extends HookConsumerWidget {
  const _UsageTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = useState(7);
    final filterKey = useState<String?>(null);
    final filterValue = useState<String?>(null);
    final windowQuery = SnLedgerQuery(days: days.value);
    final listQuery = SnLedgerQuery(
      days: days.value,
      key: filterKey.value,
      value: filterValue.value,
    );
    final summary = ref.watch(personaLedgerSummaryProvider(windowQuery));
    final ledger = ref.watch(personaBillingLedgerProvider(listQuery));

    return _ConsoleBody(
      children: [
        _SectionTitle('thoughtsConsoleSearchProvider'.tr()),
        const _SearchProviderCard(),
        const Gap(SolSpace.lg),
        _SectionTitle('thoughtsConsoleSpend'.tr()),
        Wrap(
          spacing: SolSpace.sm,
          runSpacing: SolSpace.sm,
          children: [
            for (final entry in _ledgerWindowKeys.entries)
              _FilterPill(
                label: entry.value.tr(),
                selected: days.value == entry.key,
                onTap: () => days.value = entry.key,
              ),
            if (filterKey.value != null && filterValue.value != null)
              _FilterPill(
                label:
                    '${_ledgerDimensionLabel(filterKey.value!)}: '
                    '${filterValue.value}',
                selected: true,
                icon: Symbols.close_rounded,
                onTap: () {
                  filterKey.value = null;
                  filterValue.value = null;
                },
              ),
          ],
        ),
        const Gap(SolSpace.md),
        summary.when(
          data: (value) => _SpendBreakdown(
            summary: value,
            onFilter: (key, value) {
              filterKey.value = key;
              filterValue.value = value;
            },
          ),
          error: (error, _) => _ReadError(
            error: error,
            onRetry: () =>
                ref.invalidate(personaLedgerSummaryProvider(windowQuery)),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(SolSpace.xl),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        const Gap(SolSpace.lg),
        _SectionTitle('thoughtsConsoleRecentCharges'.tr()),
        ledger.when(
          data: (entries) => _LedgerCard(entries: entries),
          error: (error, _) => _ReadError(
            error: error,
            onRetry: () =>
                ref.invalidate(personaBillingLedgerProvider(listQuery)),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(SolSpace.xl),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Where a search runs, and what each choice costs.
///
/// The choice only means anything while the server runs the search: with the
/// on-device search switch on, the call leaves from this machine and the server
/// never sees it, so the card says so rather than offering a setting that would
/// do nothing.
class _SearchProviderCard extends ConsumerWidget {
  const _SearchProviderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final choice = ref.watch(personaSearchChoiceProvider);
    final onDevice = ref
        .watch(pluginEnablementProvider)
        .contains(const WebSearchPlugin().id);

    return _ConsoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'thoughtsConsoleWhereSearchesRun'.tr(),
            style: theme.textTheme.titleSmall,
          ),
          const Gap(SolSpace.xs),
          Text(
            onDevice
                ? 'thoughtsConsoleSearchesOnDevice'.tr()
                : 'thoughtsConsoleOnlyChosenEngine'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(SolSpace.sm),
          choice.when(
            data: (value) => Column(
              children: [
                _EngineRow(
                  label: 'thoughtsConsoleServerDefault'.tr(),
                  detail: 'thoughtsConsoleWhicheverEngine'.tr(),
                  selected: value.preference.engine.isEmpty,
                  onTap: () => _chooseEngine(context, ref, ''),
                ),
                for (final engine in value.catalog.engines)
                  _EngineRow(
                    label: engine.id,
                    detail: _engineCost(engine, value.catalog.currency),
                    selected: value.preference.engine == engine.id,
                    onTap: () => _chooseEngine(context, ref, engine.id),
                  ),
              ],
            ),
            error: (error, _) => _ReadError(
              error: error,
              onRetry: () => ref.invalidate(personaSearchChoiceProvider),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(SolSpace.md),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  /// What one query through [engine] costs, in the catalogue's currency.
  String _engineCost(SnWebSearchEngine engine, String currency) {
    if (engine.free) return 'thoughtsConsoleEngineFree'.tr();
    final unit = _currencyLabel(currency).toLowerCase();
    final parts = <String>[
      if (engine.price.isNotEmpty)
        '${formatLedgerAmount(engine.price)} $unit '
            '${'thoughtsConsolePerSearch'.tr()}',
      if (engine.metered) 'thoughtsConsoleProviderTokensBilled'.tr(),
    ];
    return parts.isEmpty ? 'thoughtsConsoleEngineFree'.tr() : parts.join(' · ');
  }

  Future<void> _chooseEngine(
    BuildContext context,
    WidgetRef ref,
    String engine,
  ) async {
    try {
      await saveSearchEngine(ref.container, engine);
      if (!context.mounted) return;
      showSnackBar(
        engine.isEmpty
            ? 'thoughtsConsoleSearchesAny'.tr()
            : 'thoughtsConsoleSearchesUse'.tr(
                namedArgs: {'engine': engine},
              ),
      );
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _EngineRow extends StatelessWidget {
  const _EngineRow({
    required this.label,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SolRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SolSpace.xxs,
          vertical: SolSpace.sm,
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Symbols.radio_button_checked
                  : Symbols.radio_button_unchecked,
              size: 18,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const Gap(SolSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodyMedium),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: SolRadius.pillRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SolSpace.md,
          vertical: SolSpace.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          borderRadius: SolRadius.pillRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (icon != null) ...[
              const Gap(SolSpace.xs + 2),
              Icon(icon, size: 14, color: foreground),
            ],
          ],
        ),
      ),
    );
  }
}

/// The window's total, then what made it up — by action, endpoint, device,
/// address and credential. Each row is the way into the charges behind it.
class _SpendBreakdown extends StatelessWidget {
  const _SpendBreakdown({required this.summary, required this.onFilter});

  final SnLedgerSummary summary;
  final void Function(String key, String value) onFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = summary.byCurrency.isEmpty
        ? '0'
        : summary.byCurrency
              .map(
                (bucket) =>
                    '${formatLedgerAmount(bucket.amount)} '
                    '${_currencyLabel(bucket.currency)}',
              )
              .join(' · ');
    final credentials = summary.byCredential
        .where((bucket) => bucket.key.isNotEmpty)
        .toList();
    final groups = <(String, String, List<SnLedgerBucket>)>[
      ('thoughtsConsoleByAction'.tr(), 'action', summary.byAction),
      ('thoughtsConsoleByEndpoint'.tr(), 'surface', summary.bySurface),
      ('thoughtsConsoleByDevice'.tr(), 'device', summary.byDeviceId),
      ('thoughtsConsoleByAddress'.tr(), 'ip', summary.byClientIp),
      ('thoughtsConsoleByCredential'.tr(), 'credential', credentials),
    ];

    return _ConsoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(total, style: theme.textTheme.titleMedium),
              ),
              Text(
                'thoughtsConsoleChargeCount'.plural(summary.entries),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (summary.entries == 0) ...[
            const Gap(SolSpace.sm),
            Text(
              'thoughtsConsoleNothingInWindow'.tr(),
              style: theme.textTheme.bodySmall,
            ),
          ] else
            for (final (title, dimension, buckets) in groups)
              if (buckets.isNotEmpty) ...[
                const Gap(SolSpace.md),
                _BucketGroup(
                  title: title,
                  dimension: dimension,
                  buckets: buckets,
                  onFilter: onFilter,
                ),
              ],
        ],
      ),
    );
  }
}

class _BucketGroup extends StatelessWidget {
  const _BucketGroup({
    required this.title,
    required this.dimension,
    required this.buckets,
    required this.onFilter,
  });

  final String title;
  final String dimension;
  final List<SnLedgerBucket> buckets;
  final void Function(String key, String value) onFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = buckets.take(_kBreakdownRows).toList();
    final hidden = buckets.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        for (final bucket in shown)
          InkWell(
            onTap: () => onFilter(dimension, bucket.key),
            borderRadius: BorderRadius.circular(SolRadius.xs),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SolSpace.xxs,
                vertical: SolSpace.xs + 1,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      bucket.key.isEmpty
                          ? 'thoughtsConsoleNone'.tr()
                          : ledgerActionLabel(bucket.key),
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${formatLedgerAmount(bucket.amount)} '
                    '${_currencyLabel(bucket.currency)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.only(
              left: SolSpace.xxs,
              top: SolSpace.xxs,
            ),
            child: Text(
              'thoughtsConsoleMoreResults'.tr(
                namedArgs: {'count': '$hidden'},
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _LedgerCard extends StatelessWidget {
  const _LedgerCard({required this.entries});

  final List<SnLedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _ConsoleCard(
        child: Text(
          'thoughtsConsoleNoCharges'.tr(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return _ConsoleCard(
      padding: false,
      child: Column(
        children: [
          for (final (index, entry) in entries.indexed) ...[
            if (index > 0) const Divider(height: 1),
            _LedgerRow(entry: entry),
          ],
        ],
      ),
    );
  }
}

/// One charge: what it was, priced as what paid for it, and the call behind it.
class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry});

  final SnLedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = entry.model == entry.action ? '' : entry.model;
    final where = [
      if (entry.surface.isNotEmpty) entry.surface,
      if (entry.deviceId.isNotEmpty) entry.deviceId,
      if (entry.clientIp.isNotEmpty) entry.clientIp,
      if (entry.createdAt != null) _formatTimestamp(entry.createdAt!),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SolSpace.lg,
        vertical: SolSpace.sm + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  ledgerActionLabel(entry.action),
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(SolSpace.md),
              Text(
                '${formatLedgerAmount(entry.originalAmount)} '
                '${_currencyLabel(entry.currency)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (model.isNotEmpty)
            Text(
              model,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          if (where.isNotEmpty)
            Text(
              where.join(' · '),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skills — what the agent can reach on this device
// ---------------------------------------------------------------------------

/// The capability packs, each with the switch that grants it.
///
/// The list is the registry, not a hand-written one: a plugin added to
/// `kBuiltInPlugins` appears here, with its own honest description of what
/// turning it on allows, without an edit to this page.
class _SkillsTab extends ConsumerWidget {
  const _SkillsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plugins = ref.watch(pluginRegistryProvider);
    final enabled = ref.watch(pluginEnablementProvider);
    final notifier = ref.read(pluginEnablementProvider.notifier);

    return _ConsoleBody(
      children: [
        Text(
          'thoughtsConsoleSkillsHint'.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(SolSpace.md),
        for (final plugin in plugins)
          Padding(
            padding: const EdgeInsets.only(bottom: SolSpace.sm),
            child: _ConsoleCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plugin.label,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      Switch(
                        value: enabled.contains(plugin.id),
                        onChanged: (value) =>
                            notifier.setEnabled(plugin.id, value),
                      ),
                    ],
                  ),
                  Text(
                    plugin.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(SolSpace.xs),
                  Row(
                    children: [
                      Icon(
                        plugin.onDemand
                            ? Symbols.bolt_rounded
                            : Symbols.all_inclusive_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const Gap(SolSpace.xs),
                      Expanded(
                        child: Text(
                          plugin.onDemand
                              ? 'thoughtsConsoleSkillOnDemand'.tr()
                              : 'thoughtsConsoleSkillEager'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...plugin.settingsRows(ref),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Credentials — the tokens OpenAI-compatible clients sign in with
// ---------------------------------------------------------------------------

/// The OpenAI-compatible credentials, reachable from the console by their own
/// page section: they are the other way in to the same account.
class AiConsoleCredentialsSheet extends HookConsumerWidget {
  const AiConsoleCredentialsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(personaCredentialsProvider);
    return SheetScaffold(
      titleText: 'thoughtsConsoleCredentials'.tr(),
      heightFactor: 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SolSpace.lg,
              SolSpace.md,
              SolSpace.lg,
              SolSpace.sm,
            ),
            child: FilledButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                useRootNavigator: true,
                builder: (_) => const _CreateCredentialSheet(),
              ),
              icon: const Icon(Symbols.add_rounded, size: 18),
              label: Text('thoughtsConsoleCreateCredential'.tr()),
            ),
          ),
          Expanded(
            child: credentials.when(
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: Symbols.key_rounded,
                      title: 'thoughtsConsoleNoCredentials'.tr(),
                      compact: true,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        SolSpace.lg,
                        0,
                        SolSpace.lg,
                        SolSpace.xxl,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const Gap(SolSpace.sm),
                      itemBuilder: (context, index) =>
                          _CredentialCard(credential: list[index]),
                    ),
              error: (error, _) => _ReadError(
                error: error,
                onRetry: () => ref.invalidate(personaCredentialsProvider),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialCard extends ConsumerWidget {
  const _CredentialCard({required this.credential});

  final SnPersonaCredential credential;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return _ConsoleCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Symbols.key_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const Gap(SolSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(credential.name, style: theme.textTheme.titleSmall),
                Text(
                  '${credential.tokenPrefix}…',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${credential.usageUsed} / ${credential.usageLimit} '
                  '${_currencyLabel(credential.usageCurrency)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatTimestamp(credential.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'thoughtsConsoleRevoke'.tr(),
            onPressed: () => _revoke(context, ref),
            icon: Icon(Symbols.delete_forever_rounded, color: theme.colorScheme.error),
          ),
        ],
      ),
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      'thoughtsConsoleRevokeHint'.tr(),
      'thoughtsConsoleRevoke'.tr(),
      isDanger: true,
    );
    if (!confirmed) return;
    try {
      await revokeCredential(ref.container, credential.id);
      showSnackBar('settingsSaved'.tr());
    } catch (error) {
      showErrorAlert(error);
    }
  }
}

class _CreateCredentialSheet extends HookConsumerWidget {
  const _CreateCredentialSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useTextEditingController();
    final limit = useTextEditingController(text: '0');
    final currency = useTextEditingController(text: 'USD');
    final submitting = useState(false);
    final createdToken = useState<String?>(null);
    final token = createdToken.value;

    return SheetScaffold(
      titleText: 'thoughtsConsoleCreateCredential'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SolSpace.lg,
          SolSpace.md,
          SolSpace.lg,
          SolSpace.xxl,
        ),
        child: token != null
            ? _TokenReveal(
                token: token,
                onDone: () => Navigator.of(context).pop(),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'thoughtsConsoleCredentialName'.tr(),
                    ),
                  ),
                  const Gap(SolSpace.md),
                  TextField(
                    controller: limit,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'thoughtsConsoleUsageLimit'.tr(),
                    ),
                  ),
                  const Gap(SolSpace.md),
                  TextField(
                    controller: currency,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'thoughtsConsoleCurrency'.tr(),
                    ),
                  ),
                  const Gap(SolSpace.lg),
                  FilledButton(
                    onPressed: submitting.value
                        ? null
                        : () async {
                            if (name.text.trim().isEmpty) return;
                            submitting.value = true;
                            try {
                              final created = await createCredential(
                                ref.container,
                                name: name.text.trim(),
                                usageLimit: limit.text.trim(),
                                usageCurrency: currency.text
                                    .trim()
                                    .toUpperCase(),
                              );
                              if (!context.mounted) return;
                              createdToken.value = created.token;
                            } catch (error) {
                              showErrorAlert(error);
                            } finally {
                              submitting.value = false;
                            }
                          },
                    child: Text('thoughtsConsoleCreateCredential'.tr()),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The one time a credential's token is readable.
class _TokenReveal extends StatelessWidget {
  const _TokenReveal({required this.token, required this.onDone});

  final String token;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Symbols.key_rounded,
          size: 40,
          color: theme.colorScheme.primary,
        ),
        const Gap(SolSpace.md),
        Text(
          'thoughtsConsoleCredentialCreated'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const Gap(SolSpace.xs),
        Text(
          'thoughtsConsoleCopyTokenHint'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const Gap(SolSpace.md),
        Container(
          padding: const EdgeInsets.all(SolSpace.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(SolRadius.sm),
          ),
          child: SelectableText(token, style: theme.textTheme.bodySmall),
        ),
        const Gap(SolSpace.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: token)),
                icon: const Icon(Symbols.content_copy_rounded, size: 18),
                label: Text('copyToClipboard'.tr()),
              ),
            ),
            const Gap(SolSpace.sm),
            Expanded(
              child: FilledButton(
                onPressed: onDone,
                child: Text('done'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
