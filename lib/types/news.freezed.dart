// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnNewsSource {
  String get id;
  String get label;
  String get type;
  String get source;
  int get depth;
  bool get enabled;

  /// Create a copy of SnNewsSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnNewsSourceCopyWith<SnNewsSource> get copyWith =>
      _$SnNewsSourceCopyWithImpl<SnNewsSource>(
          this as SnNewsSource, _$identity);

  /// Serializes this SnNewsSource to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnNewsSource &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.depth, depth) || other.depth == depth) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, type, source, depth, enabled);

  @override
  String toString() {
    return 'SnNewsSource(id: $id, label: $label, type: $type, source: $source, depth: $depth, enabled: $enabled)';
  }
}

/// @nodoc
abstract mixin class $SnNewsSourceCopyWith<$Res> {
  factory $SnNewsSourceCopyWith(
          SnNewsSource value, $Res Function(SnNewsSource) _then) =
      _$SnNewsSourceCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String label,
      String type,
      String source,
      int depth,
      bool enabled});
}

/// @nodoc
class _$SnNewsSourceCopyWithImpl<$Res> implements $SnNewsSourceCopyWith<$Res> {
  _$SnNewsSourceCopyWithImpl(this._self, this._then);

  final SnNewsSource _self;
  final $Res Function(SnNewsSource) _then;

  /// Create a copy of SnNewsSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? source = null,
    Object? depth = null,
    Object? enabled = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      depth: null == depth
          ? _self.depth
          : depth // ignore: cast_nullable_to_non_nullable
              as int,
      enabled: null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnNewsSource implements SnNewsSource {
  const _SnNewsSource(
      {required this.id,
      required this.label,
      required this.type,
      required this.source,
      required this.depth,
      required this.enabled});
  factory _SnNewsSource.fromJson(Map<String, dynamic> json) =>
      _$SnNewsSourceFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final String type;
  @override
  final String source;
  @override
  final int depth;
  @override
  final bool enabled;

  /// Create a copy of SnNewsSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnNewsSourceCopyWith<_SnNewsSource> get copyWith =>
      __$SnNewsSourceCopyWithImpl<_SnNewsSource>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnNewsSourceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnNewsSource &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.depth, depth) || other.depth == depth) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, type, source, depth, enabled);

  @override
  String toString() {
    return 'SnNewsSource(id: $id, label: $label, type: $type, source: $source, depth: $depth, enabled: $enabled)';
  }
}

/// @nodoc
abstract mixin class _$SnNewsSourceCopyWith<$Res>
    implements $SnNewsSourceCopyWith<$Res> {
  factory _$SnNewsSourceCopyWith(
          _SnNewsSource value, $Res Function(_SnNewsSource) _then) =
      __$SnNewsSourceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      String type,
      String source,
      int depth,
      bool enabled});
}

/// @nodoc
class __$SnNewsSourceCopyWithImpl<$Res>
    implements _$SnNewsSourceCopyWith<$Res> {
  __$SnNewsSourceCopyWithImpl(this._self, this._then);

  final _SnNewsSource _self;
  final $Res Function(_SnNewsSource) _then;

  /// Create a copy of SnNewsSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? source = null,
    Object? depth = null,
    Object? enabled = null,
  }) {
    return _then(_SnNewsSource(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      depth: null == depth
          ? _self.depth
          : depth // ignore: cast_nullable_to_non_nullable
              as int,
      enabled: null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$SnSubscriptionItem {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get thumbnail;
  String get title;
  String get description;
  String get content;
  String get url;
  String get hash;
  int get feedId;
  DateTime? get publishedAt;

  /// Create a copy of SnSubscriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnSubscriptionItemCopyWith<SnSubscriptionItem> get copyWith =>
      _$SnSubscriptionItemCopyWithImpl<SnSubscriptionItem>(
          this as SnSubscriptionItem, _$identity);

  /// Serializes this SnSubscriptionItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnSubscriptionItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      thumbnail,
      title,
      description,
      content,
      url,
      hash,
      feedId,
      publishedAt);

  @override
  String toString() {
    return 'SnSubscriptionItem(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, thumbnail: $thumbnail, title: $title, description: $description, content: $content, url: $url, hash: $hash, feedId: $feedId, publishedAt: $publishedAt)';
  }
}

/// @nodoc
abstract mixin class $SnSubscriptionItemCopyWith<$Res> {
  factory $SnSubscriptionItemCopyWith(
          SnSubscriptionItem value, $Res Function(SnSubscriptionItem) _then) =
      _$SnSubscriptionItemCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String thumbnail,
      String title,
      String description,
      String content,
      String url,
      String hash,
      int feedId,
      DateTime? publishedAt});
}

/// @nodoc
class _$SnSubscriptionItemCopyWithImpl<$Res>
    implements $SnSubscriptionItemCopyWith<$Res> {
  _$SnSubscriptionItemCopyWithImpl(this._self, this._then);

  final SnSubscriptionItem _self;
  final $Res Function(SnSubscriptionItem) _then;

  /// Create a copy of SnSubscriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? thumbnail = null,
    Object? title = null,
    Object? description = null,
    Object? content = null,
    Object? url = null,
    Object? hash = null,
    Object? feedId = null,
    Object? publishedAt = freezed,
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
      thumbnail: null == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _self.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      feedId: null == feedId
          ? _self.feedId
          : feedId // ignore: cast_nullable_to_non_nullable
              as int,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnSubscriptionItem implements SnSubscriptionItem {
  const _SnSubscriptionItem(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.thumbnail,
      required this.title,
      required this.description,
      required this.content,
      required this.url,
      required this.hash,
      required this.feedId,
      required this.publishedAt});
  factory _SnSubscriptionItem.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionItemFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String thumbnail;
  @override
  final String title;
  @override
  final String description;
  @override
  final String content;
  @override
  final String url;
  @override
  final String hash;
  @override
  final int feedId;
  @override
  final DateTime? publishedAt;

  /// Create a copy of SnSubscriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnSubscriptionItemCopyWith<_SnSubscriptionItem> get copyWith =>
      __$SnSubscriptionItemCopyWithImpl<_SnSubscriptionItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnSubscriptionItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnSubscriptionItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      thumbnail,
      title,
      description,
      content,
      url,
      hash,
      feedId,
      publishedAt);

  @override
  String toString() {
    return 'SnSubscriptionItem(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, thumbnail: $thumbnail, title: $title, description: $description, content: $content, url: $url, hash: $hash, feedId: $feedId, publishedAt: $publishedAt)';
  }
}

/// @nodoc
abstract mixin class _$SnSubscriptionItemCopyWith<$Res>
    implements $SnSubscriptionItemCopyWith<$Res> {
  factory _$SnSubscriptionItemCopyWith(
          _SnSubscriptionItem value, $Res Function(_SnSubscriptionItem) _then) =
      __$SnSubscriptionItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String thumbnail,
      String title,
      String description,
      String content,
      String url,
      String hash,
      int feedId,
      DateTime? publishedAt});
}

/// @nodoc
class __$SnSubscriptionItemCopyWithImpl<$Res>
    implements _$SnSubscriptionItemCopyWith<$Res> {
  __$SnSubscriptionItemCopyWithImpl(this._self, this._then);

  final _SnSubscriptionItem _self;
  final $Res Function(_SnSubscriptionItem) _then;

  /// Create a copy of SnSubscriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? thumbnail = null,
    Object? title = null,
    Object? description = null,
    Object? content = null,
    Object? url = null,
    Object? hash = null,
    Object? feedId = null,
    Object? publishedAt = freezed,
  }) {
    return _then(_SnSubscriptionItem(
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
      thumbnail: null == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _self.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      feedId: null == feedId
          ? _self.feedId
          : feedId // ignore: cast_nullable_to_non_nullable
              as int,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
