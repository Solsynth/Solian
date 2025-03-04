import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/database/database.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/account.dart';

class UserDirectoryProvider {
  late final SnNetworkProvider _sn;
  late final DatabaseProvider _dt;

  UserDirectoryProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _dt = context.read<DatabaseProvider>();
  }

  final Map<String, int> _idCache = {};
  final Map<int, SnAccount> _cache = {};

  Future<int> loadAccountCache({int max = 100}) async {
    final out = await (_dt.db.snLocalAccount.select()..limit(max)).get();
    for (final ele in out) {
      _cache[ele.id] = ele.content;
      _idCache[ele.name] = ele.id;
    }
    return out.length;
  }

  Future<List<SnAccount?>> listAccount(Iterable<dynamic> id) async {
    // In-memory cache
    final out = List<SnAccount?>.generate(id.length, (e) => null);
    final plannedQuery = <int>{};
    for (var idx = 0; idx < out.length; idx++) {
      var item = id.elementAt(idx);
      if (item is String && _idCache.containsKey(item)) {
        item = _idCache[item];
      }
      if (_cache.containsKey(item)) {
        out[idx] = _cache[item];
      } else {
        plannedQuery.add(item);
      }
    }
    // On-disk cache
    if (plannedQuery.isEmpty) return out;
    final dbResp = await (_dt.db.snLocalAccount.select()
          ..where((e) => e.id.isIn(plannedQuery))
          ..where((e) => e.cacheExpiredAt.isBiggerThanValue(DateTime.now()))
          ..limit(plannedQuery.length))
        .get();
    for (var idx = 0; idx < out.length; idx++) {
      if (out[idx] != null) continue;
      if (dbResp.length <= idx) {
        break;
      }
      out[idx] = dbResp[idx].content;
      _cache[dbResp[idx].id] = dbResp[idx].content;
      _idCache[dbResp[idx].name] = dbResp[idx].id;
      plannedQuery.remove(dbResp[idx].id);
    }
    // Remote server
    if (plannedQuery.isEmpty) return out;
    final resp = await _sn.client
        .get('/cgi/id/users', queryParameters: {'id': plannedQuery.join(',')});
    final respDecoded =
        resp.data.map((e) => SnAccount.fromJson(e)).cast<SnAccount>().toList();
    var sideIdx = 0;
    for (var idx = 0; idx < out.length; idx++) {
      if (out[idx] != null) continue;
      if (respDecoded.length <= sideIdx) {
        break;
      }
      out[idx] = respDecoded[sideIdx];
      _cache[respDecoded[sideIdx].id] = out[idx]!;
      _idCache[respDecoded[sideIdx].name] = respDecoded[sideIdx].id;
      sideIdx++;
    }
    if (respDecoded.isNotEmpty) _saveToLocal(respDecoded);
    return out;
  }

  Future<SnAccount?> getAccount(dynamic id) async {
    // In-memory cache
    if (id is String && _idCache.containsKey(id)) {
      id = _idCache[id];
    }
    if (_cache.containsKey(id)) {
      return _cache[id];
    }
    // On-disk cache
    final dbResp = await (_dt.db.snLocalAccount.select()
          ..where((e) => e.id.equals(id))
          ..where((e) => e.cacheExpiredAt.isBiggerThanValue(DateTime.now())))
        .getSingleOrNull();
    if (dbResp != null) {
      _cache[dbResp.id] = dbResp.content;
      _idCache[dbResp.name] = dbResp.id;
      return dbResp.content;
    }
    // Remote server
    try {
      final resp = await _sn.client.get('/cgi/id/users/$id');
      final account = SnAccount.fromJson(
        resp.data as Map<String, dynamic>,
      );
      _cache[account.id] = account;
      if (id is String) _idCache[id] = account.id;
      _saveToLocal([account]);
      return account;
    } catch (err) {
      return null;
    }
  }

  SnAccount? getFromCache(dynamic id) {
    if (id is String && _idCache.containsKey(id)) {
      id = _idCache[id];
    }
    return _cache[id];
  }

  Future<void> _saveToLocal(Iterable<SnAccount> out) async {
    // For better on conflict resolution
    // And consider the method usually called with usually small amount of data
    // Use for to insert each record instead of bulk insert
    List<Future<int>> queries = out.map((ele) {
      return _dt.db.snLocalAccount.insertOne(
        SnLocalAccountCompanion.insert(
          id: Value(ele.id),
          name: ele.name,
          content: ele,
          cacheExpiredAt: DateTime.now().add(const Duration(hours: 1)),
        ),
        onConflict: DoUpdate(
          (_) => SnLocalAccountCompanion.custom(
            name: Constant(ele.name),
            content: Constant(jsonEncode(ele.toJson())),
          ),
        ),
      );
    }).toList();
    await Future.wait(queries);
  }
}
