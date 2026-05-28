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
  final String? name;
  final String? extension;
  final String? usage;
  final String? applicationType;
  final String? contentType;
  final String? poolId;
  final String? parentId;
  final bool? indexed;
  final bool? recycled;
  final bool? isFolder;
  final bool? hasThumbnail;
  final bool? hasCompression;
  final int? minSize;
  final int? maxSize;
  final String? createdAfter;
  final String? createdBefore;
  final String? updatedAfter;
  final String? updatedBefore;

  const _AdvancedFileSearch({
    required this.query,
    this.name,
    this.extension,
    this.usage,
    this.applicationType,
    this.contentType,
    this.poolId,
    this.parentId,
    this.indexed,
    this.recycled,
    this.isFolder,
    this.hasThumbnail,
    this.hasCompression,
    this.minSize,
    this.maxSize,
    this.createdAfter,
    this.createdBefore,
    this.updatedAfter,
    this.updatedBefore,
  });
}

_AdvancedFileSearch _parseAdvancedFileSearch(String? input) {
  if (input == null || input.trim().isEmpty) {
    return const _AdvancedFileSearch(query: null);
  }

  final remainingTerms = <String>[];
  String? name;
  String? extension;
  String? usage;
  String? applicationType;
  String? contentType;
  String? poolId;
  String? parentId;
  bool? indexed;
  bool? recycled;
  bool? isFolder;
  bool? hasThumbnail;
  bool? hasCompression;
  int? minSize;
  int? maxSize;
  String? createdAfter;
  String? createdBefore;
  String? updatedAfter;
  String? updatedBefore;

  final tokens = _tokenizeQuery(input.trim());

  for (final token in tokens) {
    final separatorIndex = token.indexOf(':');
    if (separatorIndex <= 0 || separatorIndex == token.length - 1) {
      remainingTerms.add(token);
      continue;
    }

    final key = token.substring(0, separatorIndex).toLowerCase();
    final value = _unquoteValue(token.substring(separatorIndex + 1));

    switch (key) {
      case 'name':
        name = value;
        break;
      case 'ext':
      case 'extension':
        extension = value;
        break;
      case 'usage':
        usage = value;
        break;
      case 'applicationtype':
      case 'application_type':
        applicationType = value;
        break;
      case 'contenttype':
      case 'content_type':
      case 'mimetype':
      case 'mime_type':
        contentType = value;
        break;
      case 'pool':
      case 'pool_id':
        poolId = value;
        break;
      case 'parent':
      case 'parent_id':
        parentId = value;
        break;
      case 'indexed':
        indexed = _parseBool(value);
        break;
      case 'recycled':
        recycled = _parseBool(value);
        break;
      case 'isfolder':
      case 'is_folder':
        isFolder = _parseBool(value);
        break;
      case 'hasthumbnail':
      case 'has_thumbnail':
        hasThumbnail = _parseBool(value);
        break;
      case 'hascompression':
      case 'has_compression':
        hasCompression = _parseBool(value);
        break;
      case 'minsize':
      case 'min_size':
        minSize = int.tryParse(value);
        break;
      case 'maxsize':
      case 'max_size':
        maxSize = int.tryParse(value);
        break;
      case 'createdafter':
      case 'created_after':
        createdAfter = value;
        break;
      case 'createdbefore':
      case 'created_before':
        createdBefore = value;
        break;
      case 'updatedafter':
      case 'updated_after':
        updatedAfter = value;
        break;
      case 'updatedbefore':
      case 'updated_before':
        updatedBefore = value;
        break;
      default:
        remainingTerms.add(token);
        break;
    }
  }

  final query = remainingTerms.join(' ').trim();
  return _AdvancedFileSearch(
    query: query.isEmpty ? null : query,
    name: name,
    extension: extension,
    usage: usage,
    applicationType: applicationType,
    contentType: contentType,
    poolId: poolId,
    parentId: parentId,
    indexed: indexed,
    recycled: recycled,
    isFolder: isFolder,
    hasThumbnail: hasThumbnail,
    hasCompression: hasCompression,
    minSize: minSize,
    maxSize: maxSize,
    createdAfter: createdAfter,
    createdBefore: createdBefore,
    updatedAfter: updatedAfter,
    updatedBefore: updatedBefore,
  );
}

List<String> _tokenizeQuery(String input) {
  final tokens = <String>[];
  final buffer = StringBuffer();
  bool inQuotes = false;
  String? quoteChar;

  for (int i = 0; i < input.length; i++) {
    final char = input[i];

    if (inQuotes) {
      if (char == quoteChar) {
        inQuotes = false;
        buffer.write(char);
      } else {
        buffer.write(char);
      }
    } else {
      if (char == '"' || char == "'") {
        inQuotes = true;
        quoteChar = char;
        buffer.write(char);
      } else if (char == ' ' || char == '\t') {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
      } else {
        buffer.write(char);
      }
    }
  }

  if (buffer.isNotEmpty) {
    tokens.add(buffer.toString());
  }

  return tokens;
}

String _unquoteValue(String value) {
  if (value.length >= 2) {
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
  }
  return value;
}

bool? _parseBool(String value) {
  switch (value.toLowerCase()) {
    case 'true':
    case '1':
    case 'yes':
      return true;
    case 'false':
    case '0':
    case 'no':
      return false;
    default:
      return null;
  }
}

class IndexedCloudFileListNotifier
    extends AsyncNotifier<PaginationState<FileListItem>>
    with AsyncPaginationController<FileListItem> {
  final String tabId;
  IndexedCloudFileListNotifier(this.tabId);

  String _currentPath = '/';
  String? _poolId;
  String? _query;
  String? _name;
  String? _extension;
  String? _usage;
  String? _applicationType;
  String? _contentType;
  String? _parentId;
  bool? _indexed;
  bool? _isFolder;
  bool? _hasThumbnail;
  bool? _hasCompression;
  int? _minSize;
  int? _maxSize;
  String? _createdAfter;
  String? _createdBefore;
  String? _updatedAfter;
  String? _updatedBefore;
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
        _name == parsed.name &&
        _extension == parsed.extension &&
        _usage == parsed.usage &&
        _applicationType == parsed.applicationType &&
        _contentType == parsed.contentType &&
        _parentId == parsed.parentId &&
        _indexed == parsed.indexed &&
        _isFolder == parsed.isFolder &&
        _hasThumbnail == parsed.hasThumbnail &&
        _hasCompression == parsed.hasCompression &&
        _minSize == parsed.minSize &&
        _maxSize == parsed.maxSize &&
        _createdAfter == parsed.createdAfter &&
        _createdBefore == parsed.createdBefore &&
        _updatedAfter == parsed.updatedAfter &&
        _updatedBefore == parsed.updatedBefore) {
      return;
    }
    _query = parsed.query;
    _name = parsed.name;
    _extension = parsed.extension;
    _usage = parsed.usage;
    _applicationType = parsed.applicationType;
    _contentType = parsed.contentType;
    _parentId = parsed.parentId;
    _indexed = parsed.indexed;
    _isFolder = parsed.isFolder;
    _hasThumbnail = parsed.hasThumbnail;
    _hasCompression = parsed.hasCompression;
    _minSize = parsed.minSize;
    _maxSize = parsed.maxSize;
    _createdAfter = parsed.createdAfter;
    _createdBefore = parsed.createdBefore;
    _updatedAfter = parsed.updatedAfter;
    _updatedBefore = parsed.updatedBefore;
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
        name: _name,
        extension: _extension,
        order: _order,
        orderDesc: _orderDesc,
        poolId: _poolId,
        usage: _usage,
        applicationType: _applicationType,
        contentType: _contentType,
        isFolder: _isFolder,
        hasThumbnail: _hasThumbnail,
        hasCompression: _hasCompression,
        minSize: _minSize,
        maxSize: _maxSize,
        createdAfter: _createdAfter,
        createdBefore: _createdBefore,
        updatedAfter: _updatedAfter,
        updatedBefore: _updatedBefore,
      );
    } else {
      result = await driveApi.listFolderChildren(
        resolution.parentId!,
        query: _query,
        name: _name,
        extension: _extension,
        order: _order,
        orderDesc: _orderDesc,
        poolId: _poolId,
        usage: _usage,
        applicationType: _applicationType,
        contentType: _contentType,
        isFolder: _isFolder,
        hasThumbnail: _hasThumbnail,
        hasCompression: _hasCompression,
        minSize: _minSize,
        maxSize: _maxSize,
        createdAfter: _createdAfter,
        createdBefore: _createdBefore,
        updatedAfter: _updatedAfter,
        updatedBefore: _updatedBefore,
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
  String? _name;
  String? _extension;
  String? _usage;
  String? _applicationType;
  String? _contentType;
  bool? _isFolder;
  bool? _hasThumbnail;
  bool? _hasCompression;
  int? _minSize;
  int? _maxSize;
  String? _createdAfter;
  String? _createdBefore;
  String? _updatedAfter;
  String? _updatedBefore;
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
        _name == parsed.name &&
        _extension == parsed.extension &&
        _usage == parsed.usage &&
        _applicationType == parsed.applicationType &&
        _contentType == parsed.contentType &&
        _isFolder == parsed.isFolder &&
        _hasThumbnail == parsed.hasThumbnail &&
        _hasCompression == parsed.hasCompression &&
        _minSize == parsed.minSize &&
        _maxSize == parsed.maxSize &&
        _createdAfter == parsed.createdAfter &&
        _createdBefore == parsed.createdBefore &&
        _updatedAfter == parsed.updatedAfter &&
        _updatedBefore == parsed.updatedBefore) {
      return;
    }
    _query = parsed.query;
    _name = parsed.name;
    _extension = parsed.extension;
    _usage = parsed.usage;
    _applicationType = parsed.applicationType;
    _contentType = parsed.contentType;
    _isFolder = parsed.isFolder;
    _hasThumbnail = parsed.hasThumbnail;
    _hasCompression = parsed.hasCompression;
    _minSize = parsed.minSize;
    _maxSize = parsed.maxSize;
    _createdAfter = parsed.createdAfter;
    _createdBefore = parsed.createdBefore;
    _updatedAfter = parsed.updatedAfter;
    _updatedBefore = parsed.updatedBefore;
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
      name: _name,
      extension: _extension,
      order: _order,
      orderDesc: _orderDesc,
      usage: _usage,
      applicationType: _applicationType,
      contentType: _contentType,
      isFolder: _isFolder,
      hasThumbnail: _hasThumbnail,
      hasCompression: _hasCompression,
      minSize: _minSize,
      maxSize: _maxSize,
      createdAfter: _createdAfter,
      createdBefore: _createdBefore,
      updatedAfter: _updatedAfter,
      updatedBefore: _updatedBefore,
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
