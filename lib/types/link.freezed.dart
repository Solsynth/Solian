// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnLinkMeta {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get entryId;
  String? get icon;
  String get url;
  String? get title;
  String? get image;
  String? get video;
  String? get audio;
  String? get description;
  String? get siteName;
  String? get type;

  /// Create a copy of SnLinkMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnLinkMetaCopyWith<SnLinkMeta> get copyWith =>
      _$SnLinkMetaCopyWithImpl<SnLinkMeta>(this as SnLinkMeta, _$identity);

  /// Serializes this SnLinkMeta to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnLinkMeta &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.entryId, entryId) || other.entryId == entryId) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.siteName, siteName) ||
                other.siteName == siteName) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      entryId,
      icon,
      url,
      title,
      image,
      video,
      audio,
      description,
      siteName,
      type);

  @override
  String toString() {
    return 'SnLinkMeta(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, entryId: $entryId, icon: $icon, url: $url, title: $title, image: $image, video: $video, audio: $audio, description: $description, siteName: $siteName, type: $type)';
  }
}

/// @nodoc
abstract mixin class $SnLinkMetaCopyWith<$Res> {
  factory $SnLinkMetaCopyWith(
          SnLinkMeta value, $Res Function(SnLinkMeta) _then) =
      _$SnLinkMetaCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String entryId,
      String? icon,
      String url,
      String? title,
      String? image,
      String? video,
      String? audio,
      String? description,
      String? siteName,
      String? type});
}

/// @nodoc
class _$SnLinkMetaCopyWithImpl<$Res> implements $SnLinkMetaCopyWith<$Res> {
  _$SnLinkMetaCopyWithImpl(this._self, this._then);

  final SnLinkMeta _self;
  final $Res Function(SnLinkMeta) _then;

  /// Create a copy of SnLinkMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? entryId = null,
    Object? icon = freezed,
    Object? url = null,
    Object? title = freezed,
    Object? image = freezed,
    Object? video = freezed,
    Object? audio = freezed,
    Object? description = freezed,
    Object? siteName = freezed,
    Object? type = freezed,
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
      entryId: null == entryId
          ? _self.entryId
          : entryId // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _self.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      video: freezed == video
          ? _self.video
          : video // ignore: cast_nullable_to_non_nullable
              as String?,
      audio: freezed == audio
          ? _self.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      siteName: freezed == siteName
          ? _self.siteName
          : siteName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnLinkMeta extends SnLinkMeta {
  const _SnLinkMeta(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.entryId,
      required this.icon,
      required this.url,
      required this.title,
      required this.image,
      required this.video,
      required this.audio,
      required this.description,
      required this.siteName,
      required this.type})
      : super._();
  factory _SnLinkMeta.fromJson(Map<String, dynamic> json) =>
      _$SnLinkMetaFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String entryId;
  @override
  final String? icon;
  @override
  final String url;
  @override
  final String? title;
  @override
  final String? image;
  @override
  final String? video;
  @override
  final String? audio;
  @override
  final String? description;
  @override
  final String? siteName;
  @override
  final String? type;

  /// Create a copy of SnLinkMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnLinkMetaCopyWith<_SnLinkMeta> get copyWith =>
      __$SnLinkMetaCopyWithImpl<_SnLinkMeta>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnLinkMetaToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnLinkMeta &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.entryId, entryId) || other.entryId == entryId) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.siteName, siteName) ||
                other.siteName == siteName) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      entryId,
      icon,
      url,
      title,
      image,
      video,
      audio,
      description,
      siteName,
      type);

  @override
  String toString() {
    return 'SnLinkMeta(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, entryId: $entryId, icon: $icon, url: $url, title: $title, image: $image, video: $video, audio: $audio, description: $description, siteName: $siteName, type: $type)';
  }
}

/// @nodoc
abstract mixin class _$SnLinkMetaCopyWith<$Res>
    implements $SnLinkMetaCopyWith<$Res> {
  factory _$SnLinkMetaCopyWith(
          _SnLinkMeta value, $Res Function(_SnLinkMeta) _then) =
      __$SnLinkMetaCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String entryId,
      String? icon,
      String url,
      String? title,
      String? image,
      String? video,
      String? audio,
      String? description,
      String? siteName,
      String? type});
}

/// @nodoc
class __$SnLinkMetaCopyWithImpl<$Res> implements _$SnLinkMetaCopyWith<$Res> {
  __$SnLinkMetaCopyWithImpl(this._self, this._then);

  final _SnLinkMeta _self;
  final $Res Function(_SnLinkMeta) _then;

  /// Create a copy of SnLinkMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? entryId = null,
    Object? icon = freezed,
    Object? url = null,
    Object? title = freezed,
    Object? image = freezed,
    Object? video = freezed,
    Object? audio = freezed,
    Object? description = freezed,
    Object? siteName = freezed,
    Object? type = freezed,
  }) {
    return _then(_SnLinkMeta(
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
      entryId: null == entryId
          ? _self.entryId
          : entryId // ignore: cast_nullable_to_non_nullable
              as String,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _self.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      video: freezed == video
          ? _self.video
          : video // ignore: cast_nullable_to_non_nullable
              as String?,
      audio: freezed == audio
          ? _self.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      siteName: freezed == siteName
          ? _self.siteName
          : siteName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
