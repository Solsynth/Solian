import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/realm.dart';

class SnRealmProvider {
  late final SnNetworkProvider _sn;

  SnRealmProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
  }

  final Map<String, SnRealm> _cache = {};

  Future<List<SnRealm>> listAvailableRealms() async {
    final resp = await _sn.client.get('/cgi/id/realms/me/available');
    final out = List<SnRealm>.from(
      resp.data?.map((e) => SnRealm.fromJson(e)) ?? [],
    );
    for (final realm in out) {
      _cache[realm.alias] = realm;
      _cache[realm.id.toString()] = realm;
    }
    return out;
  }

  Future<SnRealm> getRealm(dynamic aliasOrId) async {
    if (_cache.containsKey(aliasOrId.toString())) {
      return _cache[aliasOrId.toString()]!;
    }
    final resp = await _sn.client.get('/cgi/id/realms/$aliasOrId');
    final out = SnRealm.fromJson(resp.data);
    _cache[out.alias] = out;
    _cache[out.id.toString()] = out;
    return out;
  }
}
