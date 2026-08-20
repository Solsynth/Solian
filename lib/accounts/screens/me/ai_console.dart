import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:island/core/network.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/response.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_console.g.dart';

// ---------------------------------------------------------------------------
// Models — local client-side mirrors of the FloatLand personality backend
// (/personality). Kept dependency-free (plain fromJson) since these are not
// part of the typed solar_network_sdk surface.
// ---------------------------------------------------------------------------

class SnPersonalityRunUsage {
  final String used;
  final String? max;
  const SnPersonalityRunUsage({required this.used, this.max});

  factory SnPersonalityRunUsage.fromJson(Map<String, dynamic> json) =>
      SnPersonalityRunUsage(
        used: (json['used'] ?? '0').toString(),
        max: json['max']?.toString(),
      );
}

class SnPersonalityBillingUsage {
  final SnPersonalityRunUsage? hourlyRuns;
  final SnPersonalityRunUsage? dailyRuns;
  final Map<String, SnPersonalityRunUsage> hourlyUsage;
  final Map<String, SnPersonalityRunUsage> dailyUsage;

  const SnPersonalityBillingUsage({
    this.hourlyRuns,
    this.dailyRuns,
    this.hourlyUsage = const {},
    this.dailyUsage = const {},
  });

  factory SnPersonalityBillingUsage.fromJson(Map<String, dynamic> json) {
    Map<String, SnPersonalityRunUsage> parseMap(dynamic m) {
      if (m is! Map) return const {};
      return {
        for (final e in m.entries)
          e.key.toString(): SnPersonalityRunUsage.fromJson(
            e.value as Map<String, dynamic>,
          ),
      };
    }

    return SnPersonalityBillingUsage(
      hourlyRuns: json['hourly_runs'] == null
          ? null
          : SnPersonalityRunUsage.fromJson(json['hourly_runs']),
      dailyRuns: json['daily_runs'] == null
          ? null
          : SnPersonalityRunUsage.fromJson(json['daily_runs']),
      hourlyUsage: parseMap(json['hourly_usage']),
      dailyUsage: parseMap(json['daily_usage']),
    );
  }
}

class SnPersonalityBilling {
  final int? hourlyRunLimit;
  final int? dailyRunLimit;
  final String? spendingQuota;
  final bool blacklisted;
  final SnPersonalityBillingUsage usage;

  const SnPersonalityBilling({
    this.hourlyRunLimit,
    this.dailyRunLimit,
    this.spendingQuota,
    this.blacklisted = false,
    required this.usage,
  });

  factory SnPersonalityBilling.fromJson(Map<String, dynamic> json) =>
      SnPersonalityBilling(
        hourlyRunLimit: json['hourly_run_limit'] is int
            ? json['hourly_run_limit']
            : null,
        dailyRunLimit:
            json['daily_run_limit'] is int ? json['daily_run_limit'] : null,
        spendingQuota: json['spending_quota']?.toString(),
        blacklisted: json['blacklisted'] is bool ? json['blacklisted'] : false,
        usage: SnPersonalityBillingUsage.fromJson(
          json['usage'] as Map<String, dynamic>? ?? const {},
        ),
      );
}

class SnPersonalityModelPricing {
  final String? currency;
  final String? input;
  final String? output;
  const SnPersonalityModelPricing({this.currency, this.input, this.output});

  factory SnPersonalityModelPricing.fromJson(Map<String, dynamic> json) =>
      SnPersonalityModelPricing(
        currency: json['currency']?.toString(),
        input: json['input']?.toString(),
        output: json['output']?.toString(),
      );
}

class SnPersonalityModel {
  final String id;
  final String provider;
  final String name;
  final String? type;
  final List<String> modalities;
  final SnPersonalityModelPricing? pricing;

  const SnPersonalityModel({
    required this.id,
    required this.provider,
    required this.name,
    this.type,
    this.modalities = const [],
    this.pricing,
  });

  factory SnPersonalityModel.fromJson(Map<String, dynamic> json) =>
      SnPersonalityModel(
        id: json['id'] as String,
        provider: json['provider'] as String,
        name: json['name'] as String,
        type: json['type']?.toString(),
        modalities: (json['modalities'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        pricing: json['pricing'] is Map
            ? SnPersonalityModelPricing.fromJson(json['pricing'])
            : null,
      );
}

class SnPersonalityAgent {
  final String id;
  final String name;
  final String? description;
  final String? model;
  final List<String> abilities;
  final String? systemPrompt;
  final bool enabled;

  const SnPersonalityAgent({
    required this.id,
    required this.name,
    this.description,
    this.model,
    this.abilities = const [],
    this.systemPrompt,
    this.enabled = false,
  });

  factory SnPersonalityAgent.fromJson(Map<String, dynamic> json) =>
      SnPersonalityAgent(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description']?.toString(),
        model: json['model']?.toString(),
        abilities: (json['abilities'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        systemPrompt: json['system_prompt']?.toString(),
        enabled: json['enabled'] is bool ? json['enabled'] : false,
      );
}

class SnPersonalityCredential {
  final String id;
  final String name;
  final String tokenPrefix;
  final List<String> agentIds;
  final List<String> providers;
  final List<String> models;
  final String usageLimit;
  final String usageUsed;
  final String usageCurrency;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SnPersonalityCredential({
    required this.id,
    required this.name,
    required this.tokenPrefix,
    this.agentIds = const [],
    this.providers = const [],
    this.models = const [],
    required this.usageLimit,
    required this.usageUsed,
    required this.usageCurrency,
    this.enabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SnPersonalityCredential.fromJson(Map<String, dynamic> json) =>
      SnPersonalityCredential(
        id: json['id'] as String,
        name: json['name'] as String,
        tokenPrefix: json['token_prefix'] as String,
        agentIds: (json['agent_ids'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        providers: (json['providers'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        models: (json['models'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        usageLimit: (json['usage_limit'] ?? '0').toString(),
        usageUsed: (json['usage_used'] ?? '0').toString(),
        usageCurrency: json['usage_currency']?.toString() ?? 'USD',
        enabled: json['enabled'] is bool ? json['enabled'] : true,
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'])
            : DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: json['updated_at'] is String
            ? DateTime.parse(json['updated_at'])
            : DateTime.fromMillisecondsSinceEpoch(0),
      );
}

class SnPersonalityCredentialCreated {
  final SnPersonalityCredential credential;
  final String token;

  const SnPersonalityCredentialCreated({
    required this.credential,
    required this.token,
  });

  factory SnPersonalityCredentialCreated.fromJson(Map<String, dynamic> json) =>
      SnPersonalityCredentialCreated(
        credential: SnPersonalityCredential.fromJson(
          json['credential'] as Map<String, dynamic>,
        ),
        token: json['token'] as String,
      );
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

@riverpod
Future<List<SnPersonalityAgent>> personalityAgents(Ref ref) async {
  final dio = ref.read(apiClientProvider);
  final resp = await dio.get('/personality/agents');
  final data = resp.data;
  if (data is List) {
    return [
      for (final e in data)
        SnPersonalityAgent.fromJson(e as Map<String, dynamic>),
    ];
  }
  return const [];
}

@riverpod
Future<List<SnPersonalityModel>> personalityModels(Ref ref) async {
  final dio = ref.read(apiClientProvider);
  final resp = await dio.get('/personality/models');
  final data = resp.data;
  if (data is List) {
    return [
      for (final e in data)
        SnPersonalityModel.fromJson(e as Map<String, dynamic>),
    ];
  }
  return const [];
}

@riverpod
Future<SnPersonalityBilling> personalityBilling(Ref ref) async {
  final dio = ref.read(apiClientProvider);
  final resp = await dio.get('/personality/billing/me');
  return SnPersonalityBilling.fromJson(resp.data as Map<String, dynamic>);
}

@riverpod
Future<List<SnPersonalityCredential>> personalityCredentials(Ref ref) async {
  final dio = ref.read(apiClientProvider);
  final resp = await dio.get('/personality/openai/credentials');
  final data = resp.data;
  final list = data is Map ? data['data'] : null;
  if (list is List) {
    return [
      for (final e in list)
        SnPersonalityCredential.fromJson(e as Map<String, dynamic>),
    ];
  }
  return const [];
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

@RoutePage()
class AiConsoleScreen extends HookConsumerWidget {
  const AiConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        appBar: AppBar(
          leading: const AutoLeadingButton(),
          title: Text('aiConsole').tr(),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Symbols.extension),
                text: 'aiConsoleCatalog'.tr(),
              ),
              Tab(
                icon: const Icon(Symbols.receipt_long),
                text: 'aiConsoleBilling'.tr(),
              ),
              Tab(
                icon: const Icon(Symbols.key),
                text: 'aiConsoleCredentials'.tr(),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CatalogTab(),
            _BillingTab(),
            _CredentialsTab(),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String titleKey;
  const _SectionTitle(this.titleKey);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        titleKey.tr(),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  const _KeyValue(this.label, this.value, {this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'aiConsoleEmpty'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _CatalogTab extends ConsumerWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agents = ref.watch(personalityAgentsProvider);
    final models = ref.watch(personalityModelsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('aiConsoleAgents'),
          agents.when(
            data: (list) => Column(
              spacing: 8,
              children: [
                for (final a in list) _AgentCard(agent: a),
                if (list.isEmpty) const _EmptyNote(),
              ],
            ),
            error: (e, _) => ResponseErrorWidget(
              error: e,
              onRetry: () => ref.invalidate(personalityAgentsProvider),
            ),
            loading: () => const ResponseLoadingWidget(),
          ),
          _SectionTitle('aiConsoleModels'),
          models.when(
            data: (list) => Column(
              spacing: 8,
              children: [
                for (final m in list) _ModelCard(model: m),
                if (list.isEmpty) const _EmptyNote(),
              ],
            ),
            error: (e, _) => ResponseErrorWidget(
              error: e,
              onRetry: () => ref.invalidate(personalityModelsProvider),
            ),
            loading: () => const ResponseLoadingWidget(),
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final SnPersonalityAgent agent;
  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              children: [
                Icon(
                  agent.enabled ? Symbols.check_circle : Symbols.cancel,
                  color: agent.enabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    agent.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: agent.enabled
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    (agent.enabled
                            ? 'aiConsoleAgentEnabled'
                            : 'aiConsoleAgentDisabled')
                        .tr(),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            if (agent.description != null)
              Text(
                agent.description!,
                style: theme.textTheme.bodySmall,
              ),
            if (agent.model != null)
              _KeyValue('aiConsoleAgentModel'.tr(), agent.model!),
            if (agent.abilities.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final ab in agent.abilities)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(ab),
                      labelStyle: theme.textTheme.labelSmall,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final SnPersonalityModel model;
  const _ModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pricing = model.pricing;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(model.name, style: theme.textTheme.titleMedium),
            _KeyValue('aiConsoleModelProvider'.tr(), model.provider),
            if (model.type != null)
              _KeyValue('aiConsoleModelType'.tr(), model.type!),
            if (model.modalities.isNotEmpty)
              _KeyValue(
                'aiConsoleModelModalities'.tr(),
                model.modalities.join(', '),
              ),
            if (pricing != null)
              _KeyValue(
                'aiConsoleModelPricing'.tr(),
                '${pricing.input ?? '?'} / ${pricing.output ?? '?'}'
                ' (${_localizeCurrency(pricing.currency ?? 'USD')})',
                trailing: Text(
                  'aiConsoleModelPricingHint'.tr(),
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Localizes a wallet currency code (`points` → "Bits", `golds` → "Golds")
/// via the `walletCurrencyShort*` keys, like the payment overlay does.
/// Unknown codes (e.g. `USD`) pass through unchanged.
String _localizeCurrency(String currency) {
  if (currency.isEmpty) return currency;
  final key =
      'walletCurrencyShort${currency[0].toUpperCase()}${currency.substring(1).toLowerCase()}';
  final localized = key.tr();
  return localized == key ? currency : localized;
}

String _usageText(BuildContext context, SnPersonalityRunUsage? u) {
  if (u == null) return 'aiConsoleUnknown'.tr();
  return u.max == null ? u.used : '${u.used} / ${u.max}';
}

class _BillingTab extends HookConsumerWidget {
  const _BillingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final billing = ref.watch(personalityBillingProvider);
    final quotaController = useTextEditingController();
    final quotaInitialized = useState(false);

    return billing.when(
      data: (b) {
        if (!quotaInitialized.value) {
          quotaController.text = b.spendingQuota ?? '0';
          quotaInitialized.value = true;
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (b.blacklisted)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Symbols.block, color: theme.colorScheme.error),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'aiConsoleBillingBlacklisted'.tr(),
                          style:
                              TextStyle(color: theme.colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'aiConsoleBillingRunLimits'.tr(),
                        style: theme.textTheme.titleSmall,
                      ),
                      _KeyValue(
                        'aiConsoleBillingHourly'.tr(),
                        b.hourlyRunLimit?.toString() ?? 'aiConsoleUnknown'.tr(),
                      ),
                      _KeyValue(
                        'aiConsoleBillingDaily'.tr(),
                        b.dailyRunLimit?.toString() ?? 'aiConsoleUnknown'.tr(),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'aiConsoleBillingSpendingQuota'.tr(),
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        'aiConsoleBillingSpendingQuotaHint'.tr(),
                        style: theme.textTheme.labelSmall,
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: quotaController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                              ),
                            ),
                          ),
                          const Gap(8),
                          FilledButton(
                            onPressed: () => _saveQuota(
                              context,
                              ref,
                              quotaController.text,
                            ),
                            child: Text('aiConsoleBillingSaveQuota'.tr()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'aiConsoleBillingUsage'.tr(),
                        style: theme.textTheme.titleSmall,
                      ),
                      _KeyValue(
                        'aiConsoleBillingHourly'.tr(),
                        _usageText(context, b.usage.hourlyRuns),
                      ),
                      _KeyValue(
                        'aiConsoleBillingDaily'.tr(),
                        _usageText(context, b.usage.dailyRuns),
                      ),
                      ..._usageMapWidgets(
                        context,
                        b.usage.hourlyUsage,
                        'aiConsoleBillingHourly'.tr(),
                      ),
                      ..._usageMapWidgets(
                        context,
                        b.usage.dailyUsage,
                        'aiConsoleBillingDaily'.tr(),
                      ),
                    ],
                  ),
                ),
              ),
              if (b.blacklisted)
                FilledButton.icon(
                  onPressed: () => _settle(context, ref),
                  icon: const Icon(Symbols.paid),
                  label: Text('aiConsoleBillingSettle'.tr()),
                ),
            ],
          ),
        );
      },
      error: (e, _) => ResponseErrorWidget(
        error: e,
        onRetry: () => ref.invalidate(personalityBillingProvider),
      ),
      loading: () => const ResponseLoadingWidget(),
    );
  }

  List<Widget> _usageMapWidgets(
    BuildContext context,
    Map<String, SnPersonalityRunUsage> map,
    String label,
  ) {
    if (map.isEmpty) return const [];
    return [
      for (final e in map.entries)
        _KeyValue('$label · ${e.key}', _usageText(context, e.value)),
    ];
  }

  Future<void> _saveQuota(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    showLoadingModal(context);
    try {
      final dio = ref.read(apiClientProvider);
      await dio.put(
        '/personality/billing/me/spending-quota',
        data: {'spending_quota': value},
      );
      ref.invalidate(personalityBillingProvider);
      if (context.mounted) showSnackBar('settingsSaved'.tr());
    } catch (e) {
      if (context.mounted) showErrorAlert(e);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  Future<void> _settle(BuildContext context, WidgetRef ref) async {
    showLoadingModal(context);
    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/personality/billing/me/settle');
      ref.invalidate(personalityBillingProvider);
      if (context.mounted) showSnackBar('aiConsoleBillingSettled'.tr());
    } catch (e) {
      if (context.mounted) showErrorAlert(e);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }
}

class _CredentialsTab extends ConsumerWidget {
  const _CredentialsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creds = ref.watch(personalityCredentialsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: FilledButton.icon(
            onPressed: () => _showCreateSheet(context, ref),
            icon: const Icon(Symbols.add),
            label: Text('aiConsoleCredentialCreate'.tr()),
          ),
        ),
        Expanded(
          child: creds.when(
            data: (list) => list.isEmpty
                ? const Center(child: _EmptyNote())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CredentialCard(credential: list[i]),
                    ),
                  ),
            error: (e, _) => ResponseErrorWidget(
              error: e,
              onRetry: () => ref.invalidate(personalityCredentialsProvider),
            ),
            loading: () => const ResponseLoadingWidget(),
          ),
        ),
      ],
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _CreateCredentialSheet(),
    );
  }
}

class _CredentialCard extends ConsumerWidget {
  final SnPersonalityCredential credential;
  const _CredentialCard({required this.credential});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final created = DateFormat.yMMMd().add_Hm().format(credential.createdAt);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Symbols.key,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(credential.name, style: theme.textTheme.titleMedium),
                  Text(
                    '${'aiConsoleCredentialTokenPrefix'.tr()}: ${credential.tokenPrefix}',
                    style: theme.textTheme.labelSmall,
                  ),
                  Text(
                    '${'aiConsoleCredentialUsage'.tr()}: ${credential.usageUsed} / ${credential.usageLimit} ${_localizeCurrency(credential.usageCurrency)}',
                    style: theme.textTheme.labelSmall,
                  ),
                  Text(
                    '${'aiConsoleCredentialCreatedAt'.tr()}: $created',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Symbols.delete_forever, color: Colors.red),
              onPressed: () => _revoke(context, ref, credential),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    SnPersonalityCredential c,
  ) async {
    final confirm = await showConfirmAlert(
      'aiConsoleCredentialRevokeConfirm'.tr(),
      'aiConsoleCredentialRevoke'.tr(),
      isDanger: true,
    );
    if (!confirm || !context.mounted) return;
    showLoadingModal(context);
    try {
      final dio = ref.read(apiClientProvider);
      await dio.delete(
        '/personality/openai/credentials/${Uri.encodeComponent(c.id)}',
      );
      ref.invalidate(personalityCredentialsProvider);
      if (context.mounted) showSnackBar('settingsSaved'.tr());
    } catch (e) {
      if (context.mounted) showErrorAlert(e);
    } finally {
      if (context.mounted) hideLoadingModal(context);
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

    return SheetScaffold(
      titleText: 'aiConsoleCredentialCreate'.tr(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: createdToken.value != null
            ? _TokenReveal(
                token: createdToken.value!,
                onDone: () => Navigator.of(context).pop(),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'aiConsoleCredentialName'.tr(),
                    ),
                  ),
                  TextField(
                    controller: limit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'aiConsoleCredentialUsageLimit'.tr(),
                    ),
                  ),
                  TextField(
                    controller: currency,
                    decoration: InputDecoration(
                      labelText: 'aiConsoleCredentialCurrency'.tr(),
                    ),
                  ),
                  const Gap(8),
                  FilledButton(
                    onPressed: submitting.value
                        ? null
                        : () async {
                            if (name.text.trim().isEmpty) {
                              showErrorAlert('aiConsoleCredentialName'.tr());
                              return;
                            }
                            submitting.value = true;
                            showLoadingModal(context);
                            try {
                              final dio = ref.read(apiClientProvider);
                              final resp = await dio.post(
                                '/personality/openai/credentials',
                                data: {
                                  'name': name.text.trim(),
                                  'usage_limit': limit.text.trim(),
                                  'usage_currency':
                                      currency.text.trim().toUpperCase(),
                                },
                              );
                              final created =
                                  SnPersonalityCredentialCreated.fromJson(
                                resp.data as Map<String, dynamic>,
                              );
                              if (context.mounted) {
                                hideLoadingModal(context);
                                ref.invalidate(
                                  personalityCredentialsProvider,
                                );
                                createdToken.value = created.token;
                              }
                            } catch (e) {
                              if (context.mounted) hideLoadingModal(context);
                              if (context.mounted) showErrorAlert(e);
                            } finally {
                              if (context.mounted) {
                                hideLoadingModal(context);
                              }
                              submitting.value = false;
                            }
                          },
                    child: Text('aiConsoleCredentialCreate'.tr()),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TokenReveal extends StatelessWidget {
  final String token;
  final VoidCallback onDone;
  const _TokenReveal({required this.token, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Icon(Symbols.key, size: 40, color: theme.colorScheme.primary),
        Text(
          'aiConsoleCredentialTokenTitle'.tr(),
          style: theme.textTheme.titleMedium,
        ),
        Text(
          'aiConsoleCredentialTokenBody'.tr(),
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const Gap(4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            token,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const Gap(4),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: token)),
                    icon: const Icon(Symbols.content_copy),
                label: Text('aiConsoleCredentialCopyToken'.tr()),
              ),
            ),
            const Gap(8),
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
