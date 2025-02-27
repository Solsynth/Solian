import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/account.dart';

class UserDirectoryProvider {
  late final SnNetworkProvider _sn;

  UserDirectoryProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
  }

  final Map<String, int> _idCache = {};
  final Map<int, SnAccount> _cache = {};

  Future<List<SnAccount?>> listAccount(Iterable<dynamic> id) async {
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
    return out;
  }

  Future<SnAccount?> getAccount(dynamic id) async {
    if (id is String && _idCache.containsKey(id)) {
      id = _idCache[id];
    }
    if (_cache.containsKey(id)) {
      return _cache[id];
    }

    try {
      final resp = await _sn.client.get('/cgi/id/users/$id');
      final account = SnAccount.fromJson(
        resp.data as Map<String, dynamic>,
      );
      _cache[account.id] = account;
      if (id is String) _idCache[id] = account.id;
      return account;
    } catch (err) {
      return null;
    }
  }

  SnAccount? getAccountFromCache(dynamic id) {
    if (id is String && _idCache.containsKey(id)) {
      id = _idCache[id];
    }
    return _cache[id];
  }
}
