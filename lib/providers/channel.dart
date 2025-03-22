import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/database/database.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_realm.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/chat.dart';

class ChatChannelProvider extends ChangeNotifier {
  static const kChatChannelBoxName = 'nex_chat_channels';

  late final SnNetworkProvider _sn;
  late final UserDirectoryProvider _ud;
  late final UserProvider _ua;
  late final DatabaseProvider _dt;
  late final SnRealmProvider _rels;

  ChatChannelProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _ud = context.read<UserDirectoryProvider>();
    _ua = context.read<UserProvider>();
    _dt = context.read<DatabaseProvider>();
    _rels = context.read<SnRealmProvider>();
  }

  final List<SnChannel> _availableChannels = List.empty(growable: true);

  List<SnChannel> get availableChannels => _availableChannels;

  Future<void> refreshAvailableChannels() async {
    final stream = fetchChannels();
    stream.listen((ele) {
      _availableChannels.clear();
      _availableChannels.addAll(ele);
      notifyListeners();
    });
  }

  void addAvailableChannel(SnChannel channel) {
    _availableChannels.add(channel);
    notifyListeners();
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
    bool doNotSave = false,
  }) async {
    final resp = await _sn.client.get('/cgi/im/channels/me/available');
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
    if (local != null) {
      final out = local.content;
      if (out.realmId != null) {
        return out.copyWith(realm: await _rels.getRealm(out.realmId!));
      } else {
        return out;
      }
    }

    var resp =
        await _sn.client.get('/cgi/im/channels/${key.replaceAll(':', '/')}');
    var out = SnChannel.fromJson(resp.data);

    // Preload realm of the channel
    if (out.realmId != null) {
      out = out.copyWith(realm: await _rels.getRealm(out.realmId!));
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
      final out = local.map((e) => e.content).toList();
      for (var idx = 0; idx < out.length; idx++) {
        final channel = out[idx];
        if (channel.realmId != null) {
          out[idx] = out[idx].copyWith(
            realm: await _rels.getRealm(channel.realmId!),
          );
        }
      }
      yield out;
    }

    if (noRemote) return;
    final List<SnChannel> result = List.empty(growable: true);
    final channels = await _fetchChannelsFromServer();
    for (var idx = 0; idx < channels.length; idx++) {
      final channel = channels[idx];
      if (channel.realmId != null) {
        channels[idx] = channels[idx].copyWith(
          realm: await _rels.getRealm(channel.realmId!),
        );
      }
    }
    result.addAll(channels);

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

  Future<void> _saveMemberToLocal(Iterable<SnChannelMember> members) async {
    final queries = members.map((ele) {
      return _dt.db.snLocalChannelMember.insertOne(
        SnLocalChannelMemberCompanion.insert(
          id: Value(ele.id),
          channelId: ele.channelId,
          accountId: ele.accountId,
          content: ele,
          cacheExpiredAt: DateTime.now().add(const Duration(days: 7)),
        ),
        onConflict: DoUpdate(
          (_) => SnLocalChannelMemberCompanion.custom(
            content: Constant(jsonEncode(ele.toJson())),
            cacheExpiredAt:
                Constant(DateTime.now().add(const Duration(days: 7))),
          ),
        ),
      );
    });
    await Future.wait(queries);
  }

  Future<void> removeLocalChannel(SnChannel channel) async {
    await _dt.db.transaction(() async {
      await (_dt.db.snLocalChannelMember.delete()
            ..where((e) => e.channelId.equals(channel.id)))
          .go();
      await (_dt.db.snLocalChatChannel.delete()
            ..where((e) => e.id.equals(channel.id)))
          .go();
      await (_dt.db.snLocalChatMessage.delete()
            ..where((e) => e.channelId.equals(channel.id)))
          .go();
    });
  }

  Future<void> updateChannelProfile(SnChannelMember member) {
    return _saveMemberToLocal([member]);
  }

  Future<SnChannelMember> getChannelProfile(SnChannel channel) async {
    if (_ua.user == null) throw Exception('User not logged in');
    final local = await (_dt.db.snLocalChannelMember.select()
          ..where((e) => e.channelId.equals(channel.id))
          ..where((e) => e.accountId.equals(_ua.user!.id)))
        .getSingleOrNull();
    if (local != null) {
      return local.content;
    }

    final resp = await _sn.client.get('/cgi/im/channels/${channel.keyPath}/me');
    final out = SnChannelMember.fromJson(resp.data);
    _saveMemberToLocal([out]);
    return out;
  }
}
