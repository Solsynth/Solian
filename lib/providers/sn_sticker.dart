import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/attachment.dart';

class SnStickerProvider {
  late final SnNetworkProvider _sn;
  final Map<String, SnSticker?> _cache = {};

  final Map<int, List<SnSticker>> stickersByPack = {};

  List<SnSticker> get stickers =>
      _cache.values.where((ele) => ele != null).cast<SnSticker>().toList();

  SnStickerProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
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

  void putSticker(Iterable<SnSticker> sticker) {
    for (final ele in sticker) {
      _cacheSticker(ele);
    }
  }

  Future<SnSticker?> lookupSticker(String alias) async {
    if (_cache.containsKey(alias)) {
      return _cache[alias];
    }

    try {
      final resp = await _sn.client.get('/cgi/uc/stickers/lookup/$alias');
      final sticker = SnSticker.fromJson(resp.data);
      _cacheSticker(sticker);

      return sticker;
    } catch (err) {
      _cache[alias] = null;
      log('[Sticker] Failed to lookup sticker $alias: $err');
    }

    return null;
  }

  Future<void> listStickerEagerly() async {
    var count = await listSticker();
    for (var page = 1; count > 0; count -= 10) {
      await listSticker(page: page);
      page++;
    }
  }

  Future<int> listSticker({int page = 0}) async {
    try {
      final resp = await _sn.client.get('/cgi/uc/stickers', queryParameters: {
        'take': 10,
        'offset': page * 10,
      });
      final data = resp.data;
      final stickers =
          List.from(data['data']).map((ele) => SnSticker.fromJson(ele));
      for (final sticker in stickers) {
        _cacheSticker(sticker);
      }
      return data['count'] as int;
    } catch (err) {
      log('[Sticker] Failed to list stickers: $err');
      rethrow;
    }
  }
}
