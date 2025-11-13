import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/models/file_list_item.dart';
import 'package:island/models/folder.dart';
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

    final List<SnCloudFolder> folders =
        (response.data['folders'] as List)
            .map((e) => SnCloudFolder.fromJson(e as Map<String, dynamic>))
            .toList();
    final List<SnCloudFileIndex> files =
        (response.data['files'] as List)
            .map((e) => SnCloudFileIndex.fromJson(e as Map<String, dynamic>))
            .toList();

    final List<FileListItem> items = [
      ...folders.map((folder) => FileListItem.folder(folder)),
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
Future<Map<String, dynamic>?> billingQuota(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/billing/quota');
  return response.data;
}
