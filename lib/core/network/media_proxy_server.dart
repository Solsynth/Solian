import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:logging/logging.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'local_http_server.dart';

class MediaProxyServer {
  static const String kLogPrefix = 'media.proxy';
  static const int kCacheMaxSize = 2 * 1024 * 1024 * 1024; // 2GB max cache

  final Ref _ref;
  LocalHttpServer? _server;
  late final HttpClient _httpClient;
  String? _cachedAuthToken;
  final Map<String, _ChunkCache> _chunkCaches = {};
  int _totalCacheSize = 0;
  bool _isRunning = false;

  String? _baseUrl;
  String? get baseUrl => _baseUrl;
  bool get isRunning => _isRunning;

  MediaProxyServer(this._ref) {
    _httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    _applyIpOverride();
    _ref.listen<IpOverrideMode>(
      ipOverrideModeProvider,
      (previous, next) => _applyIpOverride(),
    );
    _ref.listen<List<String>>(
      ipOverrideDomainsProvider,
      (previous, next) => _applyIpOverride(),
    );
    _ref.listen<IpOverrideSettings>(
      ipOverrideSettingsProvider,
      (previous, next) => _applyIpOverride(),
    );
  }

  void _applyIpOverride() {
    _httpClient.connectionFactory = _ref.read(
      mediaIpOverrideConnectionFactoryProvider,
    );
  }

  void refreshIpOverride() => _applyIpOverride();

  Future<void> start() async {
    if (_isRunning) return;

    _server = LocalHttpServer();
    await _server!.start(
      portRange: LocalHttpServer.defaultPortRange,
      handler: _buildHandler(),
    );

    _isRunning = true;
    _baseUrl = 'http://localhost:${_server!.port}';
    Logger.root.info('[$kLogPrefix] Started on $_baseUrl');
  }

  Handler _buildHandler() {
    return (Request request) async {
      final path = request.url.path;
      Logger.root.info(
        '[$kLogPrefix] Request: ${request.method} ${request.url}',
      );

      if (path.startsWith('drive/files/')) {
        return _handleMediaRequest(request, path);
      }

      if (path == 'health') {
        return Response.ok('OK');
      }

      return Response.notFound('Not found');
    };
  }

  Future<Response> _handleMediaRequest(Request request, String path) async {
    final segments = path.split('/');
    if (segments.length < 3 ||
        segments[0] != 'drive' ||
        segments[1] != 'files') {
      return Response.notFound('Invalid path');
    }

    final fileId = segments[2];
    final queryParams = Map<String, String>.from(request.url.queryParameters);
    final mimeType = queryParams['mime'];

    Logger.root.info(
      '[$kLogPrefix] Media request: fileId=$fileId, mime=$mimeType, thumbnail=${queryParams['thumbnail']}',
    );

    if (queryParams['thumbnail'] == 'true') {
      Logger.root.info('[$kLogPrefix] Bypassing proxy for thumbnail');
      return _proxyDirect(request, fileId, queryParams);
    }

    final isVideo = mimeType?.startsWith('video/') ?? false;
    final isAudio = mimeType?.startsWith('audio/') ?? false;

    if (!isVideo && !isAudio) {
      Logger.root.info('[$kLogPrefix] Non-video/audio, bypassing proxy');
      return _proxyDirect(request, fileId, queryParams);
    }

    Logger.root.info('[$kLogPrefix] Using proxy with caching for video/audio');
    return _proxyWithCache(request, fileId, queryParams);
  }

  Future<Response> _proxyDirect(
    Request request,
    String fileId,
    Map<String, String> queryParams,
  ) async {
    final serverUrl = _ref.read(serverUrlProvider);
    final remoteUrl = '$serverUrl/drive/files/$fileId';

    try {
      Logger.root.info('[$kLogPrefix] Proxy direct: $remoteUrl');
      final token = await _getValidAuthToken();
      final uri = Uri.parse(remoteUrl).replace(queryParameters: queryParams);

      final req = await _httpClient.getUrl(uri);
      if (token != null) {
        req.headers.set('Authorization', 'Bearer $token');
      }
      request.headers.forEach((key, value) {
        if (key.toLowerCase() != 'host') {
          req.headers.set(key, value);
        }
      });

      final response = await req.close();
      Logger.root.info('[$kLogPrefix] Response status: ${response.statusCode}');

      final contentType = response.headers.contentType?.value;
      final bodyBytes = <int>[];

      await for (final chunk in response) {
        bodyBytes.addAll(chunk);
      }

      return Response(
        response.statusCode,
        body: Stream.value(Uint8List.fromList(bodyBytes)),
        headers: {
          'Content-Type': contentType ?? 'application/octet-stream',
          'Cache-Control': 'public, max-age=31536000',
        },
      );
    } on HandshakeException catch (e) {
      Logger.root.severe('[$kLogPrefix] TLS handshake failed: $e');
      return Response.internalServerError(body: 'TLS error: ${e.message}');
    } on HttpException catch (e) {
      Logger.root.severe('[$kLogPrefix] Proxy direct HTTP failed: $e');
      return Response.internalServerError();
    } catch (e) {
      Logger.root.severe('[$kLogPrefix] Proxy direct failed: $e');
      return Response.internalServerError();
    }
  }

  Future<Response> _proxyWithCache(
    Request request,
    String fileId,
    Map<String, String> queryParams,
  ) async {
    final serverUrl = _ref.read(serverUrlProvider);
    final remoteUrl = '$serverUrl/drive/files/$fileId';
    final cacheKey = _getCacheKey(fileId, queryParams);
    final rangeHeader = request.headers['range'];

    try {
      if (rangeHeader != null) {
        return _handleRangeRequest(request, remoteUrl, cacheKey, rangeHeader);
      }

      if (request.method == 'GET') {
        return _handleFullRequest(request, remoteUrl, cacheKey);
      }

      return Response(405);
    } on HttpException catch (e) {
      Logger.root.severe('[$kLogPrefix] Proxy with cache failed: $e');
      return Response.internalServerError();
    } catch (e) {
      Logger.root.severe('[$kLogPrefix] Proxy with cache failed: $e');
      return Response.internalServerError();
    }
  }

  Future<Response> _handleFullRequest(
    Request request,
    String remoteUrl,
    String cacheKey,
  ) async {
    final cache = await _getOrCreateChunkCache(cacheKey);
    if (cache.isComplete) {
      final file = File(cache.cachedFilePath!);
      if (await file.exists()) {
        final fileSize = await file.length();
        return Response(
          200,
          body: file.openRead(),
          headers: {
            'Content-Type': 'video/mp4',
            'Content-Length': fileSize.toString(),
            'Accept-Ranges': 'bytes',
            'Cache-Control': 'public, max-age=31536000',
          },
        );
      }
    }

    return _streamAndCache(request, remoteUrl, cacheKey);
  }

  Future<Response> _handleRangeRequest(
    Request request,
    String remoteUrl,
    String cacheKey,
    String rangeHeader,
  ) async {
    final range = _parseRangeHeader(rangeHeader);
    if (range == null) {
      return Response.badRequest(body: 'Invalid range header');
    }

    final cache = _chunkCaches[cacheKey];
    if (cache != null && cache.isComplete) {
      return _serveFromCache(cache, range);
    }

    return _streamAndCacheRange(request, remoteUrl, cacheKey, range);
  }

  _Range? _parseRangeHeader(String header) {
    final match = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(header);
    if (match == null) return null;

    final start = int.parse(match.group(1)!);
    final endStr = match.group(2);
    final end = endStr != null && endStr.isNotEmpty ? int.parse(endStr) : null;
    return _Range(start, end);
  }

  Future<Response> _serveFromCache(_ChunkCache cache, _Range range) async {
    final file = File(cache.cachedFilePath!);
    if (!await file.exists()) {
      return Response.internalServerError();
    }

    final fileSize = await file.length();
    final end = range.end ?? (fileSize - 1);
    final contentLength = end - range.start + 1;

    final raf = await file.open();
    await raf.setPosition(range.start);
    final chunk = await raf.read(contentLength);
    await raf.close();

    return Response(
      206,
      body: Stream.value(Uint8List.fromList(chunk)),
      headers: {
        'Content-Type': 'video/mp4',
        'Content-Length': contentLength.toString(),
        'Content-Range': 'bytes ${range.start}-$end/$fileSize',
        'Accept-Ranges': 'bytes',
        'Cache-Control': 'public, max-age=31536000',
      },
    );
  }

  Future<Response> _streamAndCache(
    Request request,
    String remoteUrl,
    String cacheKey,
  ) async {
    Logger.root.info('[$kLogPrefix] _streamAndCache: cacheKey=$cacheKey');
    final cache = await _getOrCreateChunkCache(cacheKey);

    final token = await _getValidAuthToken();
    final uri = Uri.parse(remoteUrl);

    final req = await _httpClient.getUrl(uri);
    if (token != null) {
      req.headers.set('Authorization', 'Bearer $token');
    }

    final response = await req.close();
    Logger.root.info(
      '[$kLogPrefix] Remote response status: ${response.statusCode}',
    );

    final contentLength = response.headers.contentLength;
    final totalSize = contentLength > 0 ? contentLength : null;
    Logger.root.info(
      '[$kLogPrefix] Content-Length: $contentLength, totalSize: $totalSize',
    );

    final file = File(cache.cachedFilePath!);
    final sink = file.openWrite();
    var receivedLength = 0;

    try {
      await for (final chunk in response) {
        sink.add(chunk);
        receivedLength += chunk.length;

        if (!_chunkCaches.containsKey(cacheKey)) {
          await _cleanupOldCache();
          _chunkCaches[cacheKey] = _ChunkCache(
            cachedFilePath: cache.cachedFilePath,
            totalSize: totalSize ?? receivedLength,
          );
        }
        _chunkCaches[cacheKey]!.downloadedSize = receivedLength;

        if (receivedLength % (1024 * 1024) == 0) {
          Logger.root.info('[$kLogPrefix] Downloaded: $receivedLength bytes');
        }
      }

      await sink.close();
      _chunkCaches[cacheKey]!.markComplete();
      _totalCacheSize += receivedLength;
      Logger.root.info(
        '[$kLogPrefix] Cache complete: $receivedLength bytes, cacheKey=$cacheKey',
      );

      final responseFile = File(cache.cachedFilePath!);
      return Response(
        200,
        body: responseFile.openRead(),
        headers: {
          'Content-Type': 'video/mp4',
          'Content-Length': receivedLength.toString(),
          'Accept-Ranges': 'bytes',
          'Cache-Control': 'public, max-age=31536000',
        },
      );
    } catch (e) {
      await sink.close();
      Logger.root.severe('[$kLogPrefix] _streamAndCache error: $e');
      return Response.internalServerError(body: 'Stream error: $e');
    }
  }

  Future<Response> _streamAndCacheRange(
    Request request,
    String remoteUrl,
    String cacheKey,
    _Range range,
  ) async {
    Logger.root.info(
      '[$kLogPrefix] _streamAndCacheRange: cacheKey=$cacheKey, range=${range.start}-${range.end}',
    );
    final cache = await _getOrCreateChunkCache(cacheKey);

    final token = await _getValidAuthToken();
    final uri = Uri.parse(remoteUrl);

    final req = await _httpClient.getUrl(uri);
    if (token != null) {
      req.headers.set('Authorization', 'Bearer $token');
    }
    req.headers.set('Range', 'bytes=${range.start}-${range.end ?? ""}');

    final response = await req.close();
    Logger.root.info(
      '[$kLogPrefix] Range response status: ${response.statusCode}',
    );

    final contentLength = response.headers.contentLength;
    final isPartial = response.statusCode == 206;

    if (isPartial && contentLength > 0) {
      final contentRange = response.headers.value('content-range');
      final totalSize = _parseContentRangeTotal(contentRange);

      if (totalSize != null && cache.cachedFilePath == null) {
        await _initCacheFile(cacheKey, totalSize);
      }
    }

    final bodyBytes = <int>[];
    if (cache.cachedFilePath != null) {
      final file = File(cache.cachedFilePath!);
      final raf = await file.open(mode: FileMode.append);
      try {
        await for (final chunk in response) {
          await raf.writeFrom(chunk);
          bodyBytes.addAll(chunk);
        }
      } finally {
        await raf.close();
      }

      if (contentLength > 0) {
        _chunkCaches[cacheKey]?.downloadedSize =
            (_chunkCaches[cacheKey]?.downloadedSize ?? 0) + contentLength;
      }
    } else {
      await for (final chunk in response) {
        bodyBytes.addAll(chunk);
      }
    }

    final contentRangeHeader = isPartial
        ? response.headers.value('content-range')
        : null;

    return Response(
      isPartial ? 206 : response.statusCode,
      body: Stream.value(Uint8List.fromList(bodyBytes)),
      headers: {
        'Content-Type': 'video/mp4',
        if (contentLength > 0) 'Content-Length': contentLength.toString(),
        'Content-Range': ?contentRangeHeader,
        'Accept-Ranges': 'bytes',
      },
    );
  }

  int? _parseContentRangeTotal(String? contentRange) {
    if (contentRange == null) return null;
    final match = RegExp(r'/(\d+)$').firstMatch(contentRange);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  Future<String> _getCacheDirectory() async {
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/media_proxy_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  Future<_ChunkCache> _getOrCreateChunkCache(String cacheKey) async {
    if (_chunkCaches.containsKey(cacheKey)) {
      return _chunkCaches[cacheKey]!;
    }

    await _cleanupOldCache();

    final cacheDir = await _getCacheDirectory();
    final cachedFilePath = '$cacheDir/$cacheKey';
    final file = File(cachedFilePath);

    if (await file.exists()) {
      final size = await file.length();
      final cache = _ChunkCache(
        cachedFilePath: cachedFilePath,
        totalSize: size,
      );
      cache.markComplete();
      _chunkCaches[cacheKey] = cache;
      return cache;
    }

    final cache = _ChunkCache(cachedFilePath: cachedFilePath);
    _chunkCaches[cacheKey] = cache;
    return cache;
  }

  Future<void> _initCacheFile(String cacheKey, int totalSize) async {
    final cache = _chunkCaches[cacheKey];
    if (cache == null) return;

    final file = File(cache.cachedFilePath!);
    await file.create(recursive: true);
    await file.writeAsBytes(List.filled(totalSize, 0));

    cache.totalSize = totalSize;
    _totalCacheSize += totalSize;
  }

  Future<void> _cleanupOldCache() async {
    while (_totalCacheSize > kCacheMaxSize && _chunkCaches.isNotEmpty) {
      final oldestKey = _chunkCaches.keys.first;
      final cache = _chunkCaches.remove(oldestKey)!;

      if (cache.cachedFilePath != null) {
        final file = File(cache.cachedFilePath!);
        if (await file.exists()) {
          final size = await file.length();
          await file.delete();
          _totalCacheSize -= size;
        }
      }
    }
  }

  String _getCacheKey(String fileId, Map<String, String> queryParams) {
    final sortedParams =
        queryParams.entries.where((e) => e.key != 'thumbnail').toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final paramStr = sortedParams.map((e) => '${e.key}=${e.value}').join('&');
    return '${fileId}_${paramStr.hashCode}';
  }

  Future<String?> _getValidAuthToken() async {
    if (_cachedAuthToken != null) {
      return _cachedAuthToken;
    }

    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final tokenPairRaw = prefs.getString(kTokenPairStoreKey);
      if (tokenPairRaw == null || tokenPairRaw.isEmpty) return null;

      dynamic decoded;
      try {
        decoded = Map<String, dynamic>.from(
          Uri.splitQueryString(tokenPairRaw).map((k, v) => MapEntry(k, v)),
        );
      } catch (_) {
        return null;
      }

      final token = (decoded['token'] ?? decoded['access_token']) as String?;
      _cachedAuthToken = token;
      return token;
    } catch (e) {
      Logger.root.severe('[$kLogPrefix] Failed to get auth token: $e');
      return null;
    }
  }

  void clearAuthTokenCache() {
    _cachedAuthToken = null;
  }

  Future<void> stop() async {
    await _server?.stop();
    _server = null;
    _isRunning = false;
    _httpClient.close();
    _chunkCaches.clear();
    _totalCacheSize = 0;
    _baseUrl = null;
    Logger.root.info('[$kLogPrefix] Stopped');
  }

  Future<void> clearCache() async {
    for (final cache in _chunkCaches.values) {
      if (cache.cachedFilePath != null) {
        final file = File(cache.cachedFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    _chunkCaches.clear();
    _totalCacheSize = 0;
    Logger.root.info('[$kLogPrefix] Cache cleared');
  }
}

class _ChunkCache {
  String? cachedFilePath;
  int totalSize;
  int downloadedSize;
  bool _isComplete;

  _ChunkCache({
    this.cachedFilePath,
    this.totalSize = 0,
    // ignore: unused_element_parameter
    this.downloadedSize = 0,
  }) : _isComplete = false;

  bool get isComplete => _isComplete;

  void markComplete() {
    _isComplete = true;
    downloadedSize = totalSize;
  }
}

class _Range {
  final int start;
  final int? end;

  _Range(this.start, this.end);

  int? get endInclusive => end;
}
