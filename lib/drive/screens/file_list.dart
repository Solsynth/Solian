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

final indexedCloudFileListProvider = AsyncNotifierProvider.autoDispose(
  IndexedCloudFileListNotifier.new,
);

class IndexedCloudFileListNotifier
    extends AsyncNotifier<PaginationState<FileListItem>>
    with AsyncPaginationController<FileListItem> {
  String _currentPath = '/';
  String? _poolId;
  String? _query;
  String? _order;
  bool _orderDesc = false;

  void setPath(String path) {
    _currentPath = path;
    ref.invalidateSelf();
  }

  void setPool(String? poolId) {
    _poolId = poolId;
    ref.invalidateSelf();
  }

  void setQuery(String? query) {
    _query = query;
    ref.invalidateSelf();
  }

  void setOrder(String? order) {
    _order = order;
    ref.invalidateSelf();
  }

  void setOrderDesc(bool orderDesc) {
    _orderDesc = orderDesc;
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
        order: _order,
        orderDesc: _orderDesc,
        poolId: _poolId,
      );
    } else {
      result = await driveApi.listFolderChildren(
        resolution.parentId!,
        query: _query,
        order: _order,
        orderDesc: _orderDesc,
        poolId: _poolId,
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

final unindexedFileListProvider = AsyncNotifierProvider.autoDispose(
  UnindexedFileListNotifier.new,
);

class UnindexedFileListNotifier
    extends AsyncNotifier<PaginationState<FileListItem>>
    with AsyncPaginationController<FileListItem> {
  String? _poolId;
  bool _recycled = false;
  String? _query;
  String? _order;
  bool _orderDesc = false;

  void setPool(String? poolId) {
    _poolId = poolId;
    ref.invalidateSelf();
  }

  void setRecycled(bool recycled) {
    _recycled = recycled;
    ref.invalidateSelf();
  }

  void setQuery(String? query) {
    _query = query;
    ref.invalidateSelf();
  }

  void setOrder(String? order) {
    _order = order;
    ref.invalidateSelf();
  }

  void setOrderDesc(bool orderDesc) {
    _orderDesc = orderDesc;
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
      order: _order,
      orderDesc: _orderDesc,
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
