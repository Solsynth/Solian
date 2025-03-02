// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPost {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get type;
  Map<String, dynamic> get body;
  String get language;
  String? get alias;
  String? get aliasPrefix;
  List<SnPostTag> get tags;
  List<SnPostCategory> get categories;
  List<SnPost>? get replies;
  int? get replyId;
  int? get repostId;
  int? get realmId;
  SnPost? get replyTo;
  SnPost? get repostTo;
  List<int>? get visibleUsersList;
  List<int>? get invisibleUsersList;
  int get visibility;
  DateTime? get editedAt;
  DateTime? get pinnedAt;
  DateTime? get lockedAt;
  bool get isDraft;
  DateTime? get publishedAt;
  DateTime? get publishedUntil;
  int get totalUpvote;
  int get totalDownvote;
  int get totalViews;
  int get totalAggregatedViews;
  int get publisherId;
  int? get pollId;
  SnPublisher get publisher;
  SnMetric get metric;
  SnPostPreload? get preload;

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnPostCopyWith<SnPost> get copyWith =>
      _$SnPostCopyWithImpl<SnPost>(this as SnPost, _$identity);

  /// Serializes this SnPost to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnPost &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.body, body) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.aliasPrefix, aliasPrefix) ||
                other.aliasPrefix == aliasPrefix) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality()
                .equals(other.categories, categories) &&
            const DeepCollectionEquality().equals(other.replies, replies) &&
            (identical(other.replyId, replyId) || other.replyId == replyId) &&
            (identical(other.repostId, repostId) ||
                other.repostId == repostId) &&
            (identical(other.realmId, realmId) || other.realmId == realmId) &&
            (identical(other.replyTo, replyTo) || other.replyTo == replyTo) &&
            (identical(other.repostTo, repostTo) ||
                other.repostTo == repostTo) &&
            const DeepCollectionEquality()
                .equals(other.visibleUsersList, visibleUsersList) &&
            const DeepCollectionEquality()
                .equals(other.invisibleUsersList, invisibleUsersList) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.pinnedAt, pinnedAt) ||
                other.pinnedAt == pinnedAt) &&
            (identical(other.lockedAt, lockedAt) ||
                other.lockedAt == lockedAt) &&
            (identical(other.isDraft, isDraft) || other.isDraft == isDraft) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.publishedUntil, publishedUntil) ||
                other.publishedUntil == publishedUntil) &&
            (identical(other.totalUpvote, totalUpvote) ||
                other.totalUpvote == totalUpvote) &&
            (identical(other.totalDownvote, totalDownvote) ||
                other.totalDownvote == totalDownvote) &&
            (identical(other.totalViews, totalViews) ||
                other.totalViews == totalViews) &&
            (identical(other.totalAggregatedViews, totalAggregatedViews) ||
                other.totalAggregatedViews == totalAggregatedViews) &&
            (identical(other.publisherId, publisherId) ||
                other.publisherId == publisherId) &&
            (identical(other.pollId, pollId) || other.pollId == pollId) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.preload, preload) || other.preload == preload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        deletedAt,
        type,
        const DeepCollectionEquality().hash(body),
        language,
        alias,
        aliasPrefix,
        const DeepCollectionEquality().hash(tags),
        const DeepCollectionEquality().hash(categories),
        const DeepCollectionEquality().hash(replies),
        replyId,
        repostId,
        realmId,
        replyTo,
        repostTo,
        const DeepCollectionEquality().hash(visibleUsersList),
        const DeepCollectionEquality().hash(invisibleUsersList),
        visibility,
        editedAt,
        pinnedAt,
        lockedAt,
        isDraft,
        publishedAt,
        publishedUntil,
        totalUpvote,
        totalDownvote,
        totalViews,
        totalAggregatedViews,
        publisherId,
        pollId,
        publisher,
        metric,
        preload
      ]);

  @override
  String toString() {
    return 'SnPost(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, body: $body, language: $language, alias: $alias, aliasPrefix: $aliasPrefix, tags: $tags, categories: $categories, replies: $replies, replyId: $replyId, repostId: $repostId, realmId: $realmId, replyTo: $replyTo, repostTo: $repostTo, visibleUsersList: $visibleUsersList, invisibleUsersList: $invisibleUsersList, visibility: $visibility, editedAt: $editedAt, pinnedAt: $pinnedAt, lockedAt: $lockedAt, isDraft: $isDraft, publishedAt: $publishedAt, publishedUntil: $publishedUntil, totalUpvote: $totalUpvote, totalDownvote: $totalDownvote, totalViews: $totalViews, totalAggregatedViews: $totalAggregatedViews, publisherId: $publisherId, pollId: $pollId, publisher: $publisher, metric: $metric, preload: $preload)';
  }
}

/// @nodoc
abstract mixin class $SnPostCopyWith<$Res> {
  factory $SnPostCopyWith(SnPost value, $Res Function(SnPost) _then) =
      _$SnPostCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String type,
      Map<String, dynamic> body,
      String language,
      String? alias,
      String? aliasPrefix,
      List<SnPostTag> tags,
      List<SnPostCategory> categories,
      List<SnPost>? replies,
      int? replyId,
      int? repostId,
      int? realmId,
      SnPost? replyTo,
      SnPost? repostTo,
      List<int>? visibleUsersList,
      List<int>? invisibleUsersList,
      int visibility,
      DateTime? editedAt,
      DateTime? pinnedAt,
      DateTime? lockedAt,
      bool isDraft,
      DateTime? publishedAt,
      DateTime? publishedUntil,
      int totalUpvote,
      int totalDownvote,
      int totalViews,
      int totalAggregatedViews,
      int publisherId,
      int? pollId,
      SnPublisher publisher,
      SnMetric metric,
      SnPostPreload? preload});

  $SnPostCopyWith<$Res>? get replyTo;
  $SnPostCopyWith<$Res>? get repostTo;
  $SnPublisherCopyWith<$Res> get publisher;
  $SnMetricCopyWith<$Res> get metric;
  $SnPostPreloadCopyWith<$Res>? get preload;
}

/// @nodoc
class _$SnPostCopyWithImpl<$Res> implements $SnPostCopyWith<$Res> {
  _$SnPostCopyWithImpl(this._self, this._then);

  final SnPost _self;
  final $Res Function(SnPost) _then;

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? type = null,
    Object? body = null,
    Object? language = null,
    Object? alias = freezed,
    Object? aliasPrefix = freezed,
    Object? tags = null,
    Object? categories = null,
    Object? replies = freezed,
    Object? replyId = freezed,
    Object? repostId = freezed,
    Object? realmId = freezed,
    Object? replyTo = freezed,
    Object? repostTo = freezed,
    Object? visibleUsersList = freezed,
    Object? invisibleUsersList = freezed,
    Object? visibility = null,
    Object? editedAt = freezed,
    Object? pinnedAt = freezed,
    Object? lockedAt = freezed,
    Object? isDraft = null,
    Object? publishedAt = freezed,
    Object? publishedUntil = freezed,
    Object? totalUpvote = null,
    Object? totalDownvote = null,
    Object? totalViews = null,
    Object? totalAggregatedViews = null,
    Object? publisherId = null,
    Object? pollId = freezed,
    Object? publisher = null,
    Object? metric = null,
    Object? preload = freezed,
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      alias: freezed == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      aliasPrefix: freezed == aliasPrefix
          ? _self.aliasPrefix
          : aliasPrefix // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<SnPostTag>,
      categories: null == categories
          ? _self.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<SnPostCategory>,
      replies: freezed == replies
          ? _self.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<SnPost>?,
      replyId: freezed == replyId
          ? _self.replyId
          : replyId // ignore: cast_nullable_to_non_nullable
              as int?,
      repostId: freezed == repostId
          ? _self.repostId
          : repostId // ignore: cast_nullable_to_non_nullable
              as int?,
      realmId: freezed == realmId
          ? _self.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      replyTo: freezed == replyTo
          ? _self.replyTo
          : replyTo // ignore: cast_nullable_to_non_nullable
              as SnPost?,
      repostTo: freezed == repostTo
          ? _self.repostTo
          : repostTo // ignore: cast_nullable_to_non_nullable
              as SnPost?,
      visibleUsersList: freezed == visibleUsersList
          ? _self.visibleUsersList
          : visibleUsersList // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      invisibleUsersList: freezed == invisibleUsersList
          ? _self.invisibleUsersList
          : invisibleUsersList // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      visibility: null == visibility
          ? _self.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as int,
      editedAt: freezed == editedAt
          ? _self.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pinnedAt: freezed == pinnedAt
          ? _self.pinnedAt
          : pinnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lockedAt: freezed == lockedAt
          ? _self.lockedAt
          : lockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDraft: null == isDraft
          ? _self.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      publishedUntil: freezed == publishedUntil
          ? _self.publishedUntil
          : publishedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalUpvote: null == totalUpvote
          ? _self.totalUpvote
          : totalUpvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownvote: null == totalDownvote
          ? _self.totalDownvote
          : totalDownvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalViews: null == totalViews
          ? _self.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
      totalAggregatedViews: null == totalAggregatedViews
          ? _self.totalAggregatedViews
          : totalAggregatedViews // ignore: cast_nullable_to_non_nullable
              as int,
      publisherId: null == publisherId
          ? _self.publisherId
          : publisherId // ignore: cast_nullable_to_non_nullable
              as int,
      pollId: freezed == pollId
          ? _self.pollId
          : pollId // ignore: cast_nullable_to_non_nullable
              as int?,
      publisher: null == publisher
          ? _self.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as SnPublisher,
      metric: null == metric
          ? _self.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as SnMetric,
      preload: freezed == preload
          ? _self.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as SnPostPreload?,
    ));
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostCopyWith<$Res>? get replyTo {
    if (_self.replyTo == null) {
      return null;
    }

    return $SnPostCopyWith<$Res>(_self.replyTo!, (value) {
      return _then(_self.copyWith(replyTo: value));
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostCopyWith<$Res>? get repostTo {
    if (_self.repostTo == null) {
      return null;
    }

    return $SnPostCopyWith<$Res>(_self.repostTo!, (value) {
      return _then(_self.copyWith(repostTo: value));
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPublisherCopyWith<$Res> get publisher {
    return $SnPublisherCopyWith<$Res>(_self.publisher, (value) {
      return _then(_self.copyWith(publisher: value));
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnMetricCopyWith<$Res> get metric {
    return $SnMetricCopyWith<$Res>(_self.metric, (value) {
      return _then(_self.copyWith(metric: value));
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostPreloadCopyWith<$Res>? get preload {
    if (_self.preload == null) {
      return null;
    }

    return $SnPostPreloadCopyWith<$Res>(_self.preload!, (value) {
      return _then(_self.copyWith(preload: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnPost extends SnPost {
  const _SnPost(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.type,
      required final Map<String, dynamic> body,
      required this.language,
      required this.alias,
      required this.aliasPrefix,
      final List<SnPostTag> tags = const [],
      final List<SnPostCategory> categories = const [],
      required final List<SnPost>? replies,
      required this.replyId,
      required this.repostId,
      required this.realmId,
      required this.replyTo,
      required this.repostTo,
      required final List<int>? visibleUsersList,
      required final List<int>? invisibleUsersList,
      required this.visibility,
      required this.editedAt,
      required this.pinnedAt,
      required this.lockedAt,
      required this.isDraft,
      required this.publishedAt,
      required this.publishedUntil,
      required this.totalUpvote,
      required this.totalDownvote,
      this.totalViews = 0,
      this.totalAggregatedViews = 0,
      required this.publisherId,
      required this.pollId,
      required this.publisher,
      required this.metric,
      this.preload})
      : _body = body,
        _tags = tags,
        _categories = categories,
        _replies = replies,
        _visibleUsersList = visibleUsersList,
        _invisibleUsersList = invisibleUsersList,
        super._();
  factory _SnPost.fromJson(Map<String, dynamic> json) => _$SnPostFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String type;
  final Map<String, dynamic> _body;
  @override
  Map<String, dynamic> get body {
    if (_body is EqualUnmodifiableMapView) return _body;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_body);
  }

  @override
  final String language;
  @override
  final String? alias;
  @override
  final String? aliasPrefix;
  final List<SnPostTag> _tags;
  @override
  @JsonKey()
  List<SnPostTag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<SnPostCategory> _categories;
  @override
  @JsonKey()
  List<SnPostCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<SnPost>? _replies;
  @override
  List<SnPost>? get replies {
    final value = _replies;
    if (value == null) return null;
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? replyId;
  @override
  final int? repostId;
  @override
  final int? realmId;
  @override
  final SnPost? replyTo;
  @override
  final SnPost? repostTo;
  final List<int>? _visibleUsersList;
  @override
  List<int>? get visibleUsersList {
    final value = _visibleUsersList;
    if (value == null) return null;
    if (_visibleUsersList is EqualUnmodifiableListView)
      return _visibleUsersList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<int>? _invisibleUsersList;
  @override
  List<int>? get invisibleUsersList {
    final value = _invisibleUsersList;
    if (value == null) return null;
    if (_invisibleUsersList is EqualUnmodifiableListView)
      return _invisibleUsersList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int visibility;
  @override
  final DateTime? editedAt;
  @override
  final DateTime? pinnedAt;
  @override
  final DateTime? lockedAt;
  @override
  final bool isDraft;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime? publishedUntil;
  @override
  final int totalUpvote;
  @override
  final int totalDownvote;
  @override
  @JsonKey()
  final int totalViews;
  @override
  @JsonKey()
  final int totalAggregatedViews;
  @override
  final int publisherId;
  @override
  final int? pollId;
  @override
  final SnPublisher publisher;
  @override
  final SnMetric metric;
  @override
  final SnPostPreload? preload;

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnPostCopyWith<_SnPost> get copyWith =>
      __$SnPostCopyWithImpl<_SnPost>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnPostToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnPost &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._body, _body) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.aliasPrefix, aliasPrefix) ||
                other.aliasPrefix == aliasPrefix) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            (identical(other.replyId, replyId) || other.replyId == replyId) &&
            (identical(other.repostId, repostId) ||
                other.repostId == repostId) &&
            (identical(other.realmId, realmId) || other.realmId == realmId) &&
            (identical(other.replyTo, replyTo) || other.replyTo == replyTo) &&
            (identical(other.repostTo, repostTo) ||
                other.repostTo == repostTo) &&
            const DeepCollectionEquality()
                .equals(other._visibleUsersList, _visibleUsersList) &&
            const DeepCollectionEquality()
                .equals(other._invisibleUsersList, _invisibleUsersList) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.pinnedAt, pinnedAt) ||
                other.pinnedAt == pinnedAt) &&
            (identical(other.lockedAt, lockedAt) ||
                other.lockedAt == lockedAt) &&
            (identical(other.isDraft, isDraft) || other.isDraft == isDraft) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.publishedUntil, publishedUntil) ||
                other.publishedUntil == publishedUntil) &&
            (identical(other.totalUpvote, totalUpvote) ||
                other.totalUpvote == totalUpvote) &&
            (identical(other.totalDownvote, totalDownvote) ||
                other.totalDownvote == totalDownvote) &&
            (identical(other.totalViews, totalViews) ||
                other.totalViews == totalViews) &&
            (identical(other.totalAggregatedViews, totalAggregatedViews) ||
                other.totalAggregatedViews == totalAggregatedViews) &&
            (identical(other.publisherId, publisherId) ||
                other.publisherId == publisherId) &&
            (identical(other.pollId, pollId) || other.pollId == pollId) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.preload, preload) || other.preload == preload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        deletedAt,
        type,
        const DeepCollectionEquality().hash(_body),
        language,
        alias,
        aliasPrefix,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_categories),
        const DeepCollectionEquality().hash(_replies),
        replyId,
        repostId,
        realmId,
        replyTo,
        repostTo,
        const DeepCollectionEquality().hash(_visibleUsersList),
        const DeepCollectionEquality().hash(_invisibleUsersList),
        visibility,
        editedAt,
        pinnedAt,
        lockedAt,
        isDraft,
        publishedAt,
        publishedUntil,
        totalUpvote,
        totalDownvote,
        totalViews,
        totalAggregatedViews,
        publisherId,
        pollId,
        publisher,
        metric,
        preload
      ]);

  @override
  String toString() {
    return 'SnPost(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, body: $body, language: $language, alias: $alias, aliasPrefix: $aliasPrefix, tags: $tags, categories: $categories, replies: $replies, replyId: $replyId, repostId: $repostId, realmId: $realmId, replyTo: $replyTo, repostTo: $repostTo, visibleUsersList: $visibleUsersList, invisibleUsersList: $invisibleUsersList, visibility: $visibility, editedAt: $editedAt, pinnedAt: $pinnedAt, lockedAt: $lockedAt, isDraft: $isDraft, publishedAt: $publishedAt, publishedUntil: $publishedUntil, totalUpvote: $totalUpvote, totalDownvote: $totalDownvote, totalViews: $totalViews, totalAggregatedViews: $totalAggregatedViews, publisherId: $publisherId, pollId: $pollId, publisher: $publisher, metric: $metric, preload: $preload)';
  }
}

/// @nodoc
abstract mixin class _$SnPostCopyWith<$Res> implements $SnPostCopyWith<$Res> {
  factory _$SnPostCopyWith(_SnPost value, $Res Function(_SnPost) _then) =
      __$SnPostCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String type,
      Map<String, dynamic> body,
      String language,
      String? alias,
      String? aliasPrefix,
      List<SnPostTag> tags,
      List<SnPostCategory> categories,
      List<SnPost>? replies,
      int? replyId,
      int? repostId,
      int? realmId,
      SnPost? replyTo,
      SnPost? repostTo,
      List<int>? visibleUsersList,
      List<int>? invisibleUsersList,
      int visibility,
      DateTime? editedAt,
      DateTime? pinnedAt,
      DateTime? lockedAt,
      bool isDraft,
      DateTime? publishedAt,
      DateTime? publishedUntil,
      int totalUpvote,
      int totalDownvote,
      int totalViews,
      int totalAggregatedViews,
      int publisherId,
      int? pollId,
      SnPublisher publisher,
      SnMetric metric,
      SnPostPreload? preload});

  @override
  $SnPostCopyWith<$Res>? get replyTo;
  @override
  $SnPostCopyWith<$Res>? get repostTo;
  @override
  $SnPublisherCopyWith<$Res> get publisher;
  @override
  $SnMetricCopyWith<$Res> get metric;
  @override
  $SnPostPreloadCopyWith<$Res>? get preload;
}

/// @nodoc
class __$SnPostCopyWithImpl<$Res> implements _$SnPostCopyWith<$Res> {
  __$SnPostCopyWithImpl(this._self, this._then);

  final _SnPost _self;
  final $Res Function(_SnPost) _then;

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? type = null,
    Object? body = null,
    Object? language = null,
    Object? alias = freezed,
    Object? aliasPrefix = freezed,
    Object? tags = null,
    Object? categories = null,
    Object? replies = freezed,
    Object? replyId = freezed,
    Object? repostId = freezed,
    Object? realmId = freezed,
    Object? replyTo = freezed,
    Object? repostTo = freezed,
    Object? visibleUsersList = freezed,
    Object? invisibleUsersList = freezed,
    Object? visibility = null,
    Object? editedAt = freezed,
    Object? pinnedAt = freezed,
    Object? lockedAt = freezed,
    Object? isDraft = null,
    Object? publishedAt = freezed,
    Object? publishedUntil = freezed,
    Object? totalUpvote = null,
    Object? totalDownvote = null,
    Object? totalViews = null,
    Object? totalAggregatedViews = null,
    Object? publisherId = null,
    Object? pollId = freezed,
    Object? publisher = null,
    Object? metric = null,
    Object? preload = freezed,
  }) {
    return _then(_SnPost(
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self._body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      alias: freezed == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      aliasPrefix: freezed == aliasPrefix
          ? _self.aliasPrefix
          : aliasPrefix // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<SnPostTag>,
      categories: null == categories
          ? _self._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<SnPostCategory>,
      replies: freezed == replies
          ? _self._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<SnPost>?,
      replyId: freezed == replyId
          ? _self.replyId
          : replyId // ignore: cast_nullable_to_non_nullable
              as int?,
      repostId: freezed == repostId
          ? _self.repostId
          : repostId // ignore: cast_nullable_to_non_nullable
              as int?,
      realmId: freezed == realmId
          ? _self.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      replyTo: freezed == replyTo
          ? _self.replyTo
          : replyTo // ignore: cast_nullable_to_non_nullable
              as SnPost?,
      repostTo: freezed == repostTo
          ? _self.repostTo
          : repostTo // ignore: cast_nullable_to_non_nullable
              as SnPost?,
      visibleUsersList: freezed == visibleUsersList
          ? _self._visibleUsersList
          : visibleUsersList // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      invisibleUsersList: freezed == invisibleUsersList
          ? _self._invisibleUsersList
          : invisibleUsersList // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      visibility: null == visibility
          ? _self.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as int,
      editedAt: freezed == editedAt
          ? _self.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pinnedAt: freezed == pinnedAt
          ? _self.pinnedAt
          : pinnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lockedAt: freezed == lockedAt
          ? _self.lockedAt
          : lockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDraft: null == isDraft
          ? _self.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      publishedAt: freezed == publishedAt
          ? _self.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      publishedUntil: freezed == publishedUntil
          ? _self.publishedUntil
          : publishedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalUpvote: null == totalUpvote
          ? _self.totalUpvote
          : totalUpvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownvote: null == totalDownvote
          ? _self.totalDownvote
          : totalDownvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalViews: null == totalViews
          ? _self.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
      totalAggregatedViews: null == totalAggregatedViews
          ? _self.totalAggregatedViews
          : totalAggregatedViews // ignore: cast_nullable_to_non_nullable
              as int,
      publisherId: null == publisherId
          ? _self.publisherId
          : publisherId // ignore: cast_nullable_to_non_nullable
              as int,
      pollId: freezed == pollId
          ? _self.pollId
          : pollId // ignore: cast_nullable_to_non_nullable
              as int?,
      publisher: null == publisher
          ? _self.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as SnPublisher,
      metric: null == metric
          ? _self.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as SnMetric,
      preload: freezed == preload
          ? _self.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as SnPostPreload?,
    ));
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostCopyWith<$Res>? get replyTo {
    if (_self.replyTo == null) {
      return null;
    }

    return $SnPostCopyWith<$Res>(_self.replyTo!, (value) {
      return _then(_self.copyWith(replyTo: value));
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostCopyWith<$Res>? get repostTo {
    if (_self.repostTo == null) {
      return null;
    }

    return $SnPostCopyWith<$Res>(_self.repostTo!, (value) {
      return _then(_self.copyWith(repostTo: value));
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPublisherCopyWith<$Res> get publisher {
    return $SnPublisherCopyWith<$Res>(_self.publisher, (value) {
      return _then(_self.copyWith(publisher: value));
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnMetricCopyWith<$Res> get metric {
    return $SnMetricCopyWith<$Res>(_self.metric, (value) {
      return _then(_self.copyWith(metric: value));
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostPreloadCopyWith<$Res>? get preload {
    if (_self.preload == null) {
      return null;
    }

    return $SnPostPreloadCopyWith<$Res>(_self.preload!, (value) {
      return _then(_self.copyWith(preload: value));
    });
  }
}

/// @nodoc
mixin _$SnPostTag {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  dynamic get deletedAt;
  String get alias;
  String get name;
  String get description;
  dynamic get posts;

  /// Create a copy of SnPostTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnPostTagCopyWith<SnPostTag> get copyWith =>
      _$SnPostTagCopyWithImpl<SnPostTag>(this as SnPostTag, _$identity);

  /// Serializes this SnPostTag to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnPostTag &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.deletedAt, deletedAt) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.posts, posts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(deletedAt),
      alias,
      name,
      description,
      const DeepCollectionEquality().hash(posts));

  @override
  String toString() {
    return 'SnPostTag(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, posts: $posts)';
  }
}

/// @nodoc
abstract mixin class $SnPostTagCopyWith<$Res> {
  factory $SnPostTagCopyWith(SnPostTag value, $Res Function(SnPostTag) _then) =
      _$SnPostTagCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      String alias,
      String name,
      String description,
      dynamic posts});
}

/// @nodoc
class _$SnPostTagCopyWithImpl<$Res> implements $SnPostTagCopyWith<$Res> {
  _$SnPostTagCopyWithImpl(this._self, this._then);

  final SnPostTag _self;
  final $Res Function(SnPostTag) _then;

  /// Create a copy of SnPostTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? description = null,
    Object? posts = freezed,
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
              as dynamic,
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      posts: freezed == posts
          ? _self.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnPostTag implements SnPostTag {
  const _SnPostTag(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.alias,
      required this.name,
      required this.description,
      required this.posts});
  factory _SnPostTag.fromJson(Map<String, dynamic> json) =>
      _$SnPostTagFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final dynamic deletedAt;
  @override
  final String alias;
  @override
  final String name;
  @override
  final String description;
  @override
  final dynamic posts;

  /// Create a copy of SnPostTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnPostTagCopyWith<_SnPostTag> get copyWith =>
      __$SnPostTagCopyWithImpl<_SnPostTag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnPostTagToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnPostTag &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.deletedAt, deletedAt) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.posts, posts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(deletedAt),
      alias,
      name,
      description,
      const DeepCollectionEquality().hash(posts));

  @override
  String toString() {
    return 'SnPostTag(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, posts: $posts)';
  }
}

/// @nodoc
abstract mixin class _$SnPostTagCopyWith<$Res>
    implements $SnPostTagCopyWith<$Res> {
  factory _$SnPostTagCopyWith(
          _SnPostTag value, $Res Function(_SnPostTag) _then) =
      __$SnPostTagCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      String alias,
      String name,
      String description,
      dynamic posts});
}

/// @nodoc
class __$SnPostTagCopyWithImpl<$Res> implements _$SnPostTagCopyWith<$Res> {
  __$SnPostTagCopyWithImpl(this._self, this._then);

  final _SnPostTag _self;
  final $Res Function(_SnPostTag) _then;

  /// Create a copy of SnPostTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? description = null,
    Object? posts = freezed,
  }) {
    return _then(_SnPostTag(
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
              as dynamic,
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      posts: freezed == posts
          ? _self.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
mixin _$SnPostCategory {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  dynamic get deletedAt;
  String get alias;
  String get name;
  String get description;
  dynamic get posts;

  /// Create a copy of SnPostCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnPostCategoryCopyWith<SnPostCategory> get copyWith =>
      _$SnPostCategoryCopyWithImpl<SnPostCategory>(
          this as SnPostCategory, _$identity);

  /// Serializes this SnPostCategory to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnPostCategory &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.deletedAt, deletedAt) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.posts, posts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(deletedAt),
      alias,
      name,
      description,
      const DeepCollectionEquality().hash(posts));

  @override
  String toString() {
    return 'SnPostCategory(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, posts: $posts)';
  }
}

/// @nodoc
abstract mixin class $SnPostCategoryCopyWith<$Res> {
  factory $SnPostCategoryCopyWith(
          SnPostCategory value, $Res Function(SnPostCategory) _then) =
      _$SnPostCategoryCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      String alias,
      String name,
      String description,
      dynamic posts});
}

/// @nodoc
class _$SnPostCategoryCopyWithImpl<$Res>
    implements $SnPostCategoryCopyWith<$Res> {
  _$SnPostCategoryCopyWithImpl(this._self, this._then);

  final SnPostCategory _self;
  final $Res Function(SnPostCategory) _then;

  /// Create a copy of SnPostCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? description = null,
    Object? posts = freezed,
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
              as dynamic,
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      posts: freezed == posts
          ? _self.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnPostCategory implements SnPostCategory {
  const _SnPostCategory(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.alias,
      required this.name,
      required this.description,
      required this.posts});
  factory _SnPostCategory.fromJson(Map<String, dynamic> json) =>
      _$SnPostCategoryFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final dynamic deletedAt;
  @override
  final String alias;
  @override
  final String name;
  @override
  final String description;
  @override
  final dynamic posts;

  /// Create a copy of SnPostCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnPostCategoryCopyWith<_SnPostCategory> get copyWith =>
      __$SnPostCategoryCopyWithImpl<_SnPostCategory>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnPostCategoryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnPostCategory &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.deletedAt, deletedAt) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.posts, posts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(deletedAt),
      alias,
      name,
      description,
      const DeepCollectionEquality().hash(posts));

  @override
  String toString() {
    return 'SnPostCategory(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, posts: $posts)';
  }
}

/// @nodoc
abstract mixin class _$SnPostCategoryCopyWith<$Res>
    implements $SnPostCategoryCopyWith<$Res> {
  factory _$SnPostCategoryCopyWith(
          _SnPostCategory value, $Res Function(_SnPostCategory) _then) =
      __$SnPostCategoryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      String alias,
      String name,
      String description,
      dynamic posts});
}

/// @nodoc
class __$SnPostCategoryCopyWithImpl<$Res>
    implements _$SnPostCategoryCopyWith<$Res> {
  __$SnPostCategoryCopyWithImpl(this._self, this._then);

  final _SnPostCategory _self;
  final $Res Function(_SnPostCategory) _then;

  /// Create a copy of SnPostCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? description = null,
    Object? posts = freezed,
  }) {
    return _then(_SnPostCategory(
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
              as dynamic,
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      posts: freezed == posts
          ? _self.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
mixin _$SnPostPreload {
  SnAttachment? get thumbnail;
  List<SnAttachment?>? get attachments;
  SnAttachment? get video;
  SnPoll? get poll;
  SnRealm? get realm;

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnPostPreloadCopyWith<SnPostPreload> get copyWith =>
      _$SnPostPreloadCopyWithImpl<SnPostPreload>(
          this as SnPostPreload, _$identity);

  /// Serializes this SnPostPreload to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnPostPreload &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            const DeepCollectionEquality()
                .equals(other.attachments, attachments) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.poll, poll) || other.poll == poll) &&
            (identical(other.realm, realm) || other.realm == realm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, thumbnail,
      const DeepCollectionEquality().hash(attachments), video, poll, realm);

  @override
  String toString() {
    return 'SnPostPreload(thumbnail: $thumbnail, attachments: $attachments, video: $video, poll: $poll, realm: $realm)';
  }
}

/// @nodoc
abstract mixin class $SnPostPreloadCopyWith<$Res> {
  factory $SnPostPreloadCopyWith(
          SnPostPreload value, $Res Function(SnPostPreload) _then) =
      _$SnPostPreloadCopyWithImpl;
  @useResult
  $Res call(
      {SnAttachment? thumbnail,
      List<SnAttachment?>? attachments,
      SnAttachment? video,
      SnPoll? poll,
      SnRealm? realm});

  $SnAttachmentCopyWith<$Res>? get thumbnail;
  $SnAttachmentCopyWith<$Res>? get video;
  $SnPollCopyWith<$Res>? get poll;
  $SnRealmCopyWith<$Res>? get realm;
}

/// @nodoc
class _$SnPostPreloadCopyWithImpl<$Res>
    implements $SnPostPreloadCopyWith<$Res> {
  _$SnPostPreloadCopyWithImpl(this._self, this._then);

  final SnPostPreload _self;
  final $Res Function(SnPostPreload) _then;

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thumbnail = freezed,
    Object? attachments = freezed,
    Object? video = freezed,
    Object? poll = freezed,
    Object? realm = freezed,
  }) {
    return _then(_self.copyWith(
      thumbnail: freezed == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      attachments: freezed == attachments
          ? _self.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<SnAttachment?>?,
      video: freezed == video
          ? _self.video
          : video // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      poll: freezed == poll
          ? _self.poll
          : poll // ignore: cast_nullable_to_non_nullable
              as SnPoll?,
      realm: freezed == realm
          ? _self.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm?,
    ));
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get thumbnail {
    if (_self.thumbnail == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.thumbnail!, (value) {
      return _then(_self.copyWith(thumbnail: value));
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get video {
    if (_self.video == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.video!, (value) {
      return _then(_self.copyWith(video: value));
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
      return null;
    }

    return $SnPollCopyWith<$Res>(_self.poll!, (value) {
      return _then(_self.copyWith(poll: value));
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
      return null;
    }

    return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
      return _then(_self.copyWith(realm: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnPostPreload implements SnPostPreload {
  const _SnPostPreload(
      {required this.thumbnail,
      required final List<SnAttachment?>? attachments,
      required this.video,
      required this.poll,
      required this.realm})
      : _attachments = attachments;
  factory _SnPostPreload.fromJson(Map<String, dynamic> json) =>
      _$SnPostPreloadFromJson(json);

  @override
  final SnAttachment? thumbnail;
  final List<SnAttachment?>? _attachments;
  @override
  List<SnAttachment?>? get attachments {
    final value = _attachments;
    if (value == null) return null;
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final SnAttachment? video;
  @override
  final SnPoll? poll;
  @override
  final SnRealm? realm;

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnPostPreloadCopyWith<_SnPostPreload> get copyWith =>
      __$SnPostPreloadCopyWithImpl<_SnPostPreload>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnPostPreloadToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnPostPreload &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.poll, poll) || other.poll == poll) &&
            (identical(other.realm, realm) || other.realm == realm));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, thumbnail,
      const DeepCollectionEquality().hash(_attachments), video, poll, realm);

  @override
  String toString() {
    return 'SnPostPreload(thumbnail: $thumbnail, attachments: $attachments, video: $video, poll: $poll, realm: $realm)';
  }
}

/// @nodoc
abstract mixin class _$SnPostPreloadCopyWith<$Res>
    implements $SnPostPreloadCopyWith<$Res> {
  factory _$SnPostPreloadCopyWith(
          _SnPostPreload value, $Res Function(_SnPostPreload) _then) =
      __$SnPostPreloadCopyWithImpl;
  @override
  @useResult
  $Res call(
      {SnAttachment? thumbnail,
      List<SnAttachment?>? attachments,
      SnAttachment? video,
      SnPoll? poll,
      SnRealm? realm});

  @override
  $SnAttachmentCopyWith<$Res>? get thumbnail;
  @override
  $SnAttachmentCopyWith<$Res>? get video;
  @override
  $SnPollCopyWith<$Res>? get poll;
  @override
  $SnRealmCopyWith<$Res>? get realm;
}

/// @nodoc
class __$SnPostPreloadCopyWithImpl<$Res>
    implements _$SnPostPreloadCopyWith<$Res> {
  __$SnPostPreloadCopyWithImpl(this._self, this._then);

  final _SnPostPreload _self;
  final $Res Function(_SnPostPreload) _then;

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? thumbnail = freezed,
    Object? attachments = freezed,
    Object? video = freezed,
    Object? poll = freezed,
    Object? realm = freezed,
  }) {
    return _then(_SnPostPreload(
      thumbnail: freezed == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      attachments: freezed == attachments
          ? _self._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<SnAttachment?>?,
      video: freezed == video
          ? _self.video
          : video // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      poll: freezed == poll
          ? _self.poll
          : poll // ignore: cast_nullable_to_non_nullable
              as SnPoll?,
      realm: freezed == realm
          ? _self.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm?,
    ));
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get thumbnail {
    if (_self.thumbnail == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.thumbnail!, (value) {
      return _then(_self.copyWith(thumbnail: value));
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get video {
    if (_self.video == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.video!, (value) {
      return _then(_self.copyWith(video: value));
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
      return null;
    }

    return $SnPollCopyWith<$Res>(_self.poll!, (value) {
      return _then(_self.copyWith(poll: value));
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
      return null;
    }

    return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
      return _then(_self.copyWith(realm: value));
    });
  }
}

/// @nodoc
mixin _$SnBody {
  List<String> get attachments;
  String get content;
  dynamic get location;
  dynamic get thumbnail;
  dynamic get title;

  /// Create a copy of SnBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnBodyCopyWith<SnBody> get copyWith =>
      _$SnBodyCopyWithImpl<SnBody>(this as SnBody, _$identity);

  /// Serializes this SnBody to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnBody &&
            const DeepCollectionEquality()
                .equals(other.attachments, attachments) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other.location, location) &&
            const DeepCollectionEquality().equals(other.thumbnail, thumbnail) &&
            const DeepCollectionEquality().equals(other.title, title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(attachments),
      content,
      const DeepCollectionEquality().hash(location),
      const DeepCollectionEquality().hash(thumbnail),
      const DeepCollectionEquality().hash(title));

  @override
  String toString() {
    return 'SnBody(attachments: $attachments, content: $content, location: $location, thumbnail: $thumbnail, title: $title)';
  }
}

/// @nodoc
abstract mixin class $SnBodyCopyWith<$Res> {
  factory $SnBodyCopyWith(SnBody value, $Res Function(SnBody) _then) =
      _$SnBodyCopyWithImpl;
  @useResult
  $Res call(
      {List<String> attachments,
      String content,
      dynamic location,
      dynamic thumbnail,
      dynamic title});
}

/// @nodoc
class _$SnBodyCopyWithImpl<$Res> implements $SnBodyCopyWith<$Res> {
  _$SnBodyCopyWithImpl(this._self, this._then);

  final SnBody _self;
  final $Res Function(SnBody) _then;

  /// Create a copy of SnBody
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachments = null,
    Object? content = null,
    Object? location = freezed,
    Object? thumbnail = freezed,
    Object? title = freezed,
  }) {
    return _then(_self.copyWith(
      attachments: null == attachments
          ? _self.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as dynamic,
      thumbnail: freezed == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as dynamic,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnBody implements SnBody {
  const _SnBody(
      {required final List<String> attachments,
      required this.content,
      required this.location,
      required this.thumbnail,
      required this.title})
      : _attachments = attachments;
  factory _SnBody.fromJson(Map<String, dynamic> json) => _$SnBodyFromJson(json);

  final List<String> _attachments;
  @override
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final String content;
  @override
  final dynamic location;
  @override
  final dynamic thumbnail;
  @override
  final dynamic title;

  /// Create a copy of SnBody
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnBodyCopyWith<_SnBody> get copyWith =>
      __$SnBodyCopyWithImpl<_SnBody>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnBodyToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnBody &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other.location, location) &&
            const DeepCollectionEquality().equals(other.thumbnail, thumbnail) &&
            const DeepCollectionEquality().equals(other.title, title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_attachments),
      content,
      const DeepCollectionEquality().hash(location),
      const DeepCollectionEquality().hash(thumbnail),
      const DeepCollectionEquality().hash(title));

  @override
  String toString() {
    return 'SnBody(attachments: $attachments, content: $content, location: $location, thumbnail: $thumbnail, title: $title)';
  }
}

/// @nodoc
abstract mixin class _$SnBodyCopyWith<$Res> implements $SnBodyCopyWith<$Res> {
  factory _$SnBodyCopyWith(_SnBody value, $Res Function(_SnBody) _then) =
      __$SnBodyCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<String> attachments,
      String content,
      dynamic location,
      dynamic thumbnail,
      dynamic title});
}

/// @nodoc
class __$SnBodyCopyWithImpl<$Res> implements _$SnBodyCopyWith<$Res> {
  __$SnBodyCopyWithImpl(this._self, this._then);

  final _SnBody _self;
  final $Res Function(_SnBody) _then;

  /// Create a copy of SnBody
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? attachments = null,
    Object? content = null,
    Object? location = freezed,
    Object? thumbnail = freezed,
    Object? title = freezed,
  }) {
    return _then(_SnBody(
      attachments: null == attachments
          ? _self._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as dynamic,
      thumbnail: freezed == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as dynamic,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
mixin _$SnMetric {
  int get replyCount;
  int get reactionCount;
  Map<String, int> get reactionList;

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnMetricCopyWith<SnMetric> get copyWith =>
      _$SnMetricCopyWithImpl<SnMetric>(this as SnMetric, _$identity);

  /// Serializes this SnMetric to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnMetric &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            (identical(other.reactionCount, reactionCount) ||
                other.reactionCount == reactionCount) &&
            const DeepCollectionEquality()
                .equals(other.reactionList, reactionList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, replyCount, reactionCount,
      const DeepCollectionEquality().hash(reactionList));

  @override
  String toString() {
    return 'SnMetric(replyCount: $replyCount, reactionCount: $reactionCount, reactionList: $reactionList)';
  }
}

/// @nodoc
abstract mixin class $SnMetricCopyWith<$Res> {
  factory $SnMetricCopyWith(SnMetric value, $Res Function(SnMetric) _then) =
      _$SnMetricCopyWithImpl;
  @useResult
  $Res call({int replyCount, int reactionCount, Map<String, int> reactionList});
}

/// @nodoc
class _$SnMetricCopyWithImpl<$Res> implements $SnMetricCopyWith<$Res> {
  _$SnMetricCopyWithImpl(this._self, this._then);

  final SnMetric _self;
  final $Res Function(SnMetric) _then;

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? replyCount = null,
    Object? reactionCount = null,
    Object? reactionList = null,
  }) {
    return _then(_self.copyWith(
      replyCount: null == replyCount
          ? _self.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionCount: null == reactionCount
          ? _self.reactionCount
          : reactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionList: null == reactionList
          ? _self.reactionList
          : reactionList // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnMetric implements SnMetric {
  const _SnMetric(
      {required this.replyCount,
      required this.reactionCount,
      final Map<String, int> reactionList = const {}})
      : _reactionList = reactionList;
  factory _SnMetric.fromJson(Map<String, dynamic> json) =>
      _$SnMetricFromJson(json);

  @override
  final int replyCount;
  @override
  final int reactionCount;
  final Map<String, int> _reactionList;
  @override
  @JsonKey()
  Map<String, int> get reactionList {
    if (_reactionList is EqualUnmodifiableMapView) return _reactionList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reactionList);
  }

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnMetricCopyWith<_SnMetric> get copyWith =>
      __$SnMetricCopyWithImpl<_SnMetric>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnMetricToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnMetric &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            (identical(other.reactionCount, reactionCount) ||
                other.reactionCount == reactionCount) &&
            const DeepCollectionEquality()
                .equals(other._reactionList, _reactionList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, replyCount, reactionCount,
      const DeepCollectionEquality().hash(_reactionList));

  @override
  String toString() {
    return 'SnMetric(replyCount: $replyCount, reactionCount: $reactionCount, reactionList: $reactionList)';
  }
}

/// @nodoc
abstract mixin class _$SnMetricCopyWith<$Res>
    implements $SnMetricCopyWith<$Res> {
  factory _$SnMetricCopyWith(_SnMetric value, $Res Function(_SnMetric) _then) =
      __$SnMetricCopyWithImpl;
  @override
  @useResult
  $Res call({int replyCount, int reactionCount, Map<String, int> reactionList});
}

/// @nodoc
class __$SnMetricCopyWithImpl<$Res> implements _$SnMetricCopyWith<$Res> {
  __$SnMetricCopyWithImpl(this._self, this._then);

  final _SnMetric _self;
  final $Res Function(_SnMetric) _then;

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? replyCount = null,
    Object? reactionCount = null,
    Object? reactionList = null,
  }) {
    return _then(_SnMetric(
      replyCount: null == replyCount
          ? _self.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionCount: null == reactionCount
          ? _self.reactionCount
          : reactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionList: null == reactionList
          ? _self._reactionList
          : reactionList // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
mixin _$SnPublisher {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  int get type;
  String get name;
  String get nick;
  String get description;
  String get avatar;
  String get banner;
  int get totalUpvote;
  int get totalDownvote;
  int? get realmId;
  int get accountId;

  /// Create a copy of SnPublisher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnPublisherCopyWith<SnPublisher> get copyWith =>
      _$SnPublisherCopyWithImpl<SnPublisher>(this as SnPublisher, _$identity);

  /// Serializes this SnPublisher to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnPublisher &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nick, nick) || other.nick == nick) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.banner, banner) || other.banner == banner) &&
            (identical(other.totalUpvote, totalUpvote) ||
                other.totalUpvote == totalUpvote) &&
            (identical(other.totalDownvote, totalDownvote) ||
                other.totalDownvote == totalDownvote) &&
            (identical(other.realmId, realmId) || other.realmId == realmId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      type,
      name,
      nick,
      description,
      avatar,
      banner,
      totalUpvote,
      totalDownvote,
      realmId,
      accountId);

  @override
  String toString() {
    return 'SnPublisher(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, name: $name, nick: $nick, description: $description, avatar: $avatar, banner: $banner, totalUpvote: $totalUpvote, totalDownvote: $totalDownvote, realmId: $realmId, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class $SnPublisherCopyWith<$Res> {
  factory $SnPublisherCopyWith(
          SnPublisher value, $Res Function(SnPublisher) _then) =
      _$SnPublisherCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int type,
      String name,
      String nick,
      String description,
      String avatar,
      String banner,
      int totalUpvote,
      int totalDownvote,
      int? realmId,
      int accountId});
}

/// @nodoc
class _$SnPublisherCopyWithImpl<$Res> implements $SnPublisherCopyWith<$Res> {
  _$SnPublisherCopyWithImpl(this._self, this._then);

  final SnPublisher _self;
  final $Res Function(SnPublisher) _then;

  /// Create a copy of SnPublisher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? type = null,
    Object? name = null,
    Object? nick = null,
    Object? description = null,
    Object? avatar = null,
    Object? banner = null,
    Object? totalUpvote = null,
    Object? totalDownvote = null,
    Object? realmId = freezed,
    Object? accountId = null,
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _self.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      banner: null == banner
          ? _self.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String,
      totalUpvote: null == totalUpvote
          ? _self.totalUpvote
          : totalUpvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownvote: null == totalDownvote
          ? _self.totalDownvote
          : totalDownvote // ignore: cast_nullable_to_non_nullable
              as int,
      realmId: freezed == realmId
          ? _self.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnPublisher implements SnPublisher {
  const _SnPublisher(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.type,
      required this.name,
      required this.nick,
      required this.description,
      required this.avatar,
      required this.banner,
      required this.totalUpvote,
      required this.totalDownvote,
      required this.realmId,
      required this.accountId});
  factory _SnPublisher.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int type;
  @override
  final String name;
  @override
  final String nick;
  @override
  final String description;
  @override
  final String avatar;
  @override
  final String banner;
  @override
  final int totalUpvote;
  @override
  final int totalDownvote;
  @override
  final int? realmId;
  @override
  final int accountId;

  /// Create a copy of SnPublisher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnPublisherCopyWith<_SnPublisher> get copyWith =>
      __$SnPublisherCopyWithImpl<_SnPublisher>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnPublisherToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnPublisher &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nick, nick) || other.nick == nick) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.banner, banner) || other.banner == banner) &&
            (identical(other.totalUpvote, totalUpvote) ||
                other.totalUpvote == totalUpvote) &&
            (identical(other.totalDownvote, totalDownvote) ||
                other.totalDownvote == totalDownvote) &&
            (identical(other.realmId, realmId) || other.realmId == realmId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      type,
      name,
      nick,
      description,
      avatar,
      banner,
      totalUpvote,
      totalDownvote,
      realmId,
      accountId);

  @override
  String toString() {
    return 'SnPublisher(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, name: $name, nick: $nick, description: $description, avatar: $avatar, banner: $banner, totalUpvote: $totalUpvote, totalDownvote: $totalDownvote, realmId: $realmId, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$SnPublisherCopyWith<$Res>
    implements $SnPublisherCopyWith<$Res> {
  factory _$SnPublisherCopyWith(
          _SnPublisher value, $Res Function(_SnPublisher) _then) =
      __$SnPublisherCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int type,
      String name,
      String nick,
      String description,
      String avatar,
      String banner,
      int totalUpvote,
      int totalDownvote,
      int? realmId,
      int accountId});
}

/// @nodoc
class __$SnPublisherCopyWithImpl<$Res> implements _$SnPublisherCopyWith<$Res> {
  __$SnPublisherCopyWithImpl(this._self, this._then);

  final _SnPublisher _self;
  final $Res Function(_SnPublisher) _then;

  /// Create a copy of SnPublisher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? type = null,
    Object? name = null,
    Object? nick = null,
    Object? description = null,
    Object? avatar = null,
    Object? banner = null,
    Object? totalUpvote = null,
    Object? totalDownvote = null,
    Object? realmId = freezed,
    Object? accountId = null,
  }) {
    return _then(_SnPublisher(
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _self.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      banner: null == banner
          ? _self.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String,
      totalUpvote: null == totalUpvote
          ? _self.totalUpvote
          : totalUpvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownvote: null == totalDownvote
          ? _self.totalDownvote
          : totalDownvote // ignore: cast_nullable_to_non_nullable
              as int,
      realmId: freezed == realmId
          ? _self.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$SnSubscription {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  int get followerId;
  int get accountId;

  /// Create a copy of SnSubscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnSubscriptionCopyWith<SnSubscription> get copyWith =>
      _$SnSubscriptionCopyWithImpl<SnSubscription>(
          this as SnSubscription, _$identity);

  /// Serializes this SnSubscription to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnSubscription &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.followerId, followerId) ||
                other.followerId == followerId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, createdAt, updatedAt, deletedAt, followerId, accountId);

  @override
  String toString() {
    return 'SnSubscription(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, followerId: $followerId, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class $SnSubscriptionCopyWith<$Res> {
  factory $SnSubscriptionCopyWith(
          SnSubscription value, $Res Function(SnSubscription) _then) =
      _$SnSubscriptionCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int followerId,
      int accountId});
}

/// @nodoc
class _$SnSubscriptionCopyWithImpl<$Res>
    implements $SnSubscriptionCopyWith<$Res> {
  _$SnSubscriptionCopyWithImpl(this._self, this._then);

  final SnSubscription _self;
  final $Res Function(SnSubscription) _then;

  /// Create a copy of SnSubscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? followerId = null,
    Object? accountId = null,
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
      followerId: null == followerId
          ? _self.followerId
          : followerId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnSubscription implements SnSubscription {
  const _SnSubscription(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.followerId,
      required this.accountId});
  factory _SnSubscription.fromJson(Map<String, dynamic> json) =>
      _$SnSubscriptionFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int followerId;
  @override
  final int accountId;

  /// Create a copy of SnSubscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnSubscriptionCopyWith<_SnSubscription> get copyWith =>
      __$SnSubscriptionCopyWithImpl<_SnSubscription>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnSubscriptionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnSubscription &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.followerId, followerId) ||
                other.followerId == followerId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, createdAt, updatedAt, deletedAt, followerId, accountId);

  @override
  String toString() {
    return 'SnSubscription(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, followerId: $followerId, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$SnSubscriptionCopyWith<$Res>
    implements $SnSubscriptionCopyWith<$Res> {
  factory _$SnSubscriptionCopyWith(
          _SnSubscription value, $Res Function(_SnSubscription) _then) =
      __$SnSubscriptionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int followerId,
      int accountId});
}

/// @nodoc
class __$SnSubscriptionCopyWithImpl<$Res>
    implements _$SnSubscriptionCopyWith<$Res> {
  __$SnSubscriptionCopyWithImpl(this._self, this._then);

  final _SnSubscription _self;
  final $Res Function(_SnSubscription) _then;

  /// Create a copy of SnSubscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? followerId = null,
    Object? accountId = null,
  }) {
    return _then(_SnSubscription(
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
      followerId: null == followerId
          ? _self.followerId
          : followerId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
