import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/file_list_item.dart';
import 'package:island/pods/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'file_list.g.dart';

@riverpod
class CloudFileListNotifier extends _$CloudFileListNotifier
    with CursorPagingNotifierMixin<FileListItem> {
  String _currentPath = '/';

  void setPath(String path) {
    _currentPath = path;
    ref.invalidateSelf();
  }

  @override
  Future<CursorPagingData<FileListItem>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<FileListItem>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/drive/index/browse',
      queryParameters: {'path': _currentPath},
    );

    final List<String> folders =
        (response.data['folders'] as List).map((e) => e as String).toList();
    final List<SnCloudFileIndex> files =
        (response.data['files'] as List)
            .map((e) => SnCloudFileIndex.fromJson(e as Map<String, dynamic>))
            .toList();

    final List<FileListItem> items = [
      ...folders.map((folderName) => FileListItem.folder(folderName)),
      ...files.map((file) => FileListItem.file(file)),
    ];

    // The new API returns all files in the path, no pagination
    return CursorPagingData(items: items, hasMore: false, nextCursor: null);
  }
}

@riverpod
Future<Map<String, dynamic>?> billingUsage(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/billing/usage');
  return response.data;
}

@riverpod
class UnindexedFileListNotifier extends _$UnindexedFileListNotifier
    with CursorPagingNotifierMixin<FileListItem> {
  String? _poolId;
  bool _recycled = false;

  void setPool(String? poolId) {
    _poolId = poolId;
    ref.invalidateSelf();
  }

  void setRecycled(bool recycled) {
    _recycled = recycled;
    ref.invalidateSelf();
  }

  @override
  Future<CursorPagingData<FileListItem>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<FileListItem>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);

    final offset = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    const take = 50; // Default page size

    final queryParameters = <String, String>{
      'take': take.toString(),
      'offset': offset.toString(),
    };

    if (_poolId != null) {
      queryParameters['pool'] = _poolId!;
    }

    if (_recycled) {
      queryParameters['recycled'] = _recycled.toString();
    }

    final response = await client.get(
      '/drive/index/unindexed',
      queryParameters: queryParameters,
    );

    final total = int.tryParse(response.headers.value('x-total') ?? '0') ?? 0;

    final List<SnCloudFile> files =
        (response.data as List)
            .map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
            .toList();

    final List<FileListItem> items =
        files.map((file) => FileListItem.unindexedFile(file)).toList();

    final hasMore = offset + take < total;
    final nextCursor = hasMore ? (offset + take).toString() : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

@riverpod
Future<Map<String, dynamic>?> billingQuota(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/billing/quota');
  return response.data;
}
