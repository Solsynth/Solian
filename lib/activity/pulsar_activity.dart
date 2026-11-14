import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Pulsar stores a live presence as an `ActiveSession`: `domain` replaces the
/// legacy activity `type`, and artwork is carried in `artwork_url` as well as
/// `large_image`. The rest of the UI still renders `SnPresenceActivity`, so
/// this is the single place that bridges the two wire shapes.
SnPresenceActivity pulsarActivityFromJson(Map<String, dynamic> json) {
  final startedAt = _date(json['started_at']);
  final endedAt = _date(json['ended_at']);
  final createdAt =
      _date(json['created_at']) ?? startedAt ?? DateTime.now().toUtc();
  final updatedAt = _date(json['updated_at']) ?? createdAt;
  final leaseExpiresAt =
      _date(json['lease_expires_at']) ?? endedAt ?? updatedAt;
  final meta = json['meta'];
  final metaMap = meta is Map ? Map<String, dynamic>.from(meta) : null;

  return SnPresenceActivity(
    id: json['id']?.toString() ?? '',
    type: pulsarDomainToType((json['domain'] ?? json['type'])?.toString()),
    manualId: json['manual_id']?.toString(),
    title: json['title']?.toString(),
    subtitle: json['subtitle']?.toString(),
    caption: json['caption']?.toString(),
    titleUrl:
        json['title_url']?.toString() ?? metaMap?['title_url']?.toString(),
    subtitleUrl:
        json['subtitle_url']?.toString() ??
        metaMap?['subtitle_url']?.toString(),
    smallImage: json['small_image']?.toString(),
    largeImage: (json['large_image'] ?? json['artwork_url'])?.toString(),
    meta: metaMap,
    leaseMinutes: _int(json['lease_minutes']) ?? 5,
    leaseExpiresAt: leaseExpiresAt,
    accountId: json['account_id']?.toString() ?? '',
    tags: _tags(json['tags']),
    visibility: presenceVisibilityFromJson(json['visibility']) ?? 'public',
    startedAt: startedAt,
    endedAt: endedAt,
    catalogId: json['catalog_id']?.toString(),
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: _date(json['deleted_at']),
  );
}

/// Parses the list returned by Pulsar's now-playing endpoints.
List<SnPresenceActivity> pulsarActivitiesFromJson(dynamic data) {
  if (data is! List) return const [];
  return [
    for (final item in data)
      if (item is Map) pulsarActivityFromJson(Map<String, dynamic>.from(item)),
  ];
}

/// Groups Pulsar's batch presence response by account id.
Map<String, List<SnPresenceActivity>> pulsarActivitiesByAccount(dynamic data) {
  final grouped = <String, List<SnPresenceActivity>>{};
  for (final activity in pulsarActivitiesFromJson(data)) {
    if (activity.accountId.isEmpty) continue;
    grouped.putIfAbsent(activity.accountId, () => []).add(activity);
  }
  return grouped;
}

/// Converts the Discord-RPC activity body the app keeps locally into Pulsar's
/// `sessions/now-playing` request. Pulsar names the activity kind `domain` and
/// accepts artwork as either `artwork_url` or `large_image`.
Map<String, dynamic> pulsarNowPlayingBody(Map<String, dynamic> activity) {
  final title = activity['title']?.toString().trim();
  final subtitle = activity['subtitle']?.toString();
  final caption = activity['caption']?.toString();
  final largeImage = (activity['large_image'] ?? activity['artwork_url'])
      ?.toString();
  final smallImage = activity['small_image']?.toString();
  final provider = activity['provider']?.toString();
  final referenceId = activity['reference_id']?.toString();
  final meta = activity['meta'];
  final domain = (activity['domain'] ?? activity['type'])?.toString();

  final body = <String, dynamic>{
    'domain': domain == null || domain.isEmpty ? 'custom' : domain,
    'manual_id': activity['manual_id']?.toString() ?? 'default',
    'title': title == null || title.isEmpty ? 'Unknown' : title,
    'lease_minutes': _int(activity['lease_minutes']) ?? 5,
  };
  if (subtitle != null) body['subtitle'] = subtitle;
  if (caption != null) body['caption'] = caption;
  if (largeImage != null && largeImage.isNotEmpty) {
    body['artwork_url'] = largeImage;
    body['large_image'] = largeImage;
  }
  if (smallImage != null && smallImage.isNotEmpty) {
    body['small_image'] = smallImage;
  }
  if (provider != null && provider.isNotEmpty) body['provider'] = provider;
  if (referenceId != null && referenceId.isNotEmpty) {
    body['provider_key'] = referenceId;
  }
  if (meta is Map) body['meta'] = meta;
  return body;
}

/// Maps Pulsar media domains onto the UI's presence taxonomy. Domains without
/// a dedicated icon collapse onto the closest existing kind.
String pulsarDomainToType(String? domain) {
  return switch (domain) {
    null || '' || 'custom' => 'other',
    'video' || 'anime' => 'entertainment',
    'book' => 'reading',
    final value => value,
  };
}

DateTime? _date(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

int? _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<SnPresenceTag> _tags(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map && (item['slug']?.toString().isNotEmpty ?? false))
        SnPresenceTag(
          slug: item['slug']!.toString(),
          name: item['name']?.toString(),
        ),
  ];
}
