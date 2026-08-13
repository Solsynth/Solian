/// A published Solsynth Express release.
class DistributionReleaseInfo {
  const DistributionReleaseInfo({
    required this.id,
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.createdAt,
    required this.publishedAt,
    required this.channel,
    required this.forceUpdate,
    required this.metadata,
    required this.artifacts,
  });

  final String id;
  final String tagName;
  final String name;
  final String body;
  final String? htmlUrl;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String channel;
  final bool forceUpdate;
  final Map<String, dynamic> metadata;
  final List<DistributionArtifact> artifacts;

  DistributionArtifact? artifactFor(String platform, String architecture) {
    for (final artifact in artifacts) {
      if (artifact.platform == platform &&
          artifact.architecture == architecture &&
          artifact.downloadUrl.isNotEmpty &&
          !artifact.expired) {
        return artifact;
      }
    }
    return null;
  }
}

class DistributionArtifact {
  const DistributionArtifact({
    required this.id,
    required this.platform,
    required this.architecture,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.hash,
    required this.downloadUrl,
    required this.expired,
  });

  final String id;
  final String platform;
  final String architecture;
  final String fileName;
  final String mimeType;
  final int size;
  final String hash;
  final String downloadUrl;
  final bool expired;
}

class DistributionProduct {
  const DistributionProduct({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.names,
    required this.descriptions,
    required this.raw,
  });

  final String id;
  final String slug;
  final String name;
  final String description;
  final Map<String, String> names;
  final Map<String, String> descriptions;
  final Map<String, dynamic> raw;
}

class DistributionPublisher {
  const DistributionPublisher({
    required this.id,
    required this.name,
    required this.raw,
  });

  final String id;
  final String name;
  final Map<String, dynamic> raw;
}

class DistributionMarketplaceApp {
  const DistributionMarketplaceApp({
    required this.product,
    required this.publisher,
    required this.latest,
  });

  final DistributionProduct product;
  final DistributionPublisher? publisher;
  final DistributionReleaseInfo? latest;
}

class DistributionPage<T> {
  const DistributionPage({
    required this.data,
    required this.total,
    required this.limit,
    required this.offset,
  });

  final List<T> data;
  final int total;
  final int limit;
  final int offset;
}

class DistributionUpdateCheck {
  const DistributionUpdateCheck({
    required this.updateAvailable,
    required this.currentVersion,
    required this.release,
  });

  final bool updateAvailable;
  final String currentVersion;
  final DistributionReleaseInfo? release;
}

class DistributionUploadPreparation {
  const DistributionUploadPreparation({
    required this.objectKey,
    required this.uploadUrl,
    required this.releaseId,
    required this.version,
  });

  final String objectKey;
  final String uploadUrl;
  final String releaseId;
  final String version;
}

Map<String, dynamic> distributionMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

String _string(Map<String, dynamic> map, String key, [String fallback = '']) =>
    (map[key] ?? fallback).toString();

Map<String, String> _strings(Object? value) {
  final map = distributionMap(value);
  return map.map((key, value) => MapEntry(key, value.toString()));
}

DistributionArtifact? distributionArtifactFromJson(Object? value) {
  final map = distributionMap(value);
  final downloadUrl = _string(map, 'download_url');
  if (downloadUrl.isEmpty && map.isEmpty) return null;
  return DistributionArtifact(
    id: _string(map, 'id'),
    platform: _string(map, 'platform'),
    architecture: _string(map, 'architecture'),
    fileName: _string(map, 'file_name'),
    mimeType: _string(map, 'mime_type'),
    size: (map['size'] as num?)?.toInt() ?? 0,
    hash: _string(map, 'hash'),
    downloadUrl: downloadUrl,
    expired: map['expired'] == true,
  );
}

DistributionReleaseInfo? distributionReleaseFromJson(Object? value) {
  final map = distributionMap(value);
  if (map.isEmpty) return null;
  final version = _string(map, 'version');
  if (version.isEmpty) return null;
  final artifacts = <DistributionArtifact>[];
  final rawArtifacts = map['artifacts'];
  if (rawArtifacts is List) {
    for (final rawArtifact in rawArtifacts) {
      final artifact = distributionArtifactFromJson(rawArtifact);
      if (artifact != null) artifacts.add(artifact);
    }
  }
  return DistributionReleaseInfo(
    id: _string(map, 'id'),
    tagName: version,
    name: _string(map, 'title', version),
    body: _string(map, 'release_notes', _string(map, 'description')),
    htmlUrl: map['html_url']?.toString(),
    createdAt: DateTime.tryParse(_string(map, 'created_at')) ?? DateTime.now(),
    publishedAt: DateTime.tryParse(_string(map, 'published_at')),
    channel: _string(map, 'channel', 'stable'),
    forceUpdate: map['force_update'] == true,
    metadata: distributionMap(map['metadata']),
    artifacts: artifacts,
  );
}

DistributionProduct distributionProductFromJson(Object? value) {
  final map = distributionMap(value);
  return DistributionProduct(
    id: _string(map, 'id'),
    slug: _string(map, 'slug'),
    name: _string(map, 'name'),
    description: _string(map, 'description'),
    names: _strings(map['names']),
    descriptions: _strings(map['descriptions']),
    raw: map,
  );
}

DistributionPublisher? distributionPublisherFromJson(Object? value) {
  if (value == null) return null;
  final map = distributionMap(value);
  if (map.isEmpty) return null;
  return DistributionPublisher(
    id: _string(map, 'id'),
    name: _string(map, 'name', _string(map, 'slug')),
    raw: map,
  );
}
