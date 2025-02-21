import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/realm.dart';

class SnRealmProvider {
  late final SnNetworkProvider _sn;

  SnRealmProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
  }

  Future<List<SnRealm>> listAvailableRealms() async {
    final resp = await _sn.client.get('/cgi/id/realms/me/available');
    final out = List<SnRealm>.from(
      resp.data?.map((e) => SnRealm.fromJson(e)) ?? [],
    );
    return out;
  }

  Future<SnRealm> getRealm(String alias) async {
    final resp = await _sn.client.get('/cgi/id/realms/$alias');
    final out = SnRealm.fromJson(resp.data);
    return out;
  }
}
