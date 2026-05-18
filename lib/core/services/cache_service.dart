import 'dart:io';

import 'package:disk_space_2/disk_space_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class DiskSpaceInfo {
  final double? freeDiskSpace;
  final double? totalDiskSpace;

  DiskSpaceInfo({this.freeDiskSpace, this.totalDiskSpace});

  int get usedSpace {
    if (freeDiskSpace == null || totalDiskSpace == null) return 0;
    return ((totalDiskSpace! - freeDiskSpace!) * 1024 * 1024).round();
  }

  int get totalSpace {
    if (totalDiskSpace == null) return 0;
    return (totalDiskSpace! * 1024 * 1024).round();
  }

  int get freeSpace {
    if (freeDiskSpace == null) return 0;
    return (freeDiskSpace! * 1024 * 1024).round();
  }

  double get usedPercentage {
    if (freeDiskSpace == null || totalDiskSpace == null) return 0;
    if (totalDiskSpace == 0) return 0;
    return ((totalDiskSpace! - freeDiskSpace!) / totalDiskSpace!);
  }
}

class CacheService {
  static const _nativeChannel = MethodChannel('dev.solsynth.solian/cache');

  static Future<DiskSpaceInfo?> getDiskSpace() async {
    try {
      final free = await DiskSpace.getFreeDiskSpace;
      final total = await DiskSpace.getTotalDiskSpace;
      return DiskSpaceInfo(freeDiskSpace: free, totalDiskSpace: total);
    } catch (e) {
      debugPrint('Failed to get disk space: $e');
      return null;
    }
  }

  static Future<int> getFlutterCacheSize() async {
    try {
      return await DefaultCacheManager().store.getCacheSize();
    } catch (e) {
      try {
        final directory = await _getCacheDirectory();
        if (directory == null) return 0;
        return await getDirectorySize(directory);
      } catch (e) {
        Logger.root.warning('Failed to get Flutter cache size', e);
        return 0;
      }
    }
  }

  static Future<void> clearFlutterCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      try {
        final directory = await _getCacheDirectory();
        if (directory != null && await directory.exists()) {
          await _deleteDirectory(directory);
        }
      } catch (e) {
        Logger.root.warning('Failed to clear Flutter cache: $e');
      }
    }
  }

  static Future<int> getNativeCacheSize() async {
    if (!Platform.isIOS) return 0;

    try {
      final result = await _nativeChannel.invokeMethod<Map>(
        'getImageCacheSize',
      );
      if (result != null && result.containsKey('sizeInBytes')) {
        return result['sizeInBytes'] as int? ?? 0;
      }
    } catch (e) {
      debugPrint('Failed to get native cache size: $e');
    }
    return 0;
  }

  static Future<bool> clearNativeCache() async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _nativeChannel.invokeMethod<bool>('clearImageCache');
      return result ?? false;
    } catch (e) {
      debugPrint('Failed to clear native cache: $e');
      return false;
    }
  }

  static Future<int> getTotalCacheSize() async {
    final flutter = await getFlutterCacheSize();
    final native = await getNativeCacheSize();
    return flutter + native;
  }

  static Future<bool> clearAllCaches() async {
    await clearFlutterCache();
    if (Platform.isIOS) {
      return await clearNativeCache();
    }
    return true;
  }

  static Future<Directory?> _getCacheDirectory() async {
    try {
      if (kIsWeb) return null;

      if (Platform.isAndroid) {
        final dir = await getTemporaryDirectory();
        return dir;
      } else if (Platform.isIOS) {
        final caches = await getTemporaryDirectory();
        return caches;
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        final dir = await getApplicationSupportDirectory();
        final cacheDir = Directory('${dir.path}/cache');
        if (!await cacheDir.exists()) {
          await cacheDir.create(recursive: true);
        }
        return cacheDir;
      }
    } catch (e) {
      debugPrint('Failed to get cache directory: $e');
    }
    return null;
  }

  static Future<int> getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            try {
              size += await entity.length();
            } catch (e) {
              // Skip files we can't access
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to calculate directory size: $e');
    }
    return size;
  }

  static Future<void> _deleteDirectory(Directory dir) async {
    try {
      if (await dir.exists()) {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            // Skip files we can't delete
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to delete directory: $e');
    }
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
