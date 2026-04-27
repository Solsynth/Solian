import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'file_list.g.dart';

@riverpod
Future<Map<String, dynamic>?> billingUsage(Ref ref) async {
  final client = ref.read(solarNetworkClientProvider).dio;
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
    final client = ref.read(solarNetworkClientProvider).dio;

    final resolution = await _resolveParentIdForPath(client);
    if (!resolution.found) return const [];

    final queryParameters = _buildQueryParameters();
    final endpoint = resolution.parentId == null
        ? '/drive/files/root/children'
        : '/drive/files/${resolution.parentId}/children';

    final response = await client.get(
      endpoint,
      queryParameters: queryParameters,
    );

    final rawItems = _extractChildren(response.data);
    return rawItems.map(_toFileListItem).toList();
  }

  Map<String, String> _buildQueryParameters() {
    final queryParameters = <String, String>{};

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
    return queryParameters;
  }

  List<Map<String, dynamic>> _extractChildren(dynamic responseData) {
    if (responseData is List) {
      return responseData
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    return const [];
  }

  FileListItem _toFileListItem(Map<String, dynamic> json) {
    final file = SnCloudFile.fromJson(json);
    final isFolder = json['is_folder'] == true;

    if (isFolder) {
      return FileListItem.folder(file.name);
    }

    return FileListItem.file(file);
  }

  Future<({bool found, String? parentId})> _resolveParentIdForPath(
    dynamic client,
  ) async {
    final parts = _currentPath.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return (found: true, parentId: null);
    }

    String? parentId;
    for (final part in parts) {
      final endpoint = parentId == null
          ? '/drive/files/root/children'
          : '/drive/files/$parentId/children';
      final response = await client.get(
        endpoint,
        queryParameters: {
          'pool': ?_poolId,
        },
      );

      final children = _extractChildren(response.data);
      final matchedFolder = children.where((item) {
        final isFolder = item['is_folder'] == true;
        final name = item['name']?.toString();
        return isFolder && name == part;
      }).firstOrNull;

      if (matchedFolder == null) {
        return (found: false, parentId: null);
      }

      parentId = matchedFolder['id']?.toString();
      if (parentId == null || parentId.isEmpty) {
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
    // Check if still mounted after async operation
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
    final client = ref.read(solarNetworkClientProvider).dio;

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
      '/drive/files/unindexed',
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
  final client = ref.read(solarNetworkClientProvider).dio;
  final response = await client.get('/drive/billing/quota');
  return response.data;
}
