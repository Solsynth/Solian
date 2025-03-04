import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/database/database.dart';
import 'package:surface/logger.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/attachment.dart';

class SnStickerProvider {
  late final SnNetworkProvider _sn;
  late final DatabaseProvider _dt;
  final Map<String, SnSticker?> _cache = {};

  final Map<int, List<SnSticker>> stickersByPack = {};

  List<SnSticker> get stickers =>
      _cache.values.where((ele) => ele != null).cast<SnSticker>().toList();

  SnStickerProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _dt = context.read<DatabaseProvider>();
  }

  bool hasNotSticker(String alias) {
    return _cache.containsKey(alias) && _cache[alias] == null;
  }

  void _cacheSticker(SnSticker sticker) {
    _cache['${sticker.pack.prefix}:${sticker.alias}'] = sticker;
    if (stickersByPack[sticker.pack.id] == null) {
      stickersByPack[sticker.pack.id] = List.empty(growable: true);
    }
    if (!stickersByPack[sticker.pack.id]!.contains(sticker)) {
      stickersByPack[sticker.pack.id]!.add(sticker);
    }
  }

  void putSticker(Iterable<SnSticker> stickers) {
    for (final ele in stickers) {
      _cacheSticker(ele);
    }
    _saveStickerToLocal(stickers);
    _saveStickerPackToLocal(stickers.map((ele) => ele.pack).toSet());
  }

  Future<SnSticker?> lookupSticker(String alias) async {
    // In-memory cache
    if (_cache.containsKey(alias)) {
      return _cache[alias];
    }
    // On-disk cache
    final localStickers = await (_dt.db.snLocalSticker.select()
          ..where((e) => e.fullAlias.equals(alias)))
        .getSingleOrNull();
    if (localStickers != null) {
      _cache[alias] = localStickers.content;
      return localStickers.content;
    }
    // Remote server
    try {
      final resp = await _sn.client.get('/cgi/uc/stickers/lookup/$alias');
      final sticker = SnSticker.fromJson(resp.data);
      putSticker([sticker]);
      return sticker;
    } catch (err) {
      _cache[alias] = null;
      logging.warning('[Sticker] Failed to lookup sticker $alias', err);
    }

    return null;
  }

  Future<void> listSticker() async {
    final localPacks = await _dt.db.snLocalStickerPack.select().get();
    final localStickers = await _dt.db.snLocalSticker.select().get();
    final local = localStickers.map((ele) {
      return ele.content.copyWith(
        pack: localPacks
            .firstWhere((pk) => pk.content.id == ele.content.packId)
            .content,
      );
    });
    for (final sticker in local) {
      _cacheSticker(sticker);
    }
    try {
      final resp = await _sn.client.get('/cgi/uc/stickers');
      final data = resp.data;
      final stickers = List.from(data).map((ele) => SnSticker.fromJson(ele));
      for (final sticker in stickers) {
        _cacheSticker(sticker);
      }
    } catch (err) {
      logging.error('[Sticker] Failed to list stickers...', err);
      rethrow;
    }
  }

  Future<void> _saveStickerToLocal(Iterable<SnSticker> stickers) async {
    await _dt.db.snLocalSticker.insertAll(
      stickers.map(
        (ele) => SnLocalStickerCompanion.insert(
          id: Value(ele.id),
          alias: ele.alias,
          fullAlias: '${ele.pack.prefix}${ele.alias}',
          content: ele,
          createdAt: Value(ele.createdAt),
        ),
      ),
      onConflict: DoNothing(),
    );
  }

  Future<void> _saveStickerPackToLocal(Iterable<SnStickerPack> packs) async {
    final queries = packs
        .map(
          (ele) => _dt.db.snLocalStickerPack.insertOne(
              SnLocalStickerPackCompanion.insert(
                id: Value(ele.id),
                content: ele,
                createdAt: Value(ele.createdAt),
              ),
              onConflict: DoUpdate((_) => SnLocalStickerPackCompanion.custom(
                  content: Constant(jsonEncode(ele.toJson()))))),
        )
        .toList();
    await Future.wait(queries);
  }
}
