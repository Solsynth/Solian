// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnNotification {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get topic;
  String get title;
  String? get subtitle;
  String get body;
  Map<String, dynamic> get metadata;
  int get priority;
  int? get senderId;
  int get accountId;
  DateTime? get readAt;

  /// Create a copy of SnNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnNotificationCopyWith<SnNotification> get copyWith =>
      _$SnNotificationCopyWithImpl<SnNotification>(
          this as SnNotification, _$identity);

  /// Serializes this SnNotification to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnNotification &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.body, body) || other.body == body) &&
            const DeepCollectionEquality().equals(other.metadata, metadata) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.readAt, readAt) || other.readAt == readAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      topic,
      title,
      subtitle,
      body,
      const DeepCollectionEquality().hash(metadata),
      priority,
      senderId,
      accountId,
      readAt);

  @override
  String toString() {
    return 'SnNotification(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, topic: $topic, title: $title, subtitle: $subtitle, body: $body, metadata: $metadata, priority: $priority, senderId: $senderId, accountId: $accountId, readAt: $readAt)';
  }
}

/// @nodoc
abstract mixin class $SnNotificationCopyWith<$Res> {
  factory $SnNotificationCopyWith(
          SnNotification value, $Res Function(SnNotification) _then) =
      _$SnNotificationCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String topic,
      String title,
      String? subtitle,
      String body,
      Map<String, dynamic> metadata,
      int priority,
      int? senderId,
      int accountId,
      DateTime? readAt});
}

/// @nodoc
class _$SnNotificationCopyWithImpl<$Res>
    implements $SnNotificationCopyWith<$Res> {
  _$SnNotificationCopyWithImpl(this._self, this._then);

  final SnNotification _self;
  final $Res Function(SnNotification) _then;

  /// Create a copy of SnNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? topic = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? body = null,
    Object? metadata = null,
    Object? priority = null,
    Object? senderId = freezed,
    Object? accountId = null,
    Object? readAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      topic: null == topic
          ? _self.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: freezed == subtitle
          ? _self.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: freezed == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      readAt: freezed == readAt
          ? _self.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnNotification implements SnNotification {
  const _SnNotification(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.topic,
      required this.title,
      required this.subtitle,
      required this.body,
      final Map<String, dynamic> metadata = const {},
      required this.priority,
      required this.senderId,
      required this.accountId,
      required this.readAt})
      : _metadata = metadata;
  factory _SnNotification.fromJson(Map<String, dynamic> json) =>
      _$SnNotificationFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String topic;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String body;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final int priority;
  @override
  final int? senderId;
  @override
  final int accountId;
  @override
  final DateTime? readAt;

  /// Create a copy of SnNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnNotificationCopyWith<_SnNotification> get copyWith =>
      __$SnNotificationCopyWithImpl<_SnNotification>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnNotificationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnNotification &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.body, body) || other.body == body) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.readAt, readAt) || other.readAt == readAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      topic,
      title,
      subtitle,
      body,
      const DeepCollectionEquality().hash(_metadata),
      priority,
      senderId,
      accountId,
      readAt);

  @override
  String toString() {
    return 'SnNotification(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, topic: $topic, title: $title, subtitle: $subtitle, body: $body, metadata: $metadata, priority: $priority, senderId: $senderId, accountId: $accountId, readAt: $readAt)';
  }
}

/// @nodoc
abstract mixin class _$SnNotificationCopyWith<$Res>
    implements $SnNotificationCopyWith<$Res> {
  factory _$SnNotificationCopyWith(
          _SnNotification value, $Res Function(_SnNotification) _then) =
      __$SnNotificationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String topic,
      String title,
      String? subtitle,
      String body,
      Map<String, dynamic> metadata,
      int priority,
      int? senderId,
      int accountId,
      DateTime? readAt});
}

/// @nodoc
class __$SnNotificationCopyWithImpl<$Res>
    implements _$SnNotificationCopyWith<$Res> {
  __$SnNotificationCopyWithImpl(this._self, this._then);

  final _SnNotification _self;
  final $Res Function(_SnNotification) _then;

  /// Create a copy of SnNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? topic = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? body = null,
    Object? metadata = null,
    Object? priority = null,
    Object? senderId = freezed,
    Object? accountId = null,
    Object? readAt = freezed,
  }) {
    return _then(_SnNotification(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      topic: null == topic
          ? _self.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: freezed == subtitle
          ? _self.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: null == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: freezed == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      readAt: freezed == readAt
          ? _self.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
