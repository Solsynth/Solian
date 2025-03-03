import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/database/database.dart';
import 'package:surface/logger.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/websocket.dart';
import 'package:surface/types/keypair.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:surface/types/websocket.dart';
import 'package:uuid/uuid.dart';

// Currently the keypair only provide RSA encryption
// Supported by the `fast_rsa` package
class KeyPairProvider {
  late final DatabaseProvider _dt;
  late final UserProvider _ua;
  late final WebSocketProvider _ws;

  SnKeyPair? activeKp;

  KeyPairProvider(BuildContext context) {
    _dt = context.read<DatabaseProvider>();
    _ua = context.read<UserProvider>();
    _ws = context.read<WebSocketProvider>();
  }

  void listen() {
    _ws.pk.stream.listen((event) {
      switch (event.method) {
        case 'kex.ack':
          ackKeyExchange(event);
          break;
        case 'key.ask':
          replyAskKeyExchange(event);
          break;
      }
    });
  }

  Future<String> decryptText(String text, String kpId) async {
    final kp = await (_dt.db.snLocalKeyPair.select()
          ..where((e) => e.id.equals(kpId)))
        .getSingleOrNull();
    if (kp == null) throw Exception('Key pair not found');
    return await RSA.decryptPKCS1v15(text, kp.privateKey!);
  }

  Future<String> encryptText(String text) async {
    if (activeKp == null) throw Exception('No active key pair');
    return await RSA.encryptPKCS1v15(text, activeKp!.publicKey);
  }

  final Map<String, Completer<SnKeyPair>> _requests = {};

  Future<SnKeyPair> askKeyExchange(int kpOwner, String kpId) async {
    if (_requests.containsKey(kpId)) return await _requests[kpId]!.future;

    final completer = Completer<SnKeyPair>();
    _requests[kpId] = completer;

    _ws.conn?.sink.add(
      jsonEncode(WebSocketPackage(
        method: 'key.ask',
        endpoint: 'id',
        payload: {
          'keypair_id': kpId,
          'user_id': kpOwner,
        },
      )),
    );

    return Future.any([
      _requests[kpId]!.future,
      Future.delayed(const Duration(seconds: 60), () {
        _requests.remove(kpId);
        throw TimeoutException("Key exchange timed out");
      }),
    ]);
  }

  Future<void> ackKeyExchange(WebSocketPackage pkt) async {
    if (pkt.payload == null) return;
    final kpMeta = SnKeyPair(
      id: pkt.payload!['keypair_id'] as String,
      accountId: pkt.payload!['user_id'] as int,
      publicKey: pkt.payload!['public_key'] as String,
      privateKey: pkt.payload?['private_key'] as String?,
    );

    if (_requests.containsKey(kpMeta.id)) {
      _requests[kpMeta.id]!.complete(kpMeta);
      _requests.remove(kpMeta.id);
    }

    // Save the keypair to the local database
    await _dt.db.snLocalKeyPair.insertOne(
      SnLocalKeyPairCompanion.insert(
        id: kpMeta.id,
        accountId: kpMeta.accountId,
        publicKey: kpMeta.publicKey,
        privateKey: Value(kpMeta.privateKey),
      ),
      onConflict: DoUpdate(
        (_) => SnLocalKeyPairCompanion.custom(
          publicKey: Constant(kpMeta.publicKey),
          privateKey: Constant(kpMeta.privateKey),
        ),
      ),
    );
  }

  Future<void> replyAskKeyExchange(WebSocketPackage pkt) async {
    final kpId = pkt.payload!['keypair_id'] as String;
    final userId = pkt.payload!['user_id'] as int;
    final clientId = pkt.payload!['client_id'] as String;

    final localKp = await (_dt.db.snLocalKeyPair.select()
          ..where((e) => e.id.equals(kpId))
          ..limit(1))
        .getSingleOrNull();
    if (localKp == null) return;

    logging.info(
      '[Kex] Reply to key exchange request of $kpId from user $userId',
    );

    // We do not give the private key to the client
    _ws.conn?.sink.add(jsonEncode(
      WebSocketPackage(
        method: 'kex.ack',
        endpoint: 'id',
        payload: {
          'keypair_id': localKp.id,
          'user_id': localKp.accountId,
          'public_key': localKp.publicKey,
          'client_id': clientId,
        },
      ).toJson(),
    ));
  }

  Future<SnKeyPair?> reloadActive({bool autoEnroll = true}) async {
    final kp = await (_dt.db.snLocalKeyPair.select()
          ..where((e) => e.accountId.equals(_ua.user!.id))
          ..where((e) => e.privateKey.isNotNull())
          ..where((e) => e.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();

    if (kp != null) {
      activeKp = SnKeyPair(
        id: kp.id,
        accountId: kp.accountId,
        publicKey: kp.publicKey,
        privateKey: kp.privateKey,
      );
    }

    if (kp == null && autoEnroll) {
      return await enrollNew();
    }

    return activeKp;
  }

  Future<List<SnKeyPair>> listKeyPair() async {
    final kps = await (_dt.db.snLocalKeyPair.select()).get();
    return kps
        .map((e) => SnKeyPair(
              id: e.id,
              accountId: e.accountId,
              publicKey: e.publicKey,
              privateKey: e.privateKey,
              isActive: e.isActive,
            ))
        .toList();
  }

  Future<void> activeKeyPair(String kpId) async {
    final kp = await (_dt.db.snLocalKeyPair.select()
          ..where((e) => e.id.equals(kpId))
          ..where((e) => e.privateKey.isNotNull())
          ..limit(1))
        .getSingleOrNull();
    if (kp == null) return;

    await _dt.db.transaction(() async {
      await (_dt.db.update(_dt.db.snLocalKeyPair)
            ..where((e) => e.isActive.equals(true)))
          .write(SnLocalKeyPairCompanion(isActive: Value(false)));

      await (_dt.db.update(_dt.db.snLocalKeyPair)
            ..where((e) => e.id.equals(kp.id)))
          .write(SnLocalKeyPairCompanion(isActive: Value(true)));
    });
  }

  Future<SnKeyPair> enrollNew() async {
    if (!_ua.isAuthorized) throw Exception('Unauthorized');

    final id = const Uuid().v4();
    final kp = await RSA.generate(2048);
    final kpMeta = SnKeyPair(
      id: id,
      accountId: _ua.user!.id,
      publicKey: kp.publicKey,
      privateKey: kp.privateKey,
    );

    // Save the keypair to the local database
    // If there is already one with private key, it will be overwritten
    await _dt.db.transaction(() async {
      await (_dt.db.update(_dt.db.snLocalKeyPair)
            ..where((e) => e.isActive.equals(true)))
          .write(SnLocalKeyPairCompanion(isActive: Value(false)));

      await _dt.db.snLocalKeyPair.insertOne(
        SnLocalKeyPairCompanion.insert(
          id: kpMeta.id,
          accountId: kpMeta.accountId,
          publicKey: kpMeta.publicKey,
          privateKey: Value(kpMeta.privateKey),
          isActive: Value(true),
        ),
      );
    });

    await reloadActive(autoEnroll: false);

    return kpMeta;
  }
}
