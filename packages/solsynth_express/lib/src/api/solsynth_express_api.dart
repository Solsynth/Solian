import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'models.dart';

/// REST client for the public marketplace, update, and artifact contracts.
class SolsynthExpressApi {
  SolsynthExpressApi({
    required String baseUrl,
    required this.productId,
    Dio? dio,
    this.apiKey,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               headers: {
                 'Accept': 'application/json',
                 'User-Agent': 'solsynth-express-dart',
               },
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
             ),
           ),
       baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');

  final Dio _dio;
  final String baseUrl;
  final String productId;
  final String? apiKey;

  bool get isConfigured =>
      baseUrl.trim().isNotEmpty && productId.trim().isNotEmpty;

  String _productPath([String suffix = '']) =>
      '$baseUrl/products/${Uri.encodeComponent(productId)}$suffix';

  Options _options({String? token}) {
    final bearer = token ?? apiKey;
    return bearer == null || bearer.isEmpty
        ? Options()
        : Options(headers: {'Authorization': 'Bearer $bearer'});
  }

  Future<DistributionPage<DistributionMarketplaceApp>> listMarketplaceApps({
    String sort = 'updated_at',
    bool descending = true,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get<dynamic>(
      '$baseUrl/marketplace/apps',
      queryParameters: {
        'sort': sort,
        'order': descending ? 'desc' : 'asc',
        'limit': limit,
        'offset': offset,
      },
    );
    final data = distributionMap(response.data);
    final items = <DistributionMarketplaceApp>[];
    final rawItems = data['data'];
    if (rawItems is List) {
      for (final rawItem in rawItems) {
        final item = distributionMap(rawItem);
        final product = distributionProductFromJson(item['product']);
        if (product.id.isEmpty) continue;
        items.add(
          DistributionMarketplaceApp(
            product: product,
            publisher: distributionPublisherFromJson(item['publisher']),
            latest: distributionReleaseFromJson(item['latest']),
          ),
        );
      }
    }
    return DistributionPage(
      data: items,
      total: (data['total'] as num?)?.toInt() ?? items.length,
      limit: (data['limit'] as num?)?.toInt() ?? limit,
      offset: (data['offset'] as num?)?.toInt() ?? offset,
    );
  }

  Future<DistributionProduct> getProduct([String? id]) async {
    final response = await _dio.get<dynamic>(
      '$baseUrl/products/${Uri.encodeComponent(id ?? productId)}',
    );
    final data = distributionMap(response.data);
    return distributionProductFromJson(data['product'] ?? data);
  }

  Future<List<DistributionChannel>> listChannels() async {
    final response = await _dio.get<dynamic>(_productPath('/channels'));
    final rawChannels = distributionMap(response.data)['data'];
    if (rawChannels is! List) return const [];
    return rawChannels
        .map(distributionChannelFromJson)
        .whereType<DistributionChannel>()
        .toList();
  }

  Future<List<DistributionProduct>> listPublisherApps(
    String publisherName,
  ) async {
    final response = await _dio.get<dynamic>(
      '$baseUrl/publishers/${Uri.encodeComponent(publisherName)}/apps',
    );
    final data = distributionMap(response.data)['data'];
    if (data is! List) return const [];
    return data.map(distributionProductFromJson).toList();
  }

  Future<DistributionPage<DistributionReleaseInfo>> listReleases({
    String channel = 'stable',
    String? platform,
    String? architecture,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get<dynamic>(
      _productPath('/releases'),
      queryParameters: {
        'channel': channel,
        // ignore: use_null_aware_elements
        if (platform case final value?) 'platform': value,
        // ignore: use_null_aware_elements
        if (architecture case final value?) 'architecture': value,
        'limit': limit,
        'offset': offset,
      },
    );
    final data = distributionMap(response.data);
    final releases = <DistributionReleaseInfo>[];
    final rawReleases = data['data'];
    if (rawReleases is List) {
      for (final rawRelease in rawReleases) {
        final release = distributionReleaseFromJson(rawRelease);
        if (release != null) releases.add(release);
      }
    }
    return DistributionPage(
      data: releases,
      total: (data['total'] as num?)?.toInt() ?? releases.length,
      limit: (data['limit'] as num?)?.toInt() ?? limit,
      offset: (data['offset'] as num?)?.toInt() ?? offset,
    );
  }

  Future<DistributionReleaseInfo?> fetchLatestRelease({
    String channel = 'stable',
    required String platform,
    required String architecture,
  }) async {
    final page = await listReleases(
      channel: channel,
      platform: platform,
      architecture: architecture,
      limit: 1,
    );
    return page.data.isEmpty ? null : page.data.first;
  }

  Future<DistributionUpdateCheck> checkForUpdate({
    required String currentVersion,
    required String platform,
    required String architecture,
    String channel = 'stable',
    String? installationId,
    String? osVersion,
    String? clientVersion,
    String? locale,
  }) async {
    final response = await _dio.get<dynamic>(
      _productPath('/update'),
      queryParameters: {
        'current_version': currentVersion,
        'channel': channel,
        'os': platform,
        'architecture': architecture,
        // ignore: use_null_aware_elements
        if (installationId case final value?) 'installation_id': value,
        // ignore: use_null_aware_elements
        if (osVersion case final value?) 'os_version': value,
        // ignore: use_null_aware_elements
        if (clientVersion case final value?) 'client_version': value,
        // ignore: use_null_aware_elements
        if (locale case final value?) 'locale': value,
      },
    );
    final data = distributionMap(response.data);
    return DistributionUpdateCheck(
      updateAvailable: data['update_available'] == true,
      currentVersion: (data['current_version'] ?? currentVersion).toString(),
      release: distributionReleaseFromJson(data['release']),
    );
  }

  Future<DistributionUpdateCheck> submitUpdateCheck({
    required String currentVersion,
    required String platform,
    required String architecture,
    String channel = 'stable',
    String? installationId,
    String? osVersion,
    String? clientVersion,
    String? locale,
  }) async {
    final response = await _dio.post<dynamic>(
      _productPath('/update/check'),
      data: {
        'version': currentVersion,
        'current_version': currentVersion,
        'channel': channel,
        'os': platform,
        'architecture': architecture,
        // ignore: use_null_aware_elements
        if (installationId case final value?) 'installation_id': value,
        // ignore: use_null_aware_elements
        if (osVersion case final value?) 'os_version': value,
        // ignore: use_null_aware_elements
        if (clientVersion case final value?) 'client_version': value,
        // ignore: use_null_aware_elements
        if (locale case final value?) 'locale': value,
      },
    );
    final data = distributionMap(response.data);
    return DistributionUpdateCheck(
      updateAvailable: data['update_available'] == true,
      currentVersion: (data['current_version'] ?? currentVersion).toString(),
      release: distributionReleaseFromJson(data['release']),
    );
  }

  Future<DistributionUploadPreparation> prepareArtifactUpload({
    required String fileName,
    required String mimeType,
    required String sha256,
    required String version,
    String channel = 'stable',
  }) async {
    final response = await _dio.post<dynamic>(
      _productPath('/artifacts/upload-url'),
      options: _options(),
      data: {
        'file_name': fileName,
        'mime_type': mimeType,
        'sha256': sha256,
        'channel': channel,
        'version': version,
      },
    );
    final data = distributionMap(response.data);
    final preparation = DistributionUploadPreparation(
      objectKey: (data['object_key'] ?? '').toString(),
      uploadUrl: (data['upload_url'] ?? '').toString(),
      releaseId: (data['release_id'] ?? '').toString(),
      version: (data['version'] ?? version).toString(),
    );
    if (preparation.objectKey.isEmpty || preparation.uploadUrl.isEmpty) {
      throw const FormatException(
        'Distribution upload response is incomplete.',
      );
    }
    return preparation;
  }

  Future<void> uploadPreparedArtifact({
    required DistributionUploadPreparation preparation,
    required List<int> bytes,
    required String mimeType,
    required String sha256,
    void Function(int sent, int total)? onProgress,
  }) async {
    final response = await _dio.put<dynamic>(
      preparation.uploadUrl,
      data: Uint8List.fromList(bytes),
      options: Options(
        headers: {'Content-Type': mimeType, 'x-amz-meta-sha256': sha256},
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
      onSendProgress: onProgress,
    );
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw DioException.badResponse(
        statusCode: response.statusCode ?? 0,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }

  Future<DistributionReleaseInfo?> attachArtifact({
    required DistributionUploadPreparation preparation,
    required String fileName,
    required String mimeType,
    required int size,
    required String sha256,
    required String platform,
    required String architecture,
  }) async {
    final releaseRef = preparation.releaseId.isNotEmpty
        ? preparation.releaseId
        : preparation.version;
    final response = await _dio.post<dynamic>(
      _productPath('/releases/${Uri.encodeComponent(releaseRef)}/artifacts'),
      options: _options(),
      data: {
        'object_key': preparation.objectKey,
        'file_name': fileName,
        'mime_type': mimeType,
        'size': size,
        'hash': sha256,
        'platform': platform,
        'architecture': architecture,
      },
    );
    return distributionReleaseFromJson(response.data);
  }

  Future<DistributionReleaseInfo?> uploadArtifact({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required String version,
    required String platform,
    required String architecture,
    String channel = 'stable',
    void Function(int sent, int total)? onProgress,
  }) async {
    final sha256 = sha256Digest(bytes);
    final preparation = await prepareArtifactUpload(
      fileName: fileName,
      mimeType: mimeType,
      sha256: sha256,
      version: version,
      channel: channel,
    );
    await uploadPreparedArtifact(
      preparation: preparation,
      bytes: bytes,
      mimeType: mimeType,
      sha256: sha256,
      onProgress: onProgress,
    );
    return attachArtifact(
      preparation: preparation,
      fileName: fileName,
      mimeType: mimeType,
      size: bytes.length,
      sha256: sha256,
      platform: platform,
      architecture: architecture,
    );
  }
}

String sha256Digest(List<int> bytes) => sha256.convert(bytes).toString();
