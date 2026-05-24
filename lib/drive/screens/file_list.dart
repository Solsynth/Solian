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

class _AdvancedFileSearch {
  final String? query;
  final String? usage;
  final String? applicationType;

  const _AdvancedFileSearch({
    required this.query,
    required this.usage,
    required this.applicationType,
  });
}

_AdvancedFileSearch _parseAdvancedFileSearch(String? input) {
  if (input == null || input.trim().isEmpty) {
    return const _AdvancedFileSearch(
      query: null,
      usage: null,
      applicationType: null,
    );
  }

  final remainingTerms = <String>[];
  String? usage;
  String? applicationType;

  for (final term in input.trim().split(RegExp(r'\s+'))) {
    final separatorIndex = term.indexOf(':');
    if (separatorIndex <= 0 || separatorIndex == term.length - 1) {
      remainingTerms.add(term);
      continue;
    }

    final key = term.substring(0, separatorIndex);
    final value = term.substring(separatorIndex + 1);

    switch (key) {
      case 'usage':
        usage = value;
        break;
      case 'applicationType':
      case 'application_type':
        applicationType = value;
        break;
      default:
        remainingTerms.add(term);
        break;
    }
  }

  final query = remainingTerms.join(' ').trim();
  return _AdvancedFileSearch(
    query: query.isEmpty ? null : query,
    usage: usage,
    applicationType: applicationType,
  );
}

class IndexedCloudFileListNotifier
    extends AsyncNotifier<PaginationState<FileListItem>>
    with AsyncPaginationController<FileListItem> {
  final String tabId;
  IndexedCloudFileListNotifier(this.tabId);

  String _currentPath = '/';
  String? _poolId;
  String? _query;
  String? _usage;
  String? _applicationType;
  String? _order;
  bool _orderDesc = false;

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

  void setQuery(String? query) {
    final parsed = _parseAdvancedFileSearch(query);
    if (_query == parsed.query &&
        _usage == parsed.usage &&
        _applicationType == parsed.applicationType) {
      return;
    }
    _query = parsed.query;
    _usage = parsed.usage;
    _applicationType = parsed.applicationType;
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
        usage: _usage,
        applicationType: _applicationType,
      );
    } else {
      result = await driveApi.listFolderChildren(
        resolution.parentId!,
        query: _query,
        order: _order,
        orderDesc: _orderDesc,
        poolId: _poolId,
        usage: _usage,
        applicationType: _applicationType,
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
  String? _usage;
  String? _applicationType;
  String? _order;
  bool _orderDesc = false;

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

  void setQuery(String? query) {
    final parsed = _parseAdvancedFileSearch(query);
    if (_query == parsed.query &&
        _usage == parsed.usage &&
        _applicationType == parsed.applicationType) {
      return;
    }
    _query = parsed.query;
    _usage = parsed.usage;
    _applicationType = parsed.applicationType;
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
      usage: _usage,
      applicationType: _applicationType,
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
