import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/drive/drive_models/file_list_item.dart';
import 'package:island/core/network.dart';
import 'package:island/pagination/pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_list.g.dart';

@riverpod
Future<Map<String, dynamic>?> billingUsage(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/billing/usage');
  return response.data;
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
      totalCount: null,
      hasMore: false,
      cursor: null,
    );
  }

  @override
  Future<List<FileListItem>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParameters = <String, String>{'path': _currentPath};

    if (_poolId != null) {
      queryParameters['pool'] = _poolId!;
    }

    if (_query != null) {
      queryParameters['query'] = _query!;
    }

    if (_order != null) {
      queryParameters['order'] = _order!;
    }

    queryParameters['orderDesc'] = _orderDesc.toString();

    final response = await client.get(
      '/drive/index/browse',
      queryParameters: queryParameters,
    );

    final List<String> folders = (response.data['folders'] as List)
        .map((e) => e as String)
        .toList();
    final List<SnCloudFileIndex> files = (response.data['files'] as List)
        .map((e) => SnCloudFileIndex.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<FileListItem> items = [
      ...folders.map((folderName) => FileListItem.folder(folderName)),
      ...files.map((file) => FileListItem.file(file)),
    ];

    return items;
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
    final client = ref.read(apiClientProvider);

    final queryParameters = <String, String>{
      'take': pageSize.toString(),
      'offset': fetchedCount.toString(),
    };

    if (_poolId != null) {
      queryParameters['pool'] = _poolId!;
    }

    if (_recycled) {
      queryParameters['recycled'] = _recycled.toString();
    }

    if (_query != null) {
      queryParameters['query'] = _query!;
    }

    if (_order != null) {
      queryParameters['order'] = _order!;
    }

    queryParameters['orderDesc'] = _orderDesc.toString();

    final response = await client.get(
      '/drive/index/unindexed',
      queryParameters: queryParameters,
    );

    totalCount = int.tryParse(response.headers.value('x-total') ?? '0') ?? 0;

    final List<SnCloudFile> files = (response.data as List)
        .map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<FileListItem> items = files
        .map((file) => FileListItem.unindexedFile(file))
        .toList();

    return items;
  }
}

@riverpod
Future<Map<String, dynamic>?> billingQuota(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/billing/quota');
  return response.data;
}
