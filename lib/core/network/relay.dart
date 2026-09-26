import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

/// SharedPreferences key holding the selected [RelayRoute] as JSON.
///
/// Absent when traffic goes straight to the configured server. The model, the
/// catalog client, and the dial logic live in `solar_network_foundation` so
/// other Solar Network clients can route through the same relays.
const kNetworkRelayRouteStoreKey = 'app_relay_route';

/// Reads the persisted relay route, ignoring malformed values.
RelayRoute? readRelayRoute(SharedPreferences prefs) {
  final raw = prefs.getString(kNetworkRelayRouteStoreKey);
  if (raw == null || raw.isEmpty) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final route = RelayRoute.fromJson(Map<String, dynamic>.from(decoded));
    return route.isValid ? route : null;
  } catch (error) {
    Logger.root.warning('[relay] Ignoring malformed relay route: $error');
    return null;
  }
}

class RelayRouteNotifier extends Notifier<RelayRoute?> {
  @override
  RelayRoute? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return readRelayRoute(prefs);
  }

  /// Selects [route], or clears the selection when null (direct traffic).
  void select(RelayRoute? route) {
    final prefs = ref.read(sharedPreferencesProvider);
    if (route == null || !route.isValid) {
      prefs.remove(kNetworkRelayRouteStoreKey);
      state = null;
      return;
    }
    prefs.setString(kNetworkRelayRouteStoreKey, jsonEncode(route.toJson()));
    state = route;
  }
}

/// The relay every HTTP client in the app dials through, or null for direct.
///
/// The logical server URL is untouched: only the socket is re-routed, so SNI,
/// `Host`, and certificate verification still belong to the configured server.
final relayRouteProvider = NotifierProvider<RelayRouteNotifier, RelayRoute?>(
  RelayRouteNotifier.new,
);

/// Relays announced by the configured server through `GET /relays`.
///
/// Loaded over a direct connection — a selected relay must never be able to
/// hide its own picker. Refresh with `ref.invalidate(relayCatalogProvider)`.
final relayCatalogProvider = FutureProvider<List<RelayEntry>>((ref) {
  final serverUrl = ref.watch(serverUrlProvider);
  return fetchRelayCatalog(serverUrl);
});
