import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/database/database.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/realm.dart';

class SnRealmProvider {
  late final SnNetworkProvider _sn;
  late final DatabaseProvider _dt;

  SnRealmProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _dt = context.read<DatabaseProvider>();
  }

  final Map<String, SnRealm> _cache = {};
  List<SnRealm> _availableRealms = List.empty(growable: true);

  Future<void> refreshAvailableRealms() async {
    _availableRealms = await listAvailableRealms();
  }

  List<SnRealm> get availableRealms => _availableRealms;

  Future<List<SnRealm>> listAvailableRealms() async {
    final resp = await _sn.client.get('/cgi/id/realms/me/available');
    final out = List<SnRealm>.from(
      resp.data?.map((e) => SnRealm.fromJson(e)) ?? [],
    );
    for (final realm in out) {
      _cache[realm.alias] = realm;
      _cache[realm.id.toString()] = realm;
    }
    _saveToLocal(out);
    return out;
  }

  Future<SnRealm> getRealm(dynamic aliasOrId) async {
    if (_cache.containsKey(aliasOrId.toString())) {
      return _cache[aliasOrId.toString()]!;
    }
    final localResp = await (_dt.db.snLocalRealm.select()
          ..where((e) =>
              e.id.equals(aliasOrId is int ? aliasOrId : 0) |
              e.alias.equals(aliasOrId.toString()))
          ..where((e) => e.cacheExpiredAt.isBiggerThanValue(DateTime.now())))
        .getSingleOrNull();
    if (localResp != null) {
      _cache[localResp.content.id.toString()] = localResp.content;
      _cache[localResp.content.alias] = localResp.content;
      return localResp.content;
    }
    final resp = await _sn.client.get('/cgi/id/realms/$aliasOrId');
    final out = SnRealm.fromJson(resp.data);
    _cache[out.alias] = out;
    _cache[out.id.toString()] = out;
    _saveToLocal([out]);
    return out;
  }

  Future<void> _saveToLocal(Iterable<SnRealm> out) async {
    for (final ele in out) {
      await _dt.db.snLocalRealm.insertOne(
        SnLocalRealmCompanion.insert(
          id: Value(ele.id),
          alias: ele.alias,
          content: ele,
          accountId: ele.accountId,
          cacheExpiredAt: DateTime.now().add(const Duration(hours: 1)),
        ),
        onConflict: DoUpdate(
          (_) => SnLocalRealmCompanion.custom(
            content: Constant(jsonEncode(ele.toJson())),
            cacheExpiredAt:
                Constant(DateTime.now().add(const Duration(hours: 1))),
          ),
        ),
      );
    }
  }
}
