import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:cross_file/cross_file.dart';
import 'package:provider/provider.dart';
import 'package:surface/database/database.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/attachment.dart';

const kConcurrentUploadChunks = 5;

class SnAttachmentProvider {
  late final SnNetworkProvider _sn;
  late final DatabaseProvider _dt;
  final Map<String, SnAttachment> _cache = {};

  SnAttachmentProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _dt = context.read<DatabaseProvider>();
  }

  void putCache(Iterable<SnAttachment> items, {bool noCheck = false}) {
    for (final item in items) {
      if (item.isAnalyzed || noCheck) {
        _cache[item.rid] = item;
      }
    }
  }

  Future<SnAttachment> getOne(String rid, {noCache = false}) async {
    // In-memory cache
    if (!noCache && _cache.containsKey(rid)) {
      return _cache[rid]!;
    }
    // On-disk cache
    final dbResp = await (_dt.db.snLocalAttachment.select()
          ..where((e) => e.rid.equals(rid))
          ..where((e) => e.cacheExpiredAt.isBiggerThanValue(DateTime.now())))
        .getSingleOrNull();
    if (dbResp != null) {
      _cache[rid] = dbResp.content;
      return dbResp.content;
    }
    // Remote server
    final resp = await _sn.client.get('/cgi/uc/attachments/$rid/meta');
    final out = SnAttachment.fromJson(resp.data);
    if (out.isAnalyzed) {
      _cache[rid] = out;
    }
    _saveToLocal([out]);

    return out;
  }

  Future<List<SnAttachment?>> getMultiple(List<String> rids,
      {bool noCache = false}) async {
    // In-memory cache
    final result = List<SnAttachment?>.filled(rids.length, null);
    final Map<String, int> randomMapping = {};
    for (int i = 0; i < rids.length; i++) {
      final rid = rids[i];
      if (noCache || !_cache.containsKey(rid)) {
        randomMapping[rid] = i;
      } else {
        result[i] = _cache[rid]!;
      }
    }
    var pendingFetch = randomMapping.keys;
    // On-disk cache
    if (pendingFetch.isEmpty) return result;
    if (!noCache) {
      final dbResp = await (_dt.db.snLocalAttachment.select()
            ..where((e) => e.rid.isIn(pendingFetch))
            ..where((e) => e.cacheExpiredAt.isBiggerThanValue(DateTime.now())))
          .get();
      for (final item in dbResp) {
        if (item.content.isAnalyzed) {
          _cache[item.rid] = item.content;
        }
        result[randomMapping[item.rid]!] = item.content;
        randomMapping.remove(item.rid);
      }
      pendingFetch = randomMapping.keys;
    }
    // Remote server
    if (pendingFetch.isEmpty) return result;
    final resp = await _sn.client.get(
      '/cgi/uc/attachments',
      queryParameters: {
        'take': pendingFetch.length,
        'id': pendingFetch.join(','),
      },
    );
    final List<SnAttachment?> out = resp.data['data']
        .map((e) => e['id'] == 0 ? null : SnAttachment.fromJson(e))
        .cast<SnAttachment?>()
        .toList();
    for (final item in out) {
      if (item == null) continue;
      if (item.isAnalyzed) {
        _cache[item.rid] = item;
      }
      result[randomMapping[item.rid]!] = item;
    }
    _saveToLocal(out.where((ele) => ele != null).cast());

    return result;
  }

  static Map<String, String> mimetypeOverrides = {
    'mov': 'video/quicktime',
    'mp4': 'video/mp4',
    'm4a': 'audio/mp4',
    'apng': 'image/apng',
    'webp': 'image/webp',
  };

  Future<SnAttachment> directUploadOne(
    Uint8List data,
    String filename,
    String pool,
    Map<String, dynamic>? metadata, {
    String? mimetype,
    Function(double progress)? onProgress,
    bool analyzeNow = false,
  }) async {
    final filePayload = MultipartFile.fromBytes(data, filename: filename);
    final fileAlt = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;
    final fileExt =
        filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();

    String? mimetypeOverride;
    if (mimetype != null) {
      mimetypeOverride = mimetype;
    } else if (mimetypeOverrides.keys.contains(fileExt)) {
      mimetypeOverride = mimetypeOverrides[fileExt];
    }

    final formData = FormData.fromMap({
      'alt': fileAlt,
      'file': filePayload,
      'pool': pool,
      'metadata': metadata,
      if (mimetypeOverride != null) 'mimetype': mimetypeOverride,
    });
    final resp = await _sn.client.post(
      '/cgi/uc/attachments',
      data: formData,
      queryParameters: {'analyzeNow': analyzeNow},
      onSendProgress: (count, total) {
        if (onProgress != null) {
          onProgress(count / total);
        }
      },
    );

    return SnAttachment.fromJson(resp.data);
  }

  Future<(SnAttachmentFragment, int)> chunkedUploadInitialize(
    int size,
    String filename,
    String pool,
    Map<String, dynamic>? metadata, {
    String? mimetype,
  }) async {
    final fileAlt = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;
    final fileExt =
        filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();

    String? mimetypeOverride;
    if (mimetype == null && mimetypeOverrides.keys.contains(fileExt)) {
      mimetypeOverride = mimetypeOverrides[fileExt];
    } else {
      mimetypeOverride = mimetype;
    }

    final resp = await _sn.client.post('/cgi/uc/fragments', data: {
      'alt': fileAlt,
      'name': filename,
      'pool': pool,
      'metadata': metadata,
      'size': size,
      if (mimetypeOverride != null) 'mimetype': mimetypeOverride,
    });

    return (
      SnAttachmentFragment.fromJson(resp.data['meta']),
      resp.data['chunk_size'] as int
    );
  }

  Future<dynamic> _chunkedUploadOnePart(
    Uint8List data,
    String rid,
    String cid, {
    Function(double progress)? onProgress,
    bool analyzeNow = false,
  }) async {
    final resp = await _sn.client.post(
      '/cgi/uc/fragments/$rid/$cid',
      data: data,
      queryParameters: {'analyzeNow': analyzeNow},
      options: Options(headers: {'Content-Type': 'application/octet-stream'}),
      onSendProgress: (count, total) {
        if (onProgress != null) {
          onProgress(count / total);
        }
      },
    );

    if (resp.data['attachment'] != null) {
      return SnAttachment.fromJson(resp.data['attachment']);
    } else {
      return SnAttachmentFragment.fromJson(resp.data['fragment']);
    }
  }

  Future<SnAttachment> chunkedUploadParts(
    XFile file,
    SnAttachmentFragment place,
    int chunkSize, {
    Function(double progress)? onProgress,
    bool analyzeNow = false,
  }) async {
    final Map<String, dynamic> chunks = place.fileChunks;
    var completedTasks = 0;

    final queue = Queue<Future<void>>();
    final activeTasks = <Future<void>>[];

    late SnAttachment out;

    for (final entry in chunks.entries) {
      queue.add(() async {
        final beginCursor = entry.value * chunkSize;
        final endCursor = math.min<int>(
          (entry.value + 1) * chunkSize,
          await file.length(),
        );
        final data = Uint8List.fromList(await file
            .openRead(beginCursor, endCursor)
            .expand((chunk) => chunk)
            .toList());

        final result = await _chunkedUploadOnePart(
          data,
          place.rid,
          entry.key,
          analyzeNow: analyzeNow,
          onProgress: (progress) {
            final overallProgress = (completedTasks + progress) / chunks.length;
            onProgress?.call(overallProgress);
          },
        );

        completedTasks++;
        final overallProgress = completedTasks / chunks.length;
        onProgress?.call(overallProgress);

        if (result is SnAttachmentFragment) {
          place = result;
        } else {
          out = result as SnAttachment;
        }
      }());
    }

    while (queue.isNotEmpty || activeTasks.isNotEmpty) {
      while (activeTasks.length < kConcurrentUploadChunks && queue.isNotEmpty) {
        final task = queue.removeFirst();
        activeTasks.add(task);

        task.then((_) => activeTasks.remove(task));
      }

      if (activeTasks.isNotEmpty) {
        await Future.any(activeTasks);
      }
    }

    return out;
  }

  Future<SnAttachment> updateOne(
    SnAttachment item, {
    String? alt,
    int? thumbnailId,
    int? compressedId,
    Map<String, dynamic>? metadata,
    bool? isIndexable,
  }) async {
    final resp = await _sn.client.put('/cgi/uc/attachments/${item.id}', data: {
      'alt': alt ?? item.alt,
      'thumbnail': thumbnailId ?? item.thumbnailId,
      'compressed': compressedId ?? item.compressedId,
      'metadata': metadata ?? item.usermeta,
      'is_indexable': isIndexable ?? item.isIndexable,
    });
    final out = SnAttachment.fromJson(resp.data);
    _saveToLocal([out]);
    return out;
  }

  Future<void> _saveToLocal(Iterable<SnAttachment> out) async {
    for (final ele in out) {
      if (!ele.isAnalyzed || ele.destination == 0) continue;
      await _dt.db.snLocalAttachment.insertOne(
        SnLocalAttachmentCompanion.insert(
          id: Value(ele.id),
          rid: ele.rid,
          uuid: ele.uuid,
          content: ele,
          accountId: ele.accountId,
          cacheExpiredAt: DateTime.now().add(const Duration(hours: 1)),
        ),
        onConflict: DoUpdate(
          (_) => SnLocalAttachmentCompanion.custom(
            content: Constant(jsonEncode(ele.toJson())),
            cacheExpiredAt:
                Constant(DateTime.now().add(const Duration(hours: 1))),
          ),
        ),
      );
    }
  }
}
