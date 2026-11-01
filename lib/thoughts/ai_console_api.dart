import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';

// ---------------------------------------------------------------------------
// Models — the console side of the `/persona` backend: the model catalogue, the
// account's billing standing, and the audit the spend is read through.
//
// These are plain `fromJson` mirrors for the same reason the conversation
// models are: the typed SDK does not cover this service.
// ---------------------------------------------------------------------------

/// What one model call is priced at, per million tokens.
@immutable
class SnPersonaModelPricing {
  const SnPersonaModelPricing({this.currency, this.input, this.output});

  final String? currency;
  final String? input;
  final String? output;

  factory SnPersonaModelPricing.fromJson(Map<String, dynamic> json) =>
      SnPersonaModelPricing(
        currency: json['currency']?.toString(),
        input: json['input']?.toString(),
        output: json['output']?.toString(),
      );
}

/// One model an agent can be run against (`GET /persona/models`).
@immutable
class SnPersonaModel {
  const SnPersonaModel({
    required this.id,
    required this.provider,
    required this.name,
    this.type,
    this.modalities = const [],
    this.pricing,
  });

  final String id;
  final String provider;
  final String name;
  final String? type;
  final List<String> modalities;
  final SnPersonaModelPricing? pricing;

  /// Whether the model reads images, which is what decides whether a picked
  /// picture reaches it or is described to it.
  bool get readsImages => modalities.contains('image');

  factory SnPersonaModel.fromJson(Map<String, dynamic> json) => SnPersonaModel(
    id: json['id']?.toString() ?? '',
    provider: json['provider']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    type: json['type']?.toString(),
    modalities:
        (json['modalities'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    pricing: json['pricing'] is Map
        ? SnPersonaModelPricing.fromJson(
            Map<String, dynamic>.from(json['pricing'] as Map),
          )
        : null,
  );
}

/// What the account consumed in one interval, per currency. A null [max] is
/// "no limit configured", not "unknown".
@immutable
class SnPersonaRunUsage {
  const SnPersonaRunUsage({required this.used, this.max});

  final String used;
  final String? max;

  factory SnPersonaRunUsage.fromJson(Map<String, dynamic> json) =>
      SnPersonaRunUsage(
        used: (json['used'] ?? '0').toString(),
        max: json['max']?.toString(),
      );
}

/// The hourly and daily meters (`GET /persona/billing/me`).
@immutable
class SnPersonaBillingUsage {
  const SnPersonaBillingUsage({
    this.hourly = const {},
    this.daily = const {},
  });

  final Map<String, SnPersonaRunUsage> hourly;
  final Map<String, SnPersonaRunUsage> daily;

  factory SnPersonaBillingUsage.fromJson(Map<String, dynamic> json) {
    Map<String, SnPersonaRunUsage> parse(dynamic raw) {
      if (raw is! Map) return const {};
      return {
        for (final entry in raw.entries)
          entry.key.toString(): SnPersonaRunUsage.fromJson(
            Map<String, dynamic>.from(entry.value as Map? ?? const {}),
          ),
      };
    }

    return SnPersonaBillingUsage(
      hourly: parse(json['hourly_usage']),
      daily: parse(json['daily_usage']),
    );
  }
}

/// The account's standing: whether it may run at all, and what it has spent.
@immutable
class SnPersonaBilling {
  const SnPersonaBilling({
    this.spendingQuota,
    this.blacklisted = false,
    this.usage = const SnPersonaBillingUsage(),
  });

  final String? spendingQuota;

  /// The server refuses runs until the outstanding usage is settled.
  final bool blacklisted;

  final SnPersonaBillingUsage usage;

  factory SnPersonaBilling.fromJson(Map<String, dynamic> json) =>
      SnPersonaBilling(
        spendingQuota: json['spending_quota']?.toString(),
        blacklisted: json['blacklisted'] == true,
        usage: SnPersonaBillingUsage.fromJson(
          Map<String, dynamic>.from(json['usage'] as Map? ?? const {}),
        ),
      );
}

/// One charge in the account's ledger, as the audit reads it.
@immutable
class SnLedgerEntry {
  const SnLedgerEntry({
    required this.id,
    required this.action,
    required this.surface,
    required this.model,
    required this.currency,
    this.threadId,
    this.agentId,
    this.clientIp = '',
    this.deviceId = '',
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.originalAmount = '0',
    this.createdAt,
  });

  final String id;
  final String action;
  final String surface;
  final String model;
  final String currency;
  final String? threadId;
  final String? agentId;
  final String clientIp;
  final String deviceId;
  final int inputTokens;
  final int outputTokens;

  /// The price the usage was incurred at. A row's `amount` shrinks as a
  /// partial payment settles it, so an audit reads this one.
  final String originalAmount;

  final DateTime? createdAt;

  factory SnLedgerEntry.fromJson(Map<String, dynamic> json) => SnLedgerEntry(
    id: json['id']?.toString() ?? '',
    action: json['action']?.toString() ?? '',
    surface: json['surface']?.toString() ?? '',
    model: json['model']?.toString() ?? '',
    currency: json['currency']?.toString() ?? '',
    threadId: _optionalText(json['thread_id']),
    agentId: _optionalText(json['agent_id']),
    clientIp: json['client_ip']?.toString() ?? '',
    deviceId: json['device_id']?.toString() ?? '',
    inputTokens: _jsonInt(json['input_tokens']),
    outputTokens: _jsonInt(json['output_tokens']),
    originalAmount: json['original_amount']?.toString() ?? '0',
    createdAt: DateTime.tryParse(
      json['created_at']?.toString() ?? '',
    )?.toLocal(),
  );
}

/// One line of the spend breakdown: how much a single key consumed.
///
/// Every bucket is single-currency, because adding golds to bits means
/// nothing; a key that spans currencies yields one bucket per currency.
@immutable
class SnLedgerBucket {
  const SnLedgerBucket({
    required this.key,
    required this.currency,
    this.entries = 0,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.amount = '0',
  });

  final String key;
  final String currency;
  final int entries;
  final int inputTokens;
  final int outputTokens;
  final String amount;

  factory SnLedgerBucket.fromJson(Map<String, dynamic> json) => SnLedgerBucket(
    key: json['key']?.toString() ?? '',
    currency: json['currency']?.toString() ?? '',
    entries: _jsonInt(json['entries']),
    inputTokens: _jsonInt(json['input_tokens']),
    outputTokens: _jsonInt(json['output_tokens']),
    amount: json['amount']?.toString() ?? '0',
  );

  static List<SnLedgerBucket> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final entry in raw.whereType<Map>())
        SnLedgerBucket.fromJson(Map<String, dynamic>.from(entry)),
    ];
  }
}

/// What the account consumed in the window, split along every audit dimension
/// at once — which is what lets a reader find the call that spent the money
/// without knowing which dimension it belongs to.
@immutable
class SnLedgerSummary {
  const SnLedgerSummary({
    this.entries = 0,
    this.byAction = const [],
    this.bySurface = const [],
    this.byModel = const [],
    this.byCurrency = const [],
    this.byClientIp = const [],
    this.byDeviceId = const [],
    this.byCredential = const [],
    this.byDay = const [],
  });

  final int entries;
  final List<SnLedgerBucket> byAction;
  final List<SnLedgerBucket> bySurface;
  final List<SnLedgerBucket> byModel;
  final List<SnLedgerBucket> byCurrency;
  final List<SnLedgerBucket> byClientIp;
  final List<SnLedgerBucket> byDeviceId;
  final List<SnLedgerBucket> byCredential;
  final List<SnLedgerBucket> byDay;

  factory SnLedgerSummary.fromJson(Map<String, dynamic> json) =>
      SnLedgerSummary(
        entries: _jsonInt(json['entries']),
        byAction: SnLedgerBucket.listFrom(json['by_action']),
        bySurface: SnLedgerBucket.listFrom(json['by_surface']),
        byModel: SnLedgerBucket.listFrom(json['by_model']),
        byCurrency: SnLedgerBucket.listFrom(json['by_currency']),
        byClientIp: SnLedgerBucket.listFrom(json['by_client_ip']),
        byDeviceId: SnLedgerBucket.listFrom(json['by_device_id']),
        byCredential: SnLedgerBucket.listFrom(json['by_credential']),
        byDay: SnLedgerBucket.listFrom(json['by_day']),
      );
}

/// What the audit is narrowed to: a rolling window, and at most one breakdown
/// key the reader tapped. Rolling rather than calendar days, because a charge
/// is metered when it happens, not at a day boundary.
@immutable
class SnLedgerQuery {
  const SnLedgerQuery({this.days = 7, this.key, this.value});

  final int days;

  /// The breakdown dimension the reader narrowed to — `action`, `surface`,
  /// `device`, `ip` or `credential` — and the key within it.
  final String? key;
  final String? value;

  SnLedgerQuery narrowed(String key, String value) =>
      SnLedgerQuery(days: days, key: key, value: value);

  Map<String, dynamic> toQueryParameters() => {
    'take': 50,
    'from': DateTime.now().toUtc().subtract(Duration(days: days)).toIso8601String(),
    if (key == 'action' && value != null) 'action': value!,
    if (key == 'surface' && value != null) 'surface': value!,
    if (key == 'device' && value != null) 'device_id': value!,
    if (key == 'ip' && value != null) 'client_ip': value!,
    if (key == 'credential' && value != null) 'credential_id': value!,
  };

  @override
  bool operator ==(Object other) =>
      other is SnLedgerQuery &&
      other.days == days &&
      other.key == key &&
      other.value == value;

  @override
  int get hashCode => Object.hash(days, key, value);
}

/// One credential an OpenAI-compatible client signs in with.
@immutable
class SnPersonaCredential {
  const SnPersonaCredential({
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

  factory SnPersonaCredential.fromJson(Map<String, dynamic> json) =>
      SnPersonaCredential(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        tokenPrefix: json['token_prefix']?.toString() ?? '',
        agentIds: _stringList(json['agent_ids']),
        providers: _stringList(json['providers']),
        models: _stringList(json['models']),
        usageLimit: (json['usage_limit'] ?? '0').toString(),
        usageUsed: (json['usage_used'] ?? '0').toString(),
        usageCurrency: json['usage_currency']?.toString() ?? 'USD',
        enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
      );
}

/// A freshly created credential and the one time its token is readable.
@immutable
class SnPersonaCredentialCreated {
  const SnPersonaCredentialCreated({
    required this.credential,
    required this.token,
  });

  final SnPersonaCredential credential;
  final String token;

  factory SnPersonaCredentialCreated.fromJson(Map<String, dynamic> json) =>
      SnPersonaCredentialCreated(
        credential: SnPersonaCredential.fromJson(
          Map<String, dynamic>.from(json['credential'] as Map? ?? const {}),
        ),
        token: json['token']?.toString() ?? '',
      );
}

/// One engine a server-side search can be kept on, and what one query costs.
@immutable
class SnWebSearchEngine {
  const SnWebSearchEngine({
    required this.id,
    this.price = '',
    this.metered = false,
    this.free = false,
  });

  final String id;
  final String price;
  final bool metered;
  final bool free;

  factory SnWebSearchEngine.fromJson(Map<String, dynamic> json) =>
      SnWebSearchEngine(
        id: json['id']?.toString() ?? '',
        price: json['price']?.toString() ?? '',
        metered: json['metered'] == true,
        free: json['free'] == true,
      );
}

/// The engines to choose between, and the currency their prices are in.
@immutable
class SnWebSearchCatalog {
  const SnWebSearchCatalog({this.currency = '', this.engines = const []});

  final String currency;
  final List<SnWebSearchEngine> engines;

  factory SnWebSearchCatalog.fromJson(Map<String, dynamic> json) =>
      SnWebSearchCatalog(
        currency: json['currency']?.toString() ?? '',
        engines: [
          for (final entry in (json['engines'] as List? ?? const [])
              .whereType<Map>())
            SnWebSearchEngine.fromJson(Map<String, dynamic>.from(entry)),
        ],
      );
}

/// The account's chosen engine. Empty means the server's own order decides.
@immutable
class SnWebSearchPreference {
  const SnWebSearchPreference({this.engine = '', this.currency = ''});

  final String engine;
  final String currency;

  factory SnWebSearchPreference.fromJson(Map<String, dynamic> json) =>
      SnWebSearchPreference(
        engine: json['engine']?.toString() ?? '',
        currency: json['currency']?.toString() ?? '',
      );
}

/// The engine choice as one read: what to choose between, and the choice.
@immutable
class SnWebSearchChoice {
  const SnWebSearchChoice({required this.catalog, required this.preference});

  final SnWebSearchCatalog catalog;
  final SnWebSearchPreference preference;
}

String? _optionalText(dynamic raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int _jsonInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw?.toString() ?? '') ?? 0;
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return [for (final item in raw) if (item != null) item.toString()];
}

DateTime _date(dynamic raw) =>
    DateTime.tryParse(raw?.toString() ?? '')?.toLocal() ??
    DateTime.fromMillisecondsSinceEpoch(0);

// ---------------------------------------------------------------------------
// Providers
//
// Every read goes through [apiClientProvider], the app's account-authenticated
// client, so the console sees exactly what the account's own conversation
// surface sees.
// ---------------------------------------------------------------------------

/// The models an agent can be run against.
final personaModelsProvider = FutureProvider<List<SnPersonaModel>>((ref) async {
  final resp = await ref.watch(apiClientProvider).get('/persona/models');
  final data = resp.data;
  if (data is! List) return const [];
  return [
    for (final entry in data.whereType<Map>())
      SnPersonaModel.fromJson(Map<String, dynamic>.from(entry)),
  ];
});

/// The account's billing standing and meters.
final personaBillingProvider = FutureProvider<SnPersonaBilling>((ref) async {
  final resp = await ref.watch(apiClientProvider).get('/persona/billing/me');
  return SnPersonaBilling.fromJson(
    Map<String, dynamic>.from(resp.data as Map? ?? const {}),
  );
});

/// The window's spend along every audit dimension. The reader's filter is
/// deliberately not part of this: the breakdown is the overview a filter is
/// chosen from, so narrowing the list must not narrow the breakdown with it.
final personaLedgerSummaryProvider =
    FutureProvider.family<SnLedgerSummary, SnLedgerQuery>((ref, query) async {
      final resp = await ref
          .watch(apiClientProvider)
          .get(
            '/persona/billing/me/ledger/summary',
            queryParameters: query.toQueryParameters(),
          );
      return SnLedgerSummary.fromJson(
        Map<String, dynamic>.from(resp.data as Map? ?? const {}),
      );
    });

/// The account's charges in the window, newest first, narrowed by whatever the
/// reader picked from the breakdown.
final personaBillingLedgerProvider =
    FutureProvider.family<List<SnLedgerEntry>, SnLedgerQuery>((ref, query) async {
      final resp = await ref
          .watch(apiClientProvider)
          .get(
            '/persona/billing/me/ledger',
            queryParameters: query.toQueryParameters(),
          );
      final data = resp.data;
      if (data is! List) return const [];
      return [
        for (final entry in data.whereType<Map>())
          SnLedgerEntry.fromJson(Map<String, dynamic>.from(entry)),
      ];
    });

/// The engines a search can be kept on, and the one this account is on — read
/// together because the picker needs both to draw a single choice.
final personaSearchChoiceProvider = FutureProvider<SnWebSearchChoice>((
  ref,
) async {
  final dio = ref.watch(apiClientProvider);
  final responses = await Future.wait([
    dio.get('/persona/web/search/engines'),
    dio.get('/persona/web/search/preference'),
  ]);
  return SnWebSearchChoice(
    catalog: SnWebSearchCatalog.fromJson(
      Map<String, dynamic>.from(responses[0].data as Map? ?? const {}),
    ),
    preference: SnWebSearchPreference.fromJson(
      Map<String, dynamic>.from(responses[1].data as Map? ?? const {}),
    ),
  );
});

/// The OpenAI-compatible credentials the account has handed out.
final personaCredentialsProvider =
    FutureProvider<List<SnPersonaCredential>>((ref) async {
      final resp = await ref
          .watch(apiClientProvider)
          .get('/persona/openai/credentials');
      final data = resp.data;
      final list = data is Map ? data['data'] : data;
      if (list is! List) return const [];
      return [
        for (final entry in list.whereType<Map>())
          SnPersonaCredential.fromJson(Map<String, dynamic>.from(entry)),
      ];
    });

/// Writes one setting back and refreshes the read that drew it.
Future<void> saveSpendingQuota(
  ProviderContainer container,
  String quota,
) async {
  await container
      .read(apiClientProvider)
      .put('/persona/billing/me/spending-quota', data: {'spending_quota': quota});
  container.invalidate(personaBillingProvider);
}

/// Settles the outstanding usage with the account's wallet.
Future<void> settleBilling(ProviderContainer container) async {
  await container.read(apiClientProvider).post('/persona/billing/me/settle');
  container.invalidate(personaBillingProvider);
}

/// Keeps a server-side search on [engine]; an empty value returns the choice to
/// the server's own order.
Future<void> saveSearchEngine(
  ProviderContainer container,
  String engine,
) async {
  await container
      .read(apiClientProvider)
      .put('/persona/web/search/preference', data: {'engine': engine});
  container.invalidate(personaSearchChoiceProvider);
}

/// Issues one credential, returning the token its holder can never read again.
Future<SnPersonaCredentialCreated> createCredential(
  ProviderContainer container, {
  required String name,
  required String usageLimit,
  required String usageCurrency,
}) async {
  final resp = await container
      .read(apiClientProvider)
      .post(
        '/persona/openai/credentials',
        data: {
          'name': name,
          'usage_limit': usageLimit,
          'usage_currency': usageCurrency,
        },
      );
  container.invalidate(personaCredentialsProvider);
  return SnPersonaCredentialCreated.fromJson(
    Map<String, dynamic>.from(resp.data as Map? ?? const {}),
  );
}

/// Revokes one credential. Its token stops working immediately.
Future<void> revokeCredential(ProviderContainer container, String id) async {
  await container
      .read(apiClientProvider)
      .delete('/persona/openai/credentials/${Uri.encodeComponent(id)}');
  container.invalidate(personaCredentialsProvider);
}

/// Whether [error] is the account being refused rather than a failed request.
bool isPersonaUnauthorized(Object error) =>
    error is DioException &&
    (error.response?.statusCode == 401 || error.response?.statusCode == 403);
