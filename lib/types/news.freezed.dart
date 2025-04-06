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
mixin _$SnSubscriptionFeed {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get url;
  bool get isEnabled;
  bool get isFullContent;
  int get pullInterval;
  String get adapter;
  int? get accountId;
  DateTime? get lastFetchedAt;

  /// Create a copy of SnSubscriptionFeed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnSubscriptionFeedCopyWith<SnSubscriptionFeed> get copyWith =>
      _$SnSubscriptionFeedCopyWithImpl<SnSubscriptionFeed>(
          this as SnSubscriptionFeed, _$identity);

  /// Serializes this SnSubscriptionFeed to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnSubscriptionFeed &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.isFullContent, isFullContent) ||
                other.isFullContent == isFullContent) &&
            (identical(other.pullInterval, pullInterval) ||
                other.pullInterval == pullInterval) &&
            (identical(other.adapter, adapter) || other.adapter == adapter) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.lastFetchedAt, lastFetchedAt) ||
                other.lastFetchedAt == lastFetchedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      url,
      isEnabled,
      isFullContent,
      pullInterval,
      adapter,
      accountId,
      lastFetchedAt);

  @override
  String toString() {
    return 'SnSubscriptionFeed(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, url: $url, isEnabled: $isEnabled, isFullContent: $isFullContent, pullInterval: $pullInterval, adapter: $adapter, accountId: $accountId, lastFetchedAt: $lastFetchedAt)';
  }
}

/// @nodoc
abstract mixin class $SnSubscriptionFeedCopyWith<$Res> {
  factory $SnSubscriptionFeedCopyWith(
          SnSubscriptionFeed value, $Res Function(SnSubscriptionFeed) _then) =
      _$SnSubscriptionFeedCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String url,
      bool isEnabled,
      bool isFullContent,
      int pullInterval,
      String adapter,
      int? accountId,
      DateTime? lastFetchedAt});
}

/// @nodoc
class _$SnSubscriptionFeedCopyWithImpl<$Res>
    implements $SnSubscriptionFeedCopyWith<$Res> {
  _$SnSubscriptionFeedCopyWithImpl(this._self, this._then);

  final SnSubscriptionFeed _self;
  final $Res Function(SnSubscriptionFeed) _then;

  /// Create a copy of SnSubscriptionFeed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? url = null,
    Object? isEnabled = null,
    Object? isFullContent = null,
    Object? pullInterval = null,
    Object? adapter = null,
    Object? accountId = freezed,
    Object? lastFetchedAt = freezed,
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
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _self.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isFullContent: null == isFullContent
          ? _self.isFullContent
          : isFullContent // ignore: cast_nullable_to_non_nullable
              as bool,
      pullInterval: null == pullInterval
          ? _self.pullInterval
          : pullInterval // ignore: cast_nullable_to_non_nullable
              as int,
      adapter: null == adapter
          ? _self.adapter
          : adapter // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
      lastFetchedAt: freezed == lastFetchedAt
          ? _self.lastFetchedAt
          : lastFetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnSubscriptionFeed implements SnSubscriptionFeed {
  const _SnSubscriptionFeed(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.url,
      required this.isEnabled,
      required this.isFullContent,
      required this.pullInterval,
      required this.adapter,
      required this.accountId,
      required this.lastFetchedAt});
  factory _SnSubscriptionFeed.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionFeedFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String url;
  @override
  final bool isEnabled;
  @override
  final bool isFullContent;
  @override
  final int pullInterval;
  @override
  final String adapter;
  @override
  final int? accountId;
  @override
  final DateTime? lastFetchedAt;

  /// Create a copy of SnSubscriptionFeed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnSubscriptionFeedCopyWith<_SnSubscriptionFeed> get copyWith =>
      __$SnSubscriptionFeedCopyWithImpl<_SnSubscriptionFeed>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnSubscriptionFeedToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnSubscriptionFeed &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.isFullContent, isFullContent) ||
                other.isFullContent == isFullContent) &&
            (identical(other.pullInterval, pullInterval) ||
                other.pullInterval == pullInterval) &&
            (identical(other.adapter, adapter) || other.adapter == adapter) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.lastFetchedAt, lastFetchedAt) ||
                other.lastFetchedAt == lastFetchedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      url,
      isEnabled,
      isFullContent,
      pullInterval,
      adapter,
      accountId,
      lastFetchedAt);

  @override
  String toString() {
    return 'SnSubscriptionFeed(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, url: $url, isEnabled: $isEnabled, isFullContent: $isFullContent, pullInterval: $pullInterval, adapter: $adapter, accountId: $accountId, lastFetchedAt: $lastFetchedAt)';
  }
}

/// @nodoc
abstract mixin class _$SnSubscriptionFeedCopyWith<$Res>
    implements $SnSubscriptionFeedCopyWith<$Res> {
  factory _$SnSubscriptionFeedCopyWith(
          _SnSubscriptionFeed value, $Res Function(_SnSubscriptionFeed) _then) =
      __$SnSubscriptionFeedCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String url,
      bool isEnabled,
      bool isFullContent,
      int pullInterval,
      String adapter,
      int? accountId,
      DateTime? lastFetchedAt});
}

/// @nodoc
class __$SnSubscriptionFeedCopyWithImpl<$Res>
    implements _$SnSubscriptionFeedCopyWith<$Res> {
  __$SnSubscriptionFeedCopyWithImpl(this._self, this._then);

  final _SnSubscriptionFeed _self;
  final $Res Function(_SnSubscriptionFeed) _then;

  /// Create a copy of SnSubscriptionFeed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? url = null,
    Object? isEnabled = null,
    Object? isFullContent = null,
    Object? pullInterval = null,
    Object? adapter = null,
    Object? accountId = freezed,
    Object? lastFetchedAt = freezed,
  }) {
    return _then(_SnSubscriptionFeed(
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
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _self.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isFullContent: null == isFullContent
          ? _self.isFullContent
          : isFullContent // ignore: cast_nullable_to_non_nullable
              as bool,
      pullInterval: null == pullInterval
          ? _self.pullInterval
          : pullInterval // ignore: cast_nullable_to_non_nullable
              as int,
      adapter: null == adapter
          ? _self.adapter
          : adapter // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
      lastFetchedAt: freezed == lastFetchedAt
          ? _self.lastFetchedAt
          : lastFetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
  SnSubscriptionFeed get feed;
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
            (identical(other.feed, feed) || other.feed == feed) &&
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
      feed,
      publishedAt);

  @override
  String toString() {
    return 'SnSubscriptionItem(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, thumbnail: $thumbnail, title: $title, description: $description, content: $content, url: $url, hash: $hash, feedId: $feedId, feed: $feed, publishedAt: $publishedAt)';
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
      SnSubscriptionFeed feed,
      DateTime? publishedAt});

  $SnSubscriptionFeedCopyWith<$Res> get feed;
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
    Object? feed = null,
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
      feed: null == feed
          ? _self.feed
          : feed // ignore: cast_nullable_to_non_nullable
              as SnSubscriptionFeed,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of SnSubscriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnSubscriptionFeedCopyWith<$Res> get feed {
    return $SnSubscriptionFeedCopyWith<$Res>(_self.feed, (value) {
      return _then(_self.copyWith(feed: value));
    });
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
      required this.feed,
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
  final SnSubscriptionFeed feed;
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
            (identical(other.feed, feed) || other.feed == feed) &&
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
      feed,
      publishedAt);

  @override
  String toString() {
    return 'SnSubscriptionItem(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, thumbnail: $thumbnail, title: $title, description: $description, content: $content, url: $url, hash: $hash, feedId: $feedId, feed: $feed, publishedAt: $publishedAt)';
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
      SnSubscriptionFeed feed,
      DateTime? publishedAt});

  @override
  $SnSubscriptionFeedCopyWith<$Res> get feed;
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
    Object? feed = null,
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
      feed: null == feed
          ? _self.feed
          : feed // ignore: cast_nullable_to_non_nullable
              as SnSubscriptionFeed,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of SnSubscriptionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnSubscriptionFeedCopyWith<$Res> get feed {
    return $SnSubscriptionFeedCopyWith<$Res>(_self.feed, (value) {
      return _then(_self.copyWith(feed: value));
    });
  }
}

// dart format on
