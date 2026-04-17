import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'call_participants.g.dart';

/// A cache for participant account data during active calls.
/// This provider keeps data alive for the duration of the call to avoid
/// repeated network requests when widgets rebuild.
@Riverpod(keepAlive: true)
class CallParticipantAccountCache extends _$CallParticipantAccountCache {
  final Map<String, AsyncValue<SnAccount>> _cache = {};
  final Map<String, DateTime> _lastFetchTime = {};
  static const Duration _cacheTTL = Duration(minutes: 5);

  @override
  Map<String, AsyncValue<SnAccount>> build() => Map.unmodifiable(_cache);

  AsyncValue<SnAccount>? get(String identity) {
    final cached = _cache[identity];
    final lastFetch = _lastFetchTime[identity];

    if (cached == null) return null;

    // Return cached value if still fresh
    if (lastFetch != null && DateTime.now().difference(lastFetch) < _cacheTTL) {
      return cached;
    }

    return null;
  }

  Future<void> fetch(String identity) async {
    // Skip if already loading or has fresh data
    final existing = _cache[identity];
    if (existing is AsyncLoading) return;

    final lastFetch = _lastFetchTime[identity];
    if (lastFetch != null &&
        DateTime.now().difference(lastFetch) < _cacheTTL &&
        existing is AsyncData) {
      return;
    }

    _cache[identity] = const AsyncLoading();
    state = Map.unmodifiable(_cache);

    try {
      final client = ref.read(solarNetworkClientProvider);
      final account = await client.accounts.getAccountByUsername(identity);
      _cache[identity] = AsyncData(account);
      _lastFetchTime[identity] = DateTime.now();
    } catch (e, st) {
      _cache[identity] = AsyncError(e, st);
    }

    state = Map.unmodifiable(_cache);
  }

  void clear() {
    _cache.clear();
    _lastFetchTime.clear();
    state = const {};
  }
}

/// A family provider that uses the cache for call participant accounts.
/// This is more efficient than accountProvider for call UI where widgets
/// rebuild frequently.
@riverpod
AsyncValue<SnAccount> callParticipantAccount(Ref ref, String identity) {
  final cache = ref.watch(callParticipantAccountCacheProvider);
  final cached = cache[identity];

  if (cached != null) {
    return cached;
  }

  // Trigger fetch and return loading state
  Future(() {
    ref.read(callParticipantAccountCacheProvider.notifier).fetch(identity);
  });

  return const AsyncLoading();
}

/// Pre-fetch multiple participant accounts at once for efficiency.
/// Useful when joining a call with multiple participants.
Future<void> prefetchParticipantAccounts(
  WidgetRef ref,
  List<String> identities,
) async {
  final cache = ref.read(callParticipantAccountCacheProvider.notifier);
  await Future.wait(identities.map((identity) => cache.fetch(identity)));
}
