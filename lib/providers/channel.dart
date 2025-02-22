import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/database/database.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/realm.dart';

class ChatChannelProvider extends ChangeNotifier {
  static const kChatChannelBoxName = 'nex_chat_channels';

  late final SnNetworkProvider _sn;
  late final UserDirectoryProvider _ud;
  late final DatabaseProvider _dt;

  ChatChannelProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _ud = context.read<UserDirectoryProvider>();
    _dt = context.read<DatabaseProvider>();
  }

  Future<void> _saveChannelToLocal(Iterable<SnChannel> channels) async {
    await Future.wait(
      channels.map(
        (ele) => _dt.db.snLocalChatChannel.insertOne(
          SnLocalChatChannelCompanion.insert(
            id: Value(ele.id),
            alias: ele.key,
            content: ele,
            createdAt: Value(ele.createdAt),
          ),
          onConflict: DoUpdate(
            (_) => SnLocalChatChannelCompanion.custom(
              content: Constant(jsonEncode(ele.toJson())),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<SnChannel>> _fetchChannelsFromServer({
    String scope = 'global',
    bool direct = false,
    bool doNotSave = false,
  }) async {
    final resp = await _sn.client.get(
      '/cgi/im/channels/$scope/me/available',
      queryParameters: {
        'direct': direct,
      },
    );
    final out = List<SnChannel>.from(
      resp.data?.map((e) => SnChannel.fromJson(e)) ?? [],
    );
    if (!doNotSave) _saveChannelToLocal(out);
    return out;
  }

  /// The get channel method will return the channel with the given alias.
  /// It will use the local storage as much as possible.
  /// The alias should include the scope, formatted as `scope:alias`.
  Future<SnChannel> getChannel(String key) async {
    final local = await (_dt.db.snLocalChatChannel.select()
          ..where((e) => e.alias.equals(key)))
        .getSingleOrNull();
    if (local != null) return local.content;

    var resp =
        await _sn.client.get('/cgi/im/channels/${key.replaceAll(':', '/')}');
    var out = SnChannel.fromJson(resp.data);

    // Preload realm of the channel
    if (out.realmId != null) {
      resp = await _sn.client.get('/cgi/id/realms/${out.realmId}');
      out = out.copyWith(realm: SnRealm.fromJson(resp.data));
    }

    _saveChannelToLocal([out]);
    return out;
  }

  /// The fetch channel method return a stream, which will emit twice.
  /// The first time is when the data was fetched from the local storage.
  /// And the second time is when the data was fetched from the server.
  /// But there is some exception that will only cause one of them to be emitted.
  /// Like the local storage is broken or the server is down.
  Stream<List<SnChannel>> fetchChannels(
      {bool noRemote = false, bool noLocal = false}) async* {
    if (!noLocal) {
      final local = await (_dt.db.snLocalChatChannel.select()
            ..orderBy([
              (e) =>
                  OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc)
            ]))
          .get();
      yield local.map((e) => e.content).toList();
    }

    if (noRemote) return;

    var resp = await _sn.client.get('/cgi/id/realms/me/available');
    final realms = List<SnRealm>.from(
      resp.data?.map((e) => SnRealm.fromJson(e)) ?? [],
    );
    final realmMap = {
      for (final realm in realms) realm.alias: realm,
    };

    final scopeToFetch = {'global', ...realms.map((e) => e.alias)};

    final List<SnChannel> result = List.empty(growable: true);
    final directMessages = await _fetchChannelsFromServer(
      scope: scopeToFetch.first,
      direct: true,
    );
    result.addAll(directMessages);

    final nonBelongsChannels = await _fetchChannelsFromServer(
      scope: scopeToFetch.first,
      direct: false,
    );
    result.addAll(nonBelongsChannels);

    for (final scope in scopeToFetch.skip(1)) {
      final channel = await _fetchChannelsFromServer(
        scope: scope,
        direct: false,
        doNotSave: true,
      );
      final out = channel.map((ele) => ele.copyWith(realm: realmMap[scope]));
      _saveChannelToLocal(out);
      result.addAll(out);
    }

    yield result;
  }

  Future<List<SnChatMessage>> getLastMessages(
    Iterable<SnChannel> channels,
  ) async {
    final result = List<Future<SnLocalChatMessageData?>>.empty(growable: true);
    for (final channel in channels) {
      final out = (_dt.db.snLocalChatMessage.select()
            ..where((e) => e.channelId.equals(channel.id))
            ..orderBy([
              (e) =>
                  OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc)
            ])
            ..limit(1))
          .getSingleOrNull();
      result.add(out);
    }
    final out = (await Future.wait(result))
        .where((e) => e != null)
        .map((e) => e!.content)
        .toList();
    await _ud.listAccount(out.map((ele) => ele.sender.accountId).toSet());
    return out;
  }
}
