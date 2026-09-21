import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

/// Picks the web image render method for [uri].
///
/// `cached_network_image` defaults to [ImageRenderMethodForWeb.HtmlImage] on
/// web, which decodes through a browser `<img>` element. The CanvasKit engine
/// snapshots only a single frame from that, so animated GIFs never play. The
/// [ImageRenderMethodForWeb.HttpGet] method fetches raw bytes and decodes with
/// Flutter's multi-frame codec, which animates GIFs.
///
/// Returns `HttpGet` for app-origin images (the API server already allows
/// CORS — the whole web client talks to it over XHR) and for URIs that are
/// clearly animated: `.gif` files and sticker lookup endpoints. Third-party
/// images stay on `HtmlImage` so they keep working without CORS headers.
ImageRenderMethodForWeb imageRenderMethodForWebFor(
  String uri, {
  required String serverUrl,
}) {
  if (!kIsWeb) return ImageRenderMethodForWeb.HtmlImage;
  final lower = uri.toLowerCase();
  final appOrigin = uri.startsWith(serverUrl);
  final animated =
      lower.endsWith('.gif') || lower.contains('/sphere/stickers/lookup/');
  return appOrigin || animated
      ? ImageRenderMethodForWeb.HttpGet
      : ImageRenderMethodForWeb.HtmlImage;
}

/// Creates the cached image provider used for cloud-file previews.
ImageProvider cloudFileImageProvider({
  required String serverUrl,
  required String id,
  String? storageUrl,
  bool original = false,
  String? workspaceId,
  Map<String, String>? headers,
}) {
  final url = cloudFileUrl(
    serverUrl: serverUrl,
    id: id,
    storageUrl: storageUrl,
    original: original,
    workspaceId: workspaceId,
  );
  return CachedNetworkImageProvider(
    url,
    headers: headers,
    imageRenderMethodForWeb: imageRenderMethodForWebFor(
      url,
      serverUrl: serverUrl,
    ),
  );
}
