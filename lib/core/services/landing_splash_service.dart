import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kLandingSplashManifestKey = 'app_landing_splash_manifest';
const _kLandingSplashDirName = 'landing_splash';

final _log = Logger('LandingSplashService');

/// A cloud-configured startup splash artwork downloaded to local storage.
class CloudLandingAsset {
  final String id;
  final String url;
  final String orientation;
  final int? backgroundColorValue;
  final bool isLimitedTime;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? localPath;

  const CloudLandingAsset({
    required this.id,
    required this.url,
    required this.orientation,
    this.backgroundColorValue,
    this.isLimitedTime = false,
    this.startsAt,
    this.endsAt,
    this.localPath,
  });

  bool get isLandscape => orientation == 'landscape';

  Color? get backgroundColor =>
      backgroundColorValue != null ? Color(backgroundColorValue!) : null;

  bool isActiveAt(DateTime now) {
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }

  bool isExpiredAt(DateTime now) => endsAt != null && now.isAfter(endsAt!);

  CloudLandingAsset copyWith({String? localPath}) {
    return CloudLandingAsset(
      id: id,
      url: url,
      orientation: orientation,
      backgroundColorValue: backgroundColorValue,
      isLimitedTime: isLimitedTime,
      startsAt: startsAt,
      endsAt: endsAt,
      localPath: localPath ?? this.localPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'orientation': orientation,
      if (backgroundColorValue != null)
        'background_color_value': backgroundColorValue,
      'is_limited_time': isLimitedTime,
      if (startsAt != null) 'starts_at': startsAt!.toUtc().toIso8601String(),
      if (endsAt != null) 'ends_at': endsAt!.toUtc().toIso8601String(),
      if (localPath != null) 'local_path': localPath,
    };
  }

  factory CloudLandingAsset.fromJson(Map<String, dynamic> json) {
    final startsAtRaw = json['starts_at'] as String?;
    final endsAtRaw = json['ends_at'] as String?;
    final startsAt = startsAtRaw != null && startsAtRaw.isNotEmpty
        ? DateTime.tryParse(startsAtRaw)?.toUtc()
        : null;
    final endsAt = endsAtRaw != null && endsAtRaw.isNotEmpty
        ? DateTime.tryParse(endsAtRaw)?.toUtc()
        : null;
    final rawOrientation =
        (json['orientation'] as String? ?? '').trim().toLowerCase();
    final orientation =
        rawOrientation == 'portrait' ? 'vertical' : rawOrientation;
    final bgValue = json['background_color_value'] is int
        ? json['background_color_value'] as int
        : parseLandingHexColor(json['background_color'] as String?);
    final isLimited = json['is_limited_time'] == true ||
        startsAt != null ||
        endsAt != null;

    return CloudLandingAsset(
      id: (json['id'] as String? ?? '').trim(),
      url: (json['url'] as String? ?? '').trim(),
      orientation: orientation,
      backgroundColorValue: bgValue,
      isLimitedTime: isLimited,
      startsAt: startsAt,
      endsAt: endsAt,
      localPath: json['local_path'] as String?,
    );
  }
}

/// Parses `#RRGGBB` or `#AARRGGBB` into an ARGB integer, or `null` if invalid.
int? parseLandingHexColor(String? raw) {
  if (raw == null) return null;
  var hex = raw.trim();
  if (hex.startsWith('#')) {
    hex = hex.substring(1);
  }
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  if (hex.length != 8) return null;
  return int.tryParse(hex, radix: 16);
}

List<CloudLandingAsset> loadLandingManifest(SharedPreferences? prefs) {
  if (prefs == null) return const [];
  final raw = prefs.getString(kLandingSplashManifestKey);
  if (raw == null || raw.isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => CloudLandingAsset.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.id.isNotEmpty && e.url.isNotEmpty)
        .toList();
  } catch (err) {
    _log.warning('Failed to parse landing splash manifest: $err');
    return const [];
  }
}

/// Resolves an active, already-downloaded cloud landing asset synchronously from
/// local storage. Limited-time assets take priority over general assets when
/// active. Returns `null` when no downloaded asset is ready, so the caller can
/// fall back to bundled assets without any network loading.
CloudLandingAsset? resolveLocalLandingAsset({
  required SharedPreferences? prefs,
  required bool isLandscape,
  DateTime? now,
  math.Random? random,
}) {
  if (kIsWeb || prefs == null) return null;
  final targetOrientation = isLandscape ? 'landscape' : 'vertical';
  final current = (now ?? DateTime.now()).toUtc();
  final manifest = loadLandingManifest(prefs);

  final active = <CloudLandingAsset>[];
  for (final item in manifest) {
    if (item.orientation != targetOrientation) continue;
    if (!item.isActiveAt(current)) continue;
    final path = item.localPath;
    if (path == null || path.isEmpty) continue;
    if (!File(path).existsSync()) continue;
    active.add(item);
  }
  if (active.isEmpty) return null;

  final limited = active.where((item) => item.isLimitedTime).toList();
  final pool = limited.isNotEmpty ? limited : active;
  final rng = random ?? math.Random();
  return pool[rng.nextInt(pool.length)];
}

/// Fetches `/stargate/landing`, downloads any new/updated assets directly from
/// their CDN URLs into local storage, updates the manifest in
/// [SharedPreferences], and prunes stale files.
Future<void> syncLandingSplashAssets({
  required Dio apiClient,
  required SharedPreferences prefs,
  Dio? downloadClient,
  Future<Directory> Function()? storageDirProvider,
}) async {
  if (kIsWeb) return;

  final response = await apiClient.get('/stargate/landing');
  final data = response.data;
  if (data is! Map) return;
  final rawAssets = data['assets'];
  if (rawAssets is! List) return;

  final now = DateTime.now().toUtc();
  final existingList = loadLandingManifest(prefs);
  final existingByKey = <String, CloudLandingAsset>{
    for (final item in existingList) '${item.id}|${item.url}': item,
  };

  final baseDir =
      await (storageDirProvider ?? getApplicationSupportDirectory)();
  final splashDir = Directory(p.join(baseDir.path, _kLandingSplashDirName));
  if (!splashDir.existsSync()) {
    await splashDir.create(recursive: true);
  }

  final downloader = downloadClient ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  final updated = <CloudLandingAsset>[];
  final keptPaths = <String>{};

  for (final raw in rawAssets) {
    if (raw is! Map) continue;
    final asset = CloudLandingAsset.fromJson(Map<String, dynamic>.from(raw));
    if (asset.id.isEmpty ||
        asset.url.isEmpty ||
        (asset.orientation != 'landscape' && asset.orientation != 'vertical')) {
      continue;
    }
    if (asset.isExpiredAt(now)) continue;

    final key = '${asset.id}|${asset.url}';
    final existing = existingByKey[key];
    if (existing != null &&
        existing.localPath != null &&
        existing.localPath!.isNotEmpty &&
        File(existing.localPath!).existsSync()) {
      updated.add(asset.copyWith(localPath: existing.localPath));
      keptPaths.add(existing.localPath!);
      continue;
    }

    final targetPath = _buildLocalFilePath(splashDir.path, asset);
    final tmpPath = '$targetPath.tmp';
    try {
      await downloader.download(asset.url, tmpPath);
      final tmpFile = File(tmpPath);
      if (!tmpFile.existsSync() || tmpFile.lengthSync() == 0) {
        if (tmpFile.existsSync()) await tmpFile.delete();
        continue;
      }
      final targetFile = File(targetPath);
      if (targetFile.existsSync()) {
        await targetFile.delete();
      }
      await tmpFile.rename(targetPath);
      updated.add(asset.copyWith(localPath: targetPath));
      keptPaths.add(targetPath);
    } catch (err) {
      _log.warning('Failed to download landing asset ${asset.id}: $err');
      final tmpFile = File(tmpPath);
      if (tmpFile.existsSync()) {
        await tmpFile.delete().catchError((_) => tmpFile);
      }
    }
  }

  await prefs.setString(
    kLandingSplashManifestKey,
    jsonEncode(updated.map((e) => e.toJson()).toList()),
  );

  // Clean up stale/expired files no longer in the manifest.
  if (splashDir.existsSync()) {
    await for (final entity in splashDir.list()) {
      if (entity is File && !keptPaths.contains(entity.path)) {
        await entity.delete().catchError((_) => entity);
      }
    }
  }
}

String _buildLocalFilePath(String dirPath, CloudLandingAsset asset) {
  final safeId = asset.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final urlHash =
      sha256.convert(utf8.encode(asset.url)).toString().substring(0, 12);
  var ext = '';
  final uri = Uri.tryParse(asset.url);
  if (uri != null) {
    final candidate = p.extension(uri.path).toLowerCase();
    if (candidate.isNotEmpty && candidate.length <= 6) {
      ext = candidate;
    }
  }
  if (ext.isEmpty) ext = '.img';
  return p.join(dirPath, '${safeId}_$urlHash$ext');
}
