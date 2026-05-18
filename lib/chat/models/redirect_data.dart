import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'redirect_data.freezed.dart';

/// Frozen snapshot of a redirected chat history segment or single message.
///
/// Two variants:
/// - [SnRedirectData.singleMessage] — version 1, exactly one source message
/// - [SnRedirectData.historySegment] — version 2, multiple source messages
@freezed
sealed class SnRedirectData with _$SnRedirectData {
  const SnRedirectData._();

  /// Single-message redirect (version 1).
  const factory SnRedirectData.singleMessage({
    required int version,
    required String sourceType,
    required String sourceRoomId,
    required String sourceSenderId,
    required int sourceCreatedAt,
    required String sourceMessageId,
    String? sourceContent,
    String? sourceSenderName,
    @Default({}) Map<String, dynamic> sourceMeta,
    @Default([]) List<Map<String, dynamic>> sourceAttachments,
    required Map<String, dynamic> sourceRoom,
    required Map<String, dynamic> redirectedBy,
    required Map<String, dynamic> redirectedToRoom,
    required Map<String, dynamic> sourceMessage,
    @Default({}) Map<String, dynamic> senderMap,
  }) = _SnSingleMessageRedirect;

  /// History-segment redirect (version 2).
  const factory SnRedirectData.historySegment({
    required int version,
    required String kind,
    required String sourceRoomId,
    required Map<String, dynamic> sourceRoom,
    required Map<String, dynamic> redirectedBy,
    required Map<String, dynamic> redirectedToRoom,
    required Map<String, dynamic> range,
    @Default([]) List<Map<String, dynamic>> messages,
    @Default({}) Map<String, dynamic> senderMap,
  }) = _SnHistorySegmentRedirect;

  factory SnRedirectData.fromJson(Map<String, dynamic> json) {
    if (json['kind'] == 'history_segment' || json['version'] == 2) {
      return SnRedirectData.historySegment(
        version: (json['version'] as num?)?.toInt() ?? 2,
        kind: (json['kind'] as String?) ?? 'history_segment',
        sourceRoomId: json['source_room_id'] as String? ?? '',
        sourceRoom: _safeMap(json['source_room']),
        redirectedBy: _safeMap(json['redirected_by']),
        redirectedToRoom: _safeMap(json['redirected_to_room']),
        range: _safeMap(json['range']),
        messages: _safeMapList(json['messages']),
        senderMap: _safeMap(json['sender_map']),
      );
    }
    return SnRedirectData.singleMessage(
      version: (json['version'] as num?)?.toInt() ?? 1,
      sourceType: json['source_type'] as String? ?? 'text',
      sourceRoomId: json['source_room_id'] as String? ?? '',
      sourceSenderId: json['source_sender_id'] as String? ?? '',
      sourceCreatedAt: (json['source_created_at'] as num?)?.toInt() ?? 0,
      sourceMessageId: json['source_message_id'] as String? ?? '',
      sourceContent: json['source_content'] as String?,
      sourceSenderName: json['source_sender_name'] as String?,
      sourceMeta: _safeMap(json['source_meta']),
      sourceAttachments: _safeMapList(json['source_attachments']),
      sourceRoom: _safeMap(json['source_room']),
      redirectedBy: _safeMap(json['redirected_by']),
      redirectedToRoom: _safeMap(json['redirected_to_room']),
      sourceMessage: _safeMap(json['source_message']),
      senderMap: _safeMap(json['sender_map']),
    );
  }

  // ---------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------

  /// Human-readable source room name.
  String get sourceRoomName {
    final room = map(
      singleMessage: (d) => d.sourceRoom,
      historySegment: (d) => d.sourceRoom,
    );
    return _resolveRoomName(room);
  }

  /// Resolved content for single-message redirects.
  String? get resolvedSourceContent => map(
    singleMessage: (d) =>
        d.sourceContent ?? d.sourceMessage['content']?.toString(),
    historySegment: (_) => null,
  );

  /// Resolved sender display name for single-message redirects.
  String? get resolvedSourceSenderName => map(
    singleMessage: (d) => _resolveSenderDisplayName(
      topLevelName: d.sourceSenderName,
      senderMap: d.senderMap,
      senderId: d.sourceSenderId,
      message: d.sourceMessage,
    ),
    historySegment: (_) => null,
  );

  /// Parsed attachments for single-message redirects.
  List<IDisplayableCloudFile> get resolvedSourceAttachments => map(
    singleMessage: (d) {
      final raw = d.sourceAttachments.isNotEmpty
          ? d.sourceAttachments
          : _safeMapList(d.sourceMessage['attachments']);
      return _parseAttachments(raw, d.sourceCreatedAt);
    },
    historySegment: (_) => const [],
  );

  /// Profile picture of the source sender (V1 only).
  SnCloudFile? get sourceSenderProfilePicture => map(
    singleMessage: (d) => _extractProfilePicture(
      senderMap: d.senderMap,
      senderId: d.sourceSenderId,
      message: d.sourceMessage,
    ),
    historySegment: (_) => null,
  );

  /// Profile picture ID of the source sender (V1 only).
  /// Unlike [sourceSenderProfilePicture], this avoids `SnCloudFile.fromJson`
  /// and works directly with the raw JSON picture ID.
  String? get sourceSenderPictureId => map(
    singleMessage: (d) => _resolveSenderPictureId(
      senderMap: d.senderMap,
      senderId: d.sourceSenderId,
      message: d.sourceMessage,
    ),
    historySegment: (_) => null,
  );

  /// Number of messages in the redirect.
  int get messageCount => map(
    singleMessage: (_) => 1,
    historySegment: (d) {
      final count = d.range['message_count'];
      if (count is int) return count;
      if (count is String) return int.tryParse(count) ?? d.messages.length;
      return d.messages.length;
    },
  );

  // ---------------------------------------------------------------
  // Redirected-by accessors
  // ---------------------------------------------------------------

  /// Display name of the member who performed the redirect.
  String? get redirectedByName => map(
    singleMessage: (d) => _extractName(d.redirectedBy),
    historySegment: (d) => _extractName(d.redirectedBy),
  );

  /// Profile picture of the member who performed the redirect.
  SnCloudFile? get redirectedByProfilePicture => map(
    singleMessage: (d) => _extractPictureMember(d.redirectedBy),
    historySegment: (d) => _extractPictureMember(d.redirectedBy),
  );

  // ---------------------------------------------------------------
  // Per-message accessors (V2 history segment)
  // ---------------------------------------------------------------

  /// Sender display name for a message at [index] in the history segment.
  String? historyMessageSenderName(int index) => map(
    singleMessage: (_) => null,
    historySegment: (d) {
      if (index < 0 || index >= d.messages.length) return null;
      final msg = d.messages[index];
      return _resolveSenderDisplayName(
        senderMap: d.senderMap,
        senderId: msg['sender_id']?.toString(),
        message: msg,
      );
    },
  );

  /// Sender profile picture for a message at [index] in the history segment.
  SnCloudFile? historyMessageSenderPicture(int index) => map(
    singleMessage: (_) => null,
    historySegment: (d) {
      if (index < 0 || index >= d.messages.length) return null;
      return _extractProfilePicture(
        senderMap: d.senderMap,
        senderId: d.messages[index]['sender_id']?.toString(),
        message: d.messages[index],
      );
    },
  );

  /// Sender account name (username) for a message at [index].
  String? historyMessageSenderAccountName(int index) => map(
    singleMessage: (_) => null,
    historySegment: (d) {
      if (index < 0 || index >= d.messages.length) return null;
      final msg = d.messages[index];
      return _resolveSenderField(
        senderMap: d.senderMap,
        senderId: msg['sender_id']?.toString(),
        message: msg,
        field: 'name',
        accountField: 'name',
      );
    },
  );

  /// Sender account nick for a message at [index].
  String? historyMessageSenderAccountNick(int index) => map(
    singleMessage: (_) => null,
    historySegment: (d) {
      if (index < 0 || index >= d.messages.length) return null;
      final msg = d.messages[index];
      return _resolveSenderField(
        senderMap: d.senderMap,
        senderId: msg['sender_id']?.toString(),
        message: msg,
        field: 'nick',
        accountField: 'nick',
      );
    },
  );

  /// Resolved [SnAccount] for a message sender at [index], for use with [AccountName].
  /// Returns null if the account data can't be parsed from the snapshot.
  SnAccount? historyMessageSenderAccount(int index) => map(
    singleMessage: (_) => null,
    historySegment: (d) {
      if (index < 0 || index >= d.messages.length) return null;
      final msg = d.messages[index];
      return _resolveSnAccount(
        senderMap: d.senderMap,
        senderId: msg['sender_id']?.toString(),
        message: msg,
      );
    },
  );

  /// Content text for a message at [index].
  String? historyMessageContent(int index) => map(
    singleMessage: (_) => null,
    historySegment: (d) {
      if (index < 0 || index >= d.messages.length) return null;
      return d.messages[index]['content']?.toString();
    },
  );

  /// Number of attachments for a message at [index].
  int historyMessageAttachmentCount(int index) => map(
    singleMessage: (_) => 0,
    historySegment: (d) {
      if (index < 0 || index >= d.messages.length) return 0;
      final raw = d.messages[index]['attachments'];
      return raw is List ? raw.length : 0;
    },
  );

  /// Resolved attachments for a message at [index] as [SnCloudFile] list.
  List<IDisplayableCloudFile> historyMessageResolvedAttachments(int index) =>
      map(
        singleMessage: (_) => const [],
        historySegment: (d) {
          if (index < 0 || index >= d.messages.length) return const [];
          final msg = d.messages[index];
          final raw = msg['attachments'];
          final list = raw is List
              ? raw
                    .whereType<Map>()
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList()
              : <Map<String, dynamic>>[];
          final createdAt = (msg['created_at'] as num?)?.toInt() ?? 0;
          return _parseAttachmentThumbnails(list, createdAt);
        },
      );

  /// Picture id of a message sender at [index] (used for ProfilePictureWidget with fileId).
  String? historyMessageSenderPictureId(int index) => map(
    singleMessage: (_) => null,
    historySegment: (d) {
      if (index < 0 || index >= d.messages.length) return null;
      final msg = d.messages[index];
      return _resolveSenderPictureId(
        senderMap: d.senderMap,
        senderId: msg['sender_id']?.toString(),
        message: msg,
      );
    },
  );
}

// -----------------------------------------------------------------
// Internal helpers
// -----------------------------------------------------------------

Map<String, dynamic> _safeMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> _safeMapList(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

String _resolveRoomName(Map<String, dynamic> room) {
  final explicitName = room['name']?.toString();
  if (explicitName != null && explicitName.trim().isNotEmpty) {
    return explicitName;
  }
  if (room['type']?.toString() == 'DirectMessage') {
    return 'directMessage'.tr();
  }
  return 'chat'.tr();
}

/// Resolve display name with precedence:
/// 1. Top-level name hint (e.g. source_sender_name)
/// 2. sender_map entry's nick or account.nick
/// 3. Inline sender nick or account.nick
String? _resolveSenderDisplayName({
  String? topLevelName,
  required Map<String, dynamic> senderMap,
  String? senderId,
  required Map<String, dynamic> message,
}) {
  if (topLevelName != null && topLevelName.trim().isNotEmpty) {
    return topLevelName;
  }
  return _resolveSenderNick(
        senderMap: senderMap,
        senderId: senderId,
        message: message,
      ) ??
      _resolveSenderAccountNick(
        senderMap: senderMap,
        senderId: senderId,
        message: message,
      );
}

/// Resolve a generic sender field with fallback chain:
/// sender_map[senderId] → sender_map[by account.id] → message['sender']
String? _resolveSenderField({
  required Map<String, dynamic> senderMap,
  String? senderId,
  required Map<String, dynamic> message,
  required String field,
  String? accountField,
}) {
  Map<String, dynamic>? sender;
  if (senderId != null && senderMap.isNotEmpty) {
    sender = senderMap[senderId] is Map
        ? Map<String, dynamic>.from(senderMap[senderId])
        : null;
    sender ??= _findSenderByAccountId(senderMap, senderId);
  }
  sender ??= message['sender'] is Map
      ? Map<String, dynamic>.from(message['sender'])
      : null;
  if (sender == null) return null;

  final value = sender[field]?.toString();
  if (value != null && value.trim().isNotEmpty) return value;

  if (accountField != null) {
    final account = sender['account'] is Map
        ? Map<String, dynamic>.from(sender['account'])
        : null;
    return account?[accountField]?.toString();
  }
  return null;
}

/// Search sender_map values for a sender whose account.id matches.
Map<String, dynamic>? _findSenderByAccountId(
  Map<String, dynamic> senderMap,
  String accountId,
) {
  for (final entry in senderMap.entries) {
    if (entry.value is Map) {
      final senderData = Map<String, dynamic>.from(entry.value);
      final account = senderData['account'] is Map
          ? Map<String, dynamic>.from(senderData['account'])
          : null;
      if (account?['id'] == accountId) {
        return senderData;
      }
    }
  }
  return null;
}

String? _resolveSenderNick({
  required Map<String, dynamic> senderMap,
  String? senderId,
  required Map<String, dynamic> message,
}) {
  Map<String, dynamic>? sender;
  if (senderId != null && senderMap.isNotEmpty) {
    sender = senderMap[senderId] is Map
        ? Map<String, dynamic>.from(senderMap[senderId])
        : null;
    sender ??= _findSenderByAccountId(senderMap, senderId);
  }
  sender ??= message['sender'] is Map
      ? Map<String, dynamic>.from(message['sender'])
      : null;
  if (sender == null) return null;

  return (sender['nick']?.toString()) ?? (sender['realm_nick']?.toString());
}

String? _resolveSenderAccountNick({
  required Map<String, dynamic> senderMap,
  String? senderId,
  required Map<String, dynamic> message,
}) {
  Map<String, dynamic>? sender;
  if (senderId != null && senderMap.isNotEmpty) {
    sender = senderMap[senderId] is Map
        ? Map<String, dynamic>.from(senderMap[senderId])
        : null;
    sender ??= _findSenderByAccountId(senderMap, senderId);
  }
  sender ??= message['sender'] is Map
      ? Map<String, dynamic>.from(message['sender'])
      : null;
  if (sender == null) return null;

  final account = sender['account'] is Map
      ? Map<String, dynamic>.from(sender['account'])
      : null;
  return account?['nick']?.toString();
}

String? _resolveSenderPictureId({
  required Map<String, dynamic> senderMap,
  String? senderId,
  required Map<String, dynamic> message,
}) {
  Map<String, dynamic>? sender;
  if (senderId != null && senderMap.isNotEmpty) {
    sender = senderMap[senderId] is Map
        ? Map<String, dynamic>.from(senderMap[senderId])
        : null;
    sender ??= _findSenderByAccountId(senderMap, senderId);
  }
  sender ??= message['sender'] is Map
      ? Map<String, dynamic>.from(message['sender'])
      : null;
  if (sender == null) return null;

  final account = sender['account'] is Map
      ? Map<String, dynamic>.from(sender['account'])
      : null;
  final profileRaw = account?['profile'];
  final profile = profileRaw is Map
      ? Map<String, dynamic>.from(profileRaw)
      : null;
  final pictureRaw = profile?['picture'];
  final picture = pictureRaw is Map
      ? Map<String, dynamic>.from(pictureRaw)
      : null;
  return picture?['id']?.toString();
}

SnCloudFile? _extractProfilePicture({
  required Map<String, dynamic> senderMap,
  String? senderId,
  required Map<String, dynamic> message,
}) {
  Map<String, dynamic>? sender;
  if (senderId != null && senderMap.isNotEmpty) {
    sender = senderMap[senderId] is Map
        ? Map<String, dynamic>.from(senderMap[senderId])
        : null;
    sender ??= _findSenderByAccountId(senderMap, senderId);
  }
  sender ??= message['sender'] is Map
      ? Map<String, dynamic>.from(message['sender'])
      : null;
  if (sender == null) return null;

  final account = sender['account'] is Map
      ? Map<String, dynamic>.from(sender['account'])
      : null;
  final profileRaw = account?['profile'];
  final profile = profileRaw is Map
      ? Map<String, dynamic>.from(profileRaw)
      : null;
  final pictureRaw = profile?['picture'];
  final picture = pictureRaw is Map
      ? Map<String, dynamic>.from(pictureRaw)
      : null;
  if (picture == null) return null;

  try {
    return SnCloudFile.fromJson(picture);
  } catch (_) {
    return null;
  }
}

/// Extract display name from a member map.
String? _extractName(Map<String, dynamic> member) {
  return member['nick']?.toString() ??
      member['realm_nick']?.toString() ??
      (member['account'] is Map
          ? (member['account'] as Map)['nick']?.toString()
          : null);
}

/// Extract profile picture from a member map.
SnCloudFile? _extractPictureMember(Map<String, dynamic> member) {
  final account = member['account'] is Map
      ? Map<String, dynamic>.from(member['account'])
      : null;
  final profileRaw = account?['profile'];
  final profile = profileRaw is Map
      ? Map<String, dynamic>.from(profileRaw)
      : null;
  final pictureRaw = profile?['picture'];
  final picture = pictureRaw is Map
      ? Map<String, dynamic>.from(pictureRaw)
      : null;
  if (picture == null) return null;
  try {
    return SnCloudFile.fromJson(picture);
  } catch (_) {
    return null;
  }
}

/// Parse redirect attachments into SnCloudFile objects.
/// Redirect snapshots omit created_at/updated_at from attachments, so we
/// inject them from [messageCreatedAt] before deserializing.
List<IDisplayableCloudFile> _parseAttachments(
  List<Map<String, dynamic>> raw,
  int messageCreatedAt,
) {
  if (raw.isEmpty) return const [];
  return raw
      .map((e) {
        try {
          final enriched = Map<String, dynamic>.from(e);
          if (!enriched.containsKey('hash')) enriched['hash'] = '';
          enriched['created_at'] ??= messageCreatedAt;
          enriched['updated_at'] ??= messageCreatedAt;
          return SnCloudFileReference.fromJson(enriched);
        } catch (err) {
          return null;
        }
      })
      .whereType<SnCloudFileReference>()
      .toList();
}

/// Parses redirect attachment snapshots into [SnCloudFile] objects.
/// Redirect attachments may lack standard fields like `created_at`/`updated_at`.
/// [messageCreatedAt] is used as a fallback for these required fields.
List<IDisplayableCloudFile> _parseAttachmentThumbnails(
  List<Map<String, dynamic>> raw,
  int messageCreatedAt,
) {
  if (raw.isEmpty) return const [];
  return raw
      .map((e) {
        try {
          final enriched = Map<String, dynamic>.from(e);
          if (!enriched.containsKey('hash')) enriched['hash'] = '';
          enriched['created_at'] ??= messageCreatedAt;
          enriched['updated_at'] ??= messageCreatedAt;
          return SnCloudFileReference.fromJson(enriched);
        } catch (err) {
          return null;
        }
      })
      .whereType<SnCloudFileReference>()
      .toList();
}

/// Resolves sender member map from [senderMap] or inline [message], then extracts and
/// safely constructs [SnAccount] from the nested account JSON.
SnAccount? _resolveSnAccount({
  required Map<String, dynamic> senderMap,
  String? senderId,
  required Map<String, dynamic> message,
}) {
  Map<String, dynamic>? sender;
  if (senderId != null && senderMap.isNotEmpty) {
    sender = senderMap[senderId] is Map
        ? Map<String, dynamic>.from(senderMap[senderId])
        : null;
    sender ??= _findSenderByAccountId(senderMap, senderId);
  }
  sender ??= message['sender'] is Map
      ? Map<String, dynamic>.from(message['sender'])
      : null;
  if (sender == null) return null;

  final accountRaw = sender['account'];
  if (accountRaw is! Map) return null;
  final accountJson = Map<String, dynamic>.from(accountRaw);

  // Null out picture/background that may be incomplete in redirect snapshots
  // to avoid SnCloudFile.fromJson failures.
  final profileRaw = accountJson['profile'];
  if (profileRaw is Map<String, dynamic>) {
    final profile = Map<String, dynamic>.from(profileRaw);
    if (profile['picture'] is Map) {
      final pic = Map<String, dynamic>.from(profile['picture'] as Map);
      if (!_isValidSnCloudFile(pic)) {
        profile['picture'] = null;
      }
    }
    if (profile['background'] is Map) {
      final bg = Map<String, dynamic>.from(profile['background'] as Map);
      if (!_isValidSnCloudFile(bg)) {
        profile['background'] = null;
      }
    }
    accountJson['profile'] = profile;
  }

  try {
    return SnAccount.fromJson(accountJson);
  } catch (_) {
    return null;
  }
}

bool _isValidSnCloudFile(Map<String, dynamic> json) {
  return json['created_at'] != null && json['updated_at'] != null;
}
