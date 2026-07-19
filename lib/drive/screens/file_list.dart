import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'file_list.g.dart';

@riverpod
Future<Map<String, dynamic>?> billingUsage(Ref ref) async {
  final driveApi = ref.read(solarNetworkClientProvider).drive;
  return driveApi.getTotalUsage();
}

final indexedCloudFileListFamilyProvider =
    AsyncNotifierProvider.family<
      IndexedCloudFileListNotifier,
      PaginationState<FileListItem>,
      String
    >(IndexedCloudFileListNotifier.new);

final indexedCloudFileListProvider = indexedCloudFileListFamilyProvider(
  'default',
);

/// Cache-busting token for the Miller-column browser path providers.
class DriveBrowserEpoch extends Notifier<int> {
  DriveBrowserEpoch(this.tabId);
  final String tabId;

  @override
  int build() => 0;

  void bump() => state++;
}

final driveBrowserEpochProvider =
    NotifierProvider.family<DriveBrowserEpoch, int, String>(
      DriveBrowserEpoch.new,
    );

class DriveBrowserPathKey {
  final String path;
  final String? poolId;
  final String? order;
  final bool orderDesc;
  final bool? isFolder;
  final String? contentType;
  final bool? hasThumbnail;
  final String? extension;
  final String? createdAfter;
  final String? createdBefore;
  final String? query;
  final int epoch;

  const DriveBrowserPathKey({
    required this.path,
    this.poolId,
    this.order,
    this.orderDesc = true,
    this.isFolder,
    this.contentType,
    this.hasThumbnail,
    this.extension,
    this.createdAfter,
    this.createdBefore,
    this.query,
    this.epoch = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriveBrowserPathKey &&
          path == other.path &&
          poolId == other.poolId &&
          order == other.order &&
          orderDesc == other.orderDesc &&
          isFolder == other.isFolder &&
          contentType == other.contentType &&
          hasThumbnail == other.hasThumbnail &&
          extension == other.extension &&
          createdAfter == other.createdAfter &&
          createdBefore == other.createdBefore &&
          query == other.query &&
          epoch == other.epoch;

  @override
  int get hashCode => Object.hash(
    path,
    poolId,
    order,
    orderDesc,
    isFolder,
    contentType,
    hasThumbnail,
    extension,
    createdAfter,
    createdBefore,
    query,
    epoch,
  );
}

/// Lists folder children for a drive path (used by column browser columns).
final driveBrowserPathProvider = FutureProvider.autoDispose
    .family<List<SnCloudFile>, DriveBrowserPathKey>((ref, key) async {
      final driveApi = ref.read(solarNetworkClientProvider).drive;

      final parts = key.path
          .split('/')
          .where((part) => part.isNotEmpty)
          .toList();

      String? parentId;
      for (final part in parts) {
        final PaginatedResult<SnCloudFile> result;
        if (parentId == null) {
          result = await driveApi.listRootChildren(poolId: key.poolId);
        } else {
          result = await driveApi.listFolderChildren(
            parentId,
            poolId: key.poolId,
          );
        }

        final matchedFolder = result.items
            .where((item) => item.isFolder && item.name == part)
            .firstOrNull;
        if (matchedFolder == null || matchedFolder.id.isEmpty) {
          return const [];
        }
        parentId = matchedFolder.id;
      }

      final PaginatedResult<SnCloudFile> result;
      if (parentId == null) {
        result = await driveApi.listRootChildren(
          poolId: key.poolId,
          order: key.order,
          orderDesc: key.orderDesc,
          query: key.query,
          isFolder: key.isFolder,
          contentType: key.contentType,
          hasThumbnail: key.hasThumbnail,
          extension: key.extension,
          createdAfter: key.createdAfter,
          createdBefore: key.createdBefore,
        );
      } else {
        result = await driveApi.listFolderChildren(
          parentId,
          poolId: key.poolId,
          order: key.order,
          orderDesc: key.orderDesc,
          query: key.query,
          isFolder: key.isFolder,
          contentType: key.contentType,
          hasThumbnail: key.hasThumbnail,
          extension: key.extension,
          createdAfter: key.createdAfter,
          createdBefore: key.createdBefore,
        );
      }
      return result.items;
    });

void bumpDriveBrowserEpoch(WidgetRef ref, String tabId) {
  ref.read(driveBrowserEpochProvider(tabId).notifier).bump();
}

/// Invalidates the indexed file list and column-browser caches for a tab.
void invalidateIndexedDriveViews(WidgetRef ref, String tabId) {
  ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
  bumpDriveBrowserEpoch(ref, tabId);
}

class IndexedCloudFileListNotifier
    extends AsyncNotifier<PaginationState<FileListItem>>
    with AsyncPaginationController<FileListItem> {
  final String tabId;
  IndexedCloudFileListNotifier(this.tabId);

  String _currentPath = '/';
  String? _poolId;
  String? _query;
  String? _extension;
  String? _contentType;
  bool? _isFolder;
  bool? _hasThumbnail;
  String? _createdAfter;
  String? _createdBefore;
  String? _order;
  bool _orderDesc = true;

  void setPath(String path) {
    if (_currentPath == path) return;
    _currentPath = path;
    ref.invalidateSelf();
  }

  void setPool(String? poolId) {
    if (_poolId == poolId) return;
    _poolId = poolId;
    ref.invalidateSelf();
  }

  /// Free-text search only (no key:value advanced-search syntax).
  void setQuery(String? query) {
    final normalized = query?.trim();
    final next = (normalized == null || normalized.isEmpty) ? null : normalized;
    if (_query == next) return;
    _query = next;
    ref.invalidateSelf();
  }

  void setOrder(String? order) {
    if (_order == order) return;
    _order = order;
    ref.invalidateSelf();
  }

  void setOrderDesc(bool orderDesc) {
    if (_orderDesc == orderDesc) return;
    _orderDesc = orderDesc;
    ref.invalidateSelf();
  }

  /// Structured filters from the filter bar UI.
  void setStructuredFilters({
    bool? isFolder,
    String? contentType,
    bool? hasThumbnail,
    String? extension,
    String? createdAfter,
    String? createdBefore,
    String? order,
    bool? orderDesc,
  }) {
    final nextOrder = order ?? _order;
    final nextOrderDesc = orderDesc ?? _orderDesc;
    if (_isFolder == isFolder &&
        _contentType == contentType &&
        _hasThumbnail == hasThumbnail &&
        _extension == extension &&
        _createdAfter == createdAfter &&
        _createdBefore == createdBefore &&
        _order == nextOrder &&
        _orderDesc == nextOrderDesc) {
      return;
    }
    _isFolder = isFolder;
    _contentType = contentType;
    _hasThumbnail = hasThumbnail;
    _extension = extension;
    _createdAfter = createdAfter;
    _createdBefore = createdBefore;
    _order = nextOrder;
    _orderDesc = nextOrderDesc;
    ref.invalidateSelf();
  }

  @override
  FutureOr<PaginationState<FileListItem>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: false,
      cursor: null,
    );
  }

  @override
  Future<List<FileListItem>> fetch() async {
    final driveApi = ref.read(solarNetworkClientProvider).drive;

    final resolution = await _resolveParentIdForPath(driveApi);
    if (!resolution.found) return const [];

    final PaginatedResult<SnCloudFile> result;
    if (resolution.parentId == null) {
      result = await driveApi.listRootChildren(
        query: _query,
        extension: _extension,
        order: _order,
        orderDesc: _orderDesc,
        poolId: _poolId,
        contentType: _contentType,
        isFolder: _isFolder,
        hasThumbnail: _hasThumbnail,
        createdAfter: _createdAfter,
        createdBefore: _createdBefore,
      );
    } else {
      result = await driveApi.listFolderChildren(
        resolution.parentId!,
        query: _query,
        extension: _extension,
        order: _order,
        orderDesc: _orderDesc,
        poolId: _poolId,
        contentType: _contentType,
        isFolder: _isFolder,
        hasThumbnail: _hasThumbnail,
        createdAfter: _createdAfter,
        createdBefore: _createdBefore,
      );
    }

    totalCount = result.totalCount;
    return result.items.map(_toFileListItem).toList();
  }

  FileListItem _toFileListItem(SnCloudFile file) {
    if (file.isFolder) {
      return FileListItem.folder(file);
    }
    return FileListItem.file(file);
  }

  Future<({bool found, String? parentId})> _resolveParentIdForPath(
    DriveApi driveApi,
  ) async {
    final parts = _currentPath
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return (found: true, parentId: null);
    }

    String? parentId;
    for (final part in parts) {
      final PaginatedResult<SnCloudFile> result;
      if (parentId == null) {
        result = await driveApi.listRootChildren(poolId: _poolId);
      } else {
        result = await driveApi.listFolderChildren(parentId, poolId: _poolId);
      }

      final matchedFolder = result.items
          .where((item) => item.isFolder && item.name == part)
          .firstOrNull;

      if (matchedFolder == null) {
        return (found: false, parentId: null);
      }

      parentId = matchedFolder.id;
      if (parentId.isEmpty) {
        return (found: false, parentId: null);
      }
    }

    return (found: true, parentId: parentId);
  }
}

final unindexedFileListFamilyProvider =
    AsyncNotifierProvider.family<
      UnindexedFileListNotifier,
      PaginationState<FileListItem>,
      String
    >(UnindexedFileListNotifier.new);

final unindexedFileListProvider = unindexedFileListFamilyProvider('default');

class UnindexedFileListNotifier
    extends AsyncNotifier<PaginationState<FileListItem>>
    with AsyncPaginationController<FileListItem> {
  final String tabId;
  UnindexedFileListNotifier(this.tabId);

  String? _poolId;
  bool _recycled = false;
  String? _query;
  String? _extension;
  String? _contentType;
  bool? _isFolder;
  bool? _hasThumbnail;
  String? _createdAfter;
  String? _createdBefore;
  String? _order;
  bool _orderDesc = true;

  void setPool(String? poolId) {
    if (_poolId == poolId) return;
    _poolId = poolId;
    ref.invalidateSelf();
  }

  void setRecycled(bool recycled) {
    if (_recycled == recycled) return;
    _recycled = recycled;
    ref.invalidateSelf();
  }

  /// Free-text search only (no key:value advanced-search syntax).
  void setQuery(String? query) {
    final normalized = query?.trim();
    final next = (normalized == null || normalized.isEmpty) ? null : normalized;
    if (_query == next) return;
    _query = next;
    ref.invalidateSelf();
  }

  void setOrder(String? order) {
    if (_order == order) return;
    _order = order;
    ref.invalidateSelf();
  }

  void setOrderDesc(bool orderDesc) {
    if (_orderDesc == orderDesc) return;
    _orderDesc = orderDesc;
    ref.invalidateSelf();
  }

  /// Structured filters from the filter bar UI.
  void setStructuredFilters({
    bool? isFolder,
    String? contentType,
    bool? hasThumbnail,
    String? extension,
    String? createdAfter,
    String? createdBefore,
    String? order,
    bool? orderDesc,
  }) {
    final nextOrder = order ?? _order;
    final nextOrderDesc = orderDesc ?? _orderDesc;
    if (_isFolder == isFolder &&
        _contentType == contentType &&
        _hasThumbnail == hasThumbnail &&
        _extension == extension &&
        _createdAfter == createdAfter &&
        _createdBefore == createdBefore &&
        _order == nextOrder &&
        _orderDesc == nextOrderDesc) {
      return;
    }
    _isFolder = isFolder;
    _contentType = contentType;
    _hasThumbnail = hasThumbnail;
    _extension = extension;
    _createdAfter = createdAfter;
    _createdBefore = createdBefore;
    _order = nextOrder;
    _orderDesc = nextOrderDesc;
    ref.invalidateSelf();
  }

  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<FileListItem>> build() async {
    final items = await fetch();
    if (!ref.mounted) {
      return PaginationState(
        items: items,
        isLoading: false,
        isReloading: false,
        totalCount: totalCount,
        hasMore: false,
        cursor: null,
      );
    }
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<FileListItem>> fetch() async {
    final driveApi = ref.read(solarNetworkClientProvider).drive;

    final result = await driveApi.listUnindexedFiles(
      poolId: _poolId,
      recycled: _recycled,
      offset: fetchedCount,
      take: pageSize,
      query: _query,
      extension: _extension,
      order: _order,
      orderDesc: _orderDesc,
      contentType: _contentType,
      isFolder: _isFolder,
      hasThumbnail: _hasThumbnail,
      createdAfter: _createdAfter,
      createdBefore: _createdBefore,
    );

    totalCount = result.totalCount;

    return result.items
        .map((file) => FileListItem.unindexedFile(file))
        .toList();
  }
}

@riverpod
Future<Map<String, dynamic>?> billingQuota(Ref ref) async {
  final driveApi = ref.read(solarNetworkClientProvider).drive;
  return driveApi.getQuota();
}
