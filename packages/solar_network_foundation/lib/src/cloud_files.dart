import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

/// Builds the canonical Drive URL for a cloud-file identifier.
///
/// A caller-provided [storageUrl] takes precedence, allowing a file to be
/// served by a different storage backend. When provided, [workspaceId] is
/// appended as `workspace_id` without discarding any existing query parameters.
String cloudFileUrl({
  required String serverUrl,
  required String id,
  String? storageUrl,
  bool original = false,
  String? workspaceId,
}) {
  final url = storageUrl ?? '$serverUrl/drive/files/$id';
  final uri = Uri.parse(url);
  final queryParameters = Map<String, String>.from(uri.queryParameters);
  if (original) queryParameters['original'] = 'true';
  if (workspaceId != null && workspaceId.isNotEmpty) {
    queryParameters['workspace_id'] = workspaceId;
  }
  final builtUri = uri.replace(queryParameters: queryParameters).toString();
  if (builtUri.endsWith('?')) return builtUri.substring(0, builtUri.length - 1);
  return builtUri;
}

/// Creates the cached image provider used for cloud-file previews.
ImageProvider cloudFileImageProvider({
  required String serverUrl,
  required String id,
  String? storageUrl,
  bool original = false,
  String? workspaceId,
  Map<String, String>? headers,
}) => CachedNetworkImageProvider(
  cloudFileUrl(
    serverUrl: serverUrl,
    id: id,
    storageUrl: storageUrl,
    original: original,
    workspaceId: workspaceId,
  ),
  headers: headers,
);
