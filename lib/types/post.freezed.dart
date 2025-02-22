// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SnPost _$SnPostFromJson(Map<String, dynamic> json) {
  return _SnPost.fromJson(json);
}

/// @nodoc
mixin _$SnPost {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get body => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String? get alias => throw _privateConstructorUsedError;
  String? get aliasPrefix => throw _privateConstructorUsedError;
  List<SnPostTag> get tags => throw _privateConstructorUsedError;
  List<SnPostCategory> get categories => throw _privateConstructorUsedError;
  List<SnPost>? get replies => throw _privateConstructorUsedError;
  int? get replyId => throw _privateConstructorUsedError;
  int? get repostId => throw _privateConstructorUsedError;
  int? get realmId => throw _privateConstructorUsedError;
  SnPost? get replyTo => throw _privateConstructorUsedError;
  SnPost? get repostTo => throw _privateConstructorUsedError;
  List<int>? get visibleUsersList => throw _privateConstructorUsedError;
  List<int>? get invisibleUsersList => throw _privateConstructorUsedError;
  int get visibility => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  DateTime? get pinnedAt => throw _privateConstructorUsedError;
  DateTime? get lockedAt => throw _privateConstructorUsedError;
  bool get isDraft => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  DateTime? get publishedUntil => throw _privateConstructorUsedError;
  int get totalUpvote => throw _privateConstructorUsedError;
  int get totalDownvote => throw _privateConstructorUsedError;
  int get totalViews => throw _privateConstructorUsedError;
  int get totalAggregatedViews => throw _privateConstructorUsedError;
  int get publisherId => throw _privateConstructorUsedError;
  int? get pollId => throw _privateConstructorUsedError;
  SnPublisher get publisher => throw _privateConstructorUsedError;
  SnMetric get metric => throw _privateConstructorUsedError;
  SnPostPreload? get preload => throw _privateConstructorUsedError;

  /// Serializes this SnPost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnPostCopyWith<SnPost> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnPostCopyWith<$Res> {
  factory $SnPostCopyWith(SnPost value, $Res Function(SnPost) then) =
      _$SnPostCopyWithImpl<$Res, SnPost>;
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
class _$SnPostCopyWithImpl<$Res, $Val extends SnPost>
    implements $SnPostCopyWith<$Res> {
  _$SnPostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      alias: freezed == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      aliasPrefix: freezed == aliasPrefix
          ? _value.aliasPrefix
          : aliasPrefix // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<SnPostTag>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<SnPostCategory>,
      replies: freezed == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<SnPost>?,
      replyId: freezed == replyId
          ? _value.replyId
          : replyId // ignore: cast_nullable_to_non_nullable
              as int?,
      repostId: freezed == repostId
          ? _value.repostId
          : repostId // ignore: cast_nullable_to_non_nullable
              as int?,
      realmId: freezed == realmId
          ? _value.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      replyTo: freezed == replyTo
          ? _value.replyTo
          : replyTo // ignore: cast_nullable_to_non_nullable
              as SnPost?,
      repostTo: freezed == repostTo
          ? _value.repostTo
          : repostTo // ignore: cast_nullable_to_non_nullable
              as SnPost?,
      visibleUsersList: freezed == visibleUsersList
          ? _value.visibleUsersList
          : visibleUsersList // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      invisibleUsersList: freezed == invisibleUsersList
          ? _value.invisibleUsersList
          : invisibleUsersList // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as int,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pinnedAt: freezed == pinnedAt
          ? _value.pinnedAt
          : pinnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lockedAt: freezed == lockedAt
          ? _value.lockedAt
          : lockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      publishedUntil: freezed == publishedUntil
          ? _value.publishedUntil
          : publishedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalUpvote: null == totalUpvote
          ? _value.totalUpvote
          : totalUpvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownvote: null == totalDownvote
          ? _value.totalDownvote
          : totalDownvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalViews: null == totalViews
          ? _value.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
      totalAggregatedViews: null == totalAggregatedViews
          ? _value.totalAggregatedViews
          : totalAggregatedViews // ignore: cast_nullable_to_non_nullable
              as int,
      publisherId: null == publisherId
          ? _value.publisherId
          : publisherId // ignore: cast_nullable_to_non_nullable
              as int,
      pollId: freezed == pollId
          ? _value.pollId
          : pollId // ignore: cast_nullable_to_non_nullable
              as int?,
      publisher: null == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as SnPublisher,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as SnMetric,
      preload: freezed == preload
          ? _value.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as SnPostPreload?,
    ) as $Val);
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostCopyWith<$Res>? get replyTo {
    if (_value.replyTo == null) {
      return null;
    }

    return $SnPostCopyWith<$Res>(_value.replyTo!, (value) {
      return _then(_value.copyWith(replyTo: value) as $Val);
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostCopyWith<$Res>? get repostTo {
    if (_value.repostTo == null) {
      return null;
    }

    return $SnPostCopyWith<$Res>(_value.repostTo!, (value) {
      return _then(_value.copyWith(repostTo: value) as $Val);
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPublisherCopyWith<$Res> get publisher {
    return $SnPublisherCopyWith<$Res>(_value.publisher, (value) {
      return _then(_value.copyWith(publisher: value) as $Val);
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnMetricCopyWith<$Res> get metric {
    return $SnMetricCopyWith<$Res>(_value.metric, (value) {
      return _then(_value.copyWith(metric: value) as $Val);
    });
  }

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPostPreloadCopyWith<$Res>? get preload {
    if (_value.preload == null) {
      return null;
    }

    return $SnPostPreloadCopyWith<$Res>(_value.preload!, (value) {
      return _then(_value.copyWith(preload: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnPostImplCopyWith<$Res> implements $SnPostCopyWith<$Res> {
  factory _$$SnPostImplCopyWith(
          _$SnPostImpl value, $Res Function(_$SnPostImpl) then) =
      __$$SnPostImplCopyWithImpl<$Res>;
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
class __$$SnPostImplCopyWithImpl<$Res>
    extends _$SnPostCopyWithImpl<$Res, _$SnPostImpl>
    implements _$$SnPostImplCopyWith<$Res> {
  __$$SnPostImplCopyWithImpl(
      _$SnPostImpl _value, $Res Function(_$SnPostImpl) _then)
      : super(_value, _then);

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
    return _then(_$SnPostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value._body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      alias: freezed == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      aliasPrefix: freezed == aliasPrefix
          ? _value.aliasPrefix
          : aliasPrefix // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<SnPostTag>,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<SnPostCategory>,
      replies: freezed == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<SnPost>?,
      replyId: freezed == replyId
          ? _value.replyId
          : replyId // ignore: cast_nullable_to_non_nullable
              as int?,
      repostId: freezed == repostId
          ? _value.repostId
          : repostId // ignore: cast_nullable_to_non_nullable
              as int?,
      realmId: freezed == realmId
          ? _value.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      replyTo: freezed == replyTo
          ? _value.replyTo
          : replyTo // ignore: cast_nullable_to_non_nullable
              as SnPost?,
      repostTo: freezed == repostTo
          ? _value.repostTo
          : repostTo // ignore: cast_nullable_to_non_nullable
              as SnPost?,
      visibleUsersList: freezed == visibleUsersList
          ? _value._visibleUsersList
          : visibleUsersList // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      invisibleUsersList: freezed == invisibleUsersList
          ? _value._invisibleUsersList
          : invisibleUsersList // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as int,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pinnedAt: freezed == pinnedAt
          ? _value.pinnedAt
          : pinnedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lockedAt: freezed == lockedAt
          ? _value.lockedAt
          : lockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDraft: null == isDraft
          ? _value.isDraft
          : isDraft // ignore: cast_nullable_to_non_nullable
              as bool,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      publishedUntil: freezed == publishedUntil
          ? _value.publishedUntil
          : publishedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalUpvote: null == totalUpvote
          ? _value.totalUpvote
          : totalUpvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownvote: null == totalDownvote
          ? _value.totalDownvote
          : totalDownvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalViews: null == totalViews
          ? _value.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
      totalAggregatedViews: null == totalAggregatedViews
          ? _value.totalAggregatedViews
          : totalAggregatedViews // ignore: cast_nullable_to_non_nullable
              as int,
      publisherId: null == publisherId
          ? _value.publisherId
          : publisherId // ignore: cast_nullable_to_non_nullable
              as int,
      pollId: freezed == pollId
          ? _value.pollId
          : pollId // ignore: cast_nullable_to_non_nullable
              as int?,
      publisher: null == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as SnPublisher,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as SnMetric,
      preload: freezed == preload
          ? _value.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as SnPostPreload?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnPostImpl extends _SnPost {
  const _$SnPostImpl(
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

  factory _$SnPostImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnPostImplFromJson(json);

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

  @override
  String toString() {
    return 'SnPost(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, body: $body, language: $language, alias: $alias, aliasPrefix: $aliasPrefix, tags: $tags, categories: $categories, replies: $replies, replyId: $replyId, repostId: $repostId, realmId: $realmId, replyTo: $replyTo, repostTo: $repostTo, visibleUsersList: $visibleUsersList, invisibleUsersList: $invisibleUsersList, visibility: $visibility, editedAt: $editedAt, pinnedAt: $pinnedAt, lockedAt: $lockedAt, isDraft: $isDraft, publishedAt: $publishedAt, publishedUntil: $publishedUntil, totalUpvote: $totalUpvote, totalDownvote: $totalDownvote, totalViews: $totalViews, totalAggregatedViews: $totalAggregatedViews, publisherId: $publisherId, pollId: $pollId, publisher: $publisher, metric: $metric, preload: $preload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnPostImpl &&
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

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnPostImplCopyWith<_$SnPostImpl> get copyWith =>
      __$$SnPostImplCopyWithImpl<_$SnPostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnPostImplToJson(
      this,
    );
  }
}

abstract class _SnPost extends SnPost {
  const factory _SnPost(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String type,
      required final Map<String, dynamic> body,
      required final String language,
      required final String? alias,
      required final String? aliasPrefix,
      final List<SnPostTag> tags,
      final List<SnPostCategory> categories,
      required final List<SnPost>? replies,
      required final int? replyId,
      required final int? repostId,
      required final int? realmId,
      required final SnPost? replyTo,
      required final SnPost? repostTo,
      required final List<int>? visibleUsersList,
      required final List<int>? invisibleUsersList,
      required final int visibility,
      required final DateTime? editedAt,
      required final DateTime? pinnedAt,
      required final DateTime? lockedAt,
      required final bool isDraft,
      required final DateTime? publishedAt,
      required final DateTime? publishedUntil,
      required final int totalUpvote,
      required final int totalDownvote,
      final int totalViews,
      final int totalAggregatedViews,
      required final int publisherId,
      required final int? pollId,
      required final SnPublisher publisher,
      required final SnMetric metric,
      final SnPostPreload? preload}) = _$SnPostImpl;
  const _SnPost._() : super._();

  factory _SnPost.fromJson(Map<String, dynamic> json) = _$SnPostImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get type;
  @override
  Map<String, dynamic> get body;
  @override
  String get language;
  @override
  String? get alias;
  @override
  String? get aliasPrefix;
  @override
  List<SnPostTag> get tags;
  @override
  List<SnPostCategory> get categories;
  @override
  List<SnPost>? get replies;
  @override
  int? get replyId;
  @override
  int? get repostId;
  @override
  int? get realmId;
  @override
  SnPost? get replyTo;
  @override
  SnPost? get repostTo;
  @override
  List<int>? get visibleUsersList;
  @override
  List<int>? get invisibleUsersList;
  @override
  int get visibility;
  @override
  DateTime? get editedAt;
  @override
  DateTime? get pinnedAt;
  @override
  DateTime? get lockedAt;
  @override
  bool get isDraft;
  @override
  DateTime? get publishedAt;
  @override
  DateTime? get publishedUntil;
  @override
  int get totalUpvote;
  @override
  int get totalDownvote;
  @override
  int get totalViews;
  @override
  int get totalAggregatedViews;
  @override
  int get publisherId;
  @override
  int? get pollId;
  @override
  SnPublisher get publisher;
  @override
  SnMetric get metric;
  @override
  SnPostPreload? get preload;

  /// Create a copy of SnPost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnPostImplCopyWith<_$SnPostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnPostTag _$SnPostTagFromJson(Map<String, dynamic> json) {
  return _SnPostTag.fromJson(json);
}

/// @nodoc
mixin _$SnPostTag {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  dynamic get deletedAt => throw _privateConstructorUsedError;
  String get alias => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  dynamic get posts => throw _privateConstructorUsedError;

  /// Serializes this SnPostTag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnPostTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnPostTagCopyWith<SnPostTag> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnPostTagCopyWith<$Res> {
  factory $SnPostTagCopyWith(SnPostTag value, $Res Function(SnPostTag) then) =
      _$SnPostTagCopyWithImpl<$Res, SnPostTag>;
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
class _$SnPostTagCopyWithImpl<$Res, $Val extends SnPostTag>
    implements $SnPostTagCopyWith<$Res> {
  _$SnPostTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      posts: freezed == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnPostTagImplCopyWith<$Res>
    implements $SnPostTagCopyWith<$Res> {
  factory _$$SnPostTagImplCopyWith(
          _$SnPostTagImpl value, $Res Function(_$SnPostTagImpl) then) =
      __$$SnPostTagImplCopyWithImpl<$Res>;
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
class __$$SnPostTagImplCopyWithImpl<$Res>
    extends _$SnPostTagCopyWithImpl<$Res, _$SnPostTagImpl>
    implements _$$SnPostTagImplCopyWith<$Res> {
  __$$SnPostTagImplCopyWithImpl(
      _$SnPostTagImpl _value, $Res Function(_$SnPostTagImpl) _then)
      : super(_value, _then);

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
    return _then(_$SnPostTagImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      posts: freezed == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnPostTagImpl implements _SnPostTag {
  const _$SnPostTagImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.alias,
      required this.name,
      required this.description,
      required this.posts});

  factory _$SnPostTagImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnPostTagImplFromJson(json);

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

  @override
  String toString() {
    return 'SnPostTag(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, posts: $posts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnPostTagImpl &&
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

  /// Create a copy of SnPostTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnPostTagImplCopyWith<_$SnPostTagImpl> get copyWith =>
      __$$SnPostTagImplCopyWithImpl<_$SnPostTagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnPostTagImplToJson(
      this,
    );
  }
}

abstract class _SnPostTag implements SnPostTag {
  const factory _SnPostTag(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final dynamic deletedAt,
      required final String alias,
      required final String name,
      required final String description,
      required final dynamic posts}) = _$SnPostTagImpl;

  factory _SnPostTag.fromJson(Map<String, dynamic> json) =
      _$SnPostTagImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  dynamic get deletedAt;
  @override
  String get alias;
  @override
  String get name;
  @override
  String get description;
  @override
  dynamic get posts;

  /// Create a copy of SnPostTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnPostTagImplCopyWith<_$SnPostTagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnPostCategory _$SnPostCategoryFromJson(Map<String, dynamic> json) {
  return _SnPostCategory.fromJson(json);
}

/// @nodoc
mixin _$SnPostCategory {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  dynamic get deletedAt => throw _privateConstructorUsedError;
  String get alias => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  dynamic get posts => throw _privateConstructorUsedError;

  /// Serializes this SnPostCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnPostCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnPostCategoryCopyWith<SnPostCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnPostCategoryCopyWith<$Res> {
  factory $SnPostCategoryCopyWith(
          SnPostCategory value, $Res Function(SnPostCategory) then) =
      _$SnPostCategoryCopyWithImpl<$Res, SnPostCategory>;
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
class _$SnPostCategoryCopyWithImpl<$Res, $Val extends SnPostCategory>
    implements $SnPostCategoryCopyWith<$Res> {
  _$SnPostCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      posts: freezed == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnPostCategoryImplCopyWith<$Res>
    implements $SnPostCategoryCopyWith<$Res> {
  factory _$$SnPostCategoryImplCopyWith(_$SnPostCategoryImpl value,
          $Res Function(_$SnPostCategoryImpl) then) =
      __$$SnPostCategoryImplCopyWithImpl<$Res>;
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
class __$$SnPostCategoryImplCopyWithImpl<$Res>
    extends _$SnPostCategoryCopyWithImpl<$Res, _$SnPostCategoryImpl>
    implements _$$SnPostCategoryImplCopyWith<$Res> {
  __$$SnPostCategoryImplCopyWithImpl(
      _$SnPostCategoryImpl _value, $Res Function(_$SnPostCategoryImpl) _then)
      : super(_value, _then);

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
    return _then(_$SnPostCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      posts: freezed == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnPostCategoryImpl implements _SnPostCategory {
  const _$SnPostCategoryImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.alias,
      required this.name,
      required this.description,
      required this.posts});

  factory _$SnPostCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnPostCategoryImplFromJson(json);

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

  @override
  String toString() {
    return 'SnPostCategory(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, posts: $posts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnPostCategoryImpl &&
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

  /// Create a copy of SnPostCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnPostCategoryImplCopyWith<_$SnPostCategoryImpl> get copyWith =>
      __$$SnPostCategoryImplCopyWithImpl<_$SnPostCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnPostCategoryImplToJson(
      this,
    );
  }
}

abstract class _SnPostCategory implements SnPostCategory {
  const factory _SnPostCategory(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final dynamic deletedAt,
      required final String alias,
      required final String name,
      required final String description,
      required final dynamic posts}) = _$SnPostCategoryImpl;

  factory _SnPostCategory.fromJson(Map<String, dynamic> json) =
      _$SnPostCategoryImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  dynamic get deletedAt;
  @override
  String get alias;
  @override
  String get name;
  @override
  String get description;
  @override
  dynamic get posts;

  /// Create a copy of SnPostCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnPostCategoryImplCopyWith<_$SnPostCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnPostPreload _$SnPostPreloadFromJson(Map<String, dynamic> json) {
  return _SnPostPreload.fromJson(json);
}

/// @nodoc
mixin _$SnPostPreload {
  SnAttachment? get thumbnail => throw _privateConstructorUsedError;
  List<SnAttachment?>? get attachments => throw _privateConstructorUsedError;
  SnAttachment? get video => throw _privateConstructorUsedError;
  SnPoll? get poll => throw _privateConstructorUsedError;
  SnRealm? get realm => throw _privateConstructorUsedError;

  /// Serializes this SnPostPreload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnPostPreloadCopyWith<SnPostPreload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnPostPreloadCopyWith<$Res> {
  factory $SnPostPreloadCopyWith(
          SnPostPreload value, $Res Function(SnPostPreload) then) =
      _$SnPostPreloadCopyWithImpl<$Res, SnPostPreload>;
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
class _$SnPostPreloadCopyWithImpl<$Res, $Val extends SnPostPreload>
    implements $SnPostPreloadCopyWith<$Res> {
  _$SnPostPreloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      attachments: freezed == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<SnAttachment?>?,
      video: freezed == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      poll: freezed == poll
          ? _value.poll
          : poll // ignore: cast_nullable_to_non_nullable
              as SnPoll?,
      realm: freezed == realm
          ? _value.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm?,
    ) as $Val);
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get thumbnail {
    if (_value.thumbnail == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_value.thumbnail!, (value) {
      return _then(_value.copyWith(thumbnail: value) as $Val);
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get video {
    if (_value.video == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_value.video!, (value) {
      return _then(_value.copyWith(video: value) as $Val);
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPollCopyWith<$Res>? get poll {
    if (_value.poll == null) {
      return null;
    }

    return $SnPollCopyWith<$Res>(_value.poll!, (value) {
      return _then(_value.copyWith(poll: value) as $Val);
    });
  }

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res>? get realm {
    if (_value.realm == null) {
      return null;
    }

    return $SnRealmCopyWith<$Res>(_value.realm!, (value) {
      return _then(_value.copyWith(realm: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnPostPreloadImplCopyWith<$Res>
    implements $SnPostPreloadCopyWith<$Res> {
  factory _$$SnPostPreloadImplCopyWith(
          _$SnPostPreloadImpl value, $Res Function(_$SnPostPreloadImpl) then) =
      __$$SnPostPreloadImplCopyWithImpl<$Res>;
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
class __$$SnPostPreloadImplCopyWithImpl<$Res>
    extends _$SnPostPreloadCopyWithImpl<$Res, _$SnPostPreloadImpl>
    implements _$$SnPostPreloadImplCopyWith<$Res> {
  __$$SnPostPreloadImplCopyWithImpl(
      _$SnPostPreloadImpl _value, $Res Function(_$SnPostPreloadImpl) _then)
      : super(_value, _then);

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
    return _then(_$SnPostPreloadImpl(
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      attachments: freezed == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<SnAttachment?>?,
      video: freezed == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      poll: freezed == poll
          ? _value.poll
          : poll // ignore: cast_nullable_to_non_nullable
              as SnPoll?,
      realm: freezed == realm
          ? _value.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnPostPreloadImpl implements _SnPostPreload {
  const _$SnPostPreloadImpl(
      {required this.thumbnail,
      required final List<SnAttachment?>? attachments,
      required this.video,
      required this.poll,
      required this.realm})
      : _attachments = attachments;

  factory _$SnPostPreloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnPostPreloadImplFromJson(json);

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

  @override
  String toString() {
    return 'SnPostPreload(thumbnail: $thumbnail, attachments: $attachments, video: $video, poll: $poll, realm: $realm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnPostPreloadImpl &&
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

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnPostPreloadImplCopyWith<_$SnPostPreloadImpl> get copyWith =>
      __$$SnPostPreloadImplCopyWithImpl<_$SnPostPreloadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnPostPreloadImplToJson(
      this,
    );
  }
}

abstract class _SnPostPreload implements SnPostPreload {
  const factory _SnPostPreload(
      {required final SnAttachment? thumbnail,
      required final List<SnAttachment?>? attachments,
      required final SnAttachment? video,
      required final SnPoll? poll,
      required final SnRealm? realm}) = _$SnPostPreloadImpl;

  factory _SnPostPreload.fromJson(Map<String, dynamic> json) =
      _$SnPostPreloadImpl.fromJson;

  @override
  SnAttachment? get thumbnail;
  @override
  List<SnAttachment?>? get attachments;
  @override
  SnAttachment? get video;
  @override
  SnPoll? get poll;
  @override
  SnRealm? get realm;

  /// Create a copy of SnPostPreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnPostPreloadImplCopyWith<_$SnPostPreloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnBody _$SnBodyFromJson(Map<String, dynamic> json) {
  return _SnBody.fromJson(json);
}

/// @nodoc
mixin _$SnBody {
  List<String> get attachments => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  dynamic get location => throw _privateConstructorUsedError;
  dynamic get thumbnail => throw _privateConstructorUsedError;
  dynamic get title => throw _privateConstructorUsedError;

  /// Serializes this SnBody to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnBodyCopyWith<SnBody> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnBodyCopyWith<$Res> {
  factory $SnBodyCopyWith(SnBody value, $Res Function(SnBody) then) =
      _$SnBodyCopyWithImpl<$Res, SnBody>;
  @useResult
  $Res call(
      {List<String> attachments,
      String content,
      dynamic location,
      dynamic thumbnail,
      dynamic title});
}

/// @nodoc
class _$SnBodyCopyWithImpl<$Res, $Val extends SnBody>
    implements $SnBodyCopyWith<$Res> {
  _$SnBodyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as dynamic,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as dynamic,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnBodyImplCopyWith<$Res> implements $SnBodyCopyWith<$Res> {
  factory _$$SnBodyImplCopyWith(
          _$SnBodyImpl value, $Res Function(_$SnBodyImpl) then) =
      __$$SnBodyImplCopyWithImpl<$Res>;
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
class __$$SnBodyImplCopyWithImpl<$Res>
    extends _$SnBodyCopyWithImpl<$Res, _$SnBodyImpl>
    implements _$$SnBodyImplCopyWith<$Res> {
  __$$SnBodyImplCopyWithImpl(
      _$SnBodyImpl _value, $Res Function(_$SnBodyImpl) _then)
      : super(_value, _then);

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
    return _then(_$SnBodyImpl(
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as dynamic,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as dynamic,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnBodyImpl implements _SnBody {
  const _$SnBodyImpl(
      {required final List<String> attachments,
      required this.content,
      required this.location,
      required this.thumbnail,
      required this.title})
      : _attachments = attachments;

  factory _$SnBodyImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnBodyImplFromJson(json);

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

  @override
  String toString() {
    return 'SnBody(attachments: $attachments, content: $content, location: $location, thumbnail: $thumbnail, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnBodyImpl &&
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

  /// Create a copy of SnBody
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnBodyImplCopyWith<_$SnBodyImpl> get copyWith =>
      __$$SnBodyImplCopyWithImpl<_$SnBodyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnBodyImplToJson(
      this,
    );
  }
}

abstract class _SnBody implements SnBody {
  const factory _SnBody(
      {required final List<String> attachments,
      required final String content,
      required final dynamic location,
      required final dynamic thumbnail,
      required final dynamic title}) = _$SnBodyImpl;

  factory _SnBody.fromJson(Map<String, dynamic> json) = _$SnBodyImpl.fromJson;

  @override
  List<String> get attachments;
  @override
  String get content;
  @override
  dynamic get location;
  @override
  dynamic get thumbnail;
  @override
  dynamic get title;

  /// Create a copy of SnBody
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnBodyImplCopyWith<_$SnBodyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnMetric _$SnMetricFromJson(Map<String, dynamic> json) {
  return _SnMetric.fromJson(json);
}

/// @nodoc
mixin _$SnMetric {
  int get replyCount => throw _privateConstructorUsedError;
  int get reactionCount => throw _privateConstructorUsedError;
  Map<String, int> get reactionList => throw _privateConstructorUsedError;

  /// Serializes this SnMetric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnMetricCopyWith<SnMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnMetricCopyWith<$Res> {
  factory $SnMetricCopyWith(SnMetric value, $Res Function(SnMetric) then) =
      _$SnMetricCopyWithImpl<$Res, SnMetric>;
  @useResult
  $Res call({int replyCount, int reactionCount, Map<String, int> reactionList});
}

/// @nodoc
class _$SnMetricCopyWithImpl<$Res, $Val extends SnMetric>
    implements $SnMetricCopyWith<$Res> {
  _$SnMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? replyCount = null,
    Object? reactionCount = null,
    Object? reactionList = null,
  }) {
    return _then(_value.copyWith(
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionCount: null == reactionCount
          ? _value.reactionCount
          : reactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionList: null == reactionList
          ? _value.reactionList
          : reactionList // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnMetricImplCopyWith<$Res>
    implements $SnMetricCopyWith<$Res> {
  factory _$$SnMetricImplCopyWith(
          _$SnMetricImpl value, $Res Function(_$SnMetricImpl) then) =
      __$$SnMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int replyCount, int reactionCount, Map<String, int> reactionList});
}

/// @nodoc
class __$$SnMetricImplCopyWithImpl<$Res>
    extends _$SnMetricCopyWithImpl<$Res, _$SnMetricImpl>
    implements _$$SnMetricImplCopyWith<$Res> {
  __$$SnMetricImplCopyWithImpl(
      _$SnMetricImpl _value, $Res Function(_$SnMetricImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? replyCount = null,
    Object? reactionCount = null,
    Object? reactionList = null,
  }) {
    return _then(_$SnMetricImpl(
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionCount: null == reactionCount
          ? _value.reactionCount
          : reactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      reactionList: null == reactionList
          ? _value._reactionList
          : reactionList // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnMetricImpl implements _SnMetric {
  const _$SnMetricImpl(
      {required this.replyCount,
      required this.reactionCount,
      final Map<String, int> reactionList = const {}})
      : _reactionList = reactionList;

  factory _$SnMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnMetricImplFromJson(json);

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

  @override
  String toString() {
    return 'SnMetric(replyCount: $replyCount, reactionCount: $reactionCount, reactionList: $reactionList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnMetricImpl &&
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

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnMetricImplCopyWith<_$SnMetricImpl> get copyWith =>
      __$$SnMetricImplCopyWithImpl<_$SnMetricImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnMetricImplToJson(
      this,
    );
  }
}

abstract class _SnMetric implements SnMetric {
  const factory _SnMetric(
      {required final int replyCount,
      required final int reactionCount,
      final Map<String, int> reactionList}) = _$SnMetricImpl;

  factory _SnMetric.fromJson(Map<String, dynamic> json) =
      _$SnMetricImpl.fromJson;

  @override
  int get replyCount;
  @override
  int get reactionCount;
  @override
  Map<String, int> get reactionList;

  /// Create a copy of SnMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnMetricImplCopyWith<_$SnMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnPublisher _$SnPublisherFromJson(Map<String, dynamic> json) {
  return _SnPublisher.fromJson(json);
}

/// @nodoc
mixin _$SnPublisher {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  int get type => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nick => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get avatar => throw _privateConstructorUsedError;
  String get banner => throw _privateConstructorUsedError;
  int get totalUpvote => throw _privateConstructorUsedError;
  int get totalDownvote => throw _privateConstructorUsedError;
  int? get realmId => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;

  /// Serializes this SnPublisher to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnPublisher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnPublisherCopyWith<SnPublisher> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnPublisherCopyWith<$Res> {
  factory $SnPublisherCopyWith(
          SnPublisher value, $Res Function(SnPublisher) then) =
      _$SnPublisherCopyWithImpl<$Res, SnPublisher>;
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
class _$SnPublisherCopyWithImpl<$Res, $Val extends SnPublisher>
    implements $SnPublisherCopyWith<$Res> {
  _$SnPublisherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      banner: null == banner
          ? _value.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String,
      totalUpvote: null == totalUpvote
          ? _value.totalUpvote
          : totalUpvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownvote: null == totalDownvote
          ? _value.totalDownvote
          : totalDownvote // ignore: cast_nullable_to_non_nullable
              as int,
      realmId: freezed == realmId
          ? _value.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnPublisherImplCopyWith<$Res>
    implements $SnPublisherCopyWith<$Res> {
  factory _$$SnPublisherImplCopyWith(
          _$SnPublisherImpl value, $Res Function(_$SnPublisherImpl) then) =
      __$$SnPublisherImplCopyWithImpl<$Res>;
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
class __$$SnPublisherImplCopyWithImpl<$Res>
    extends _$SnPublisherCopyWithImpl<$Res, _$SnPublisherImpl>
    implements _$$SnPublisherImplCopyWith<$Res> {
  __$$SnPublisherImplCopyWithImpl(
      _$SnPublisherImpl _value, $Res Function(_$SnPublisherImpl) _then)
      : super(_value, _then);

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
    return _then(_$SnPublisherImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      banner: null == banner
          ? _value.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String,
      totalUpvote: null == totalUpvote
          ? _value.totalUpvote
          : totalUpvote // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownvote: null == totalDownvote
          ? _value.totalDownvote
          : totalDownvote // ignore: cast_nullable_to_non_nullable
              as int,
      realmId: freezed == realmId
          ? _value.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnPublisherImpl implements _SnPublisher {
  const _$SnPublisherImpl(
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

  factory _$SnPublisherImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnPublisherImplFromJson(json);

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

  @override
  String toString() {
    return 'SnPublisher(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, name: $name, nick: $nick, description: $description, avatar: $avatar, banner: $banner, totalUpvote: $totalUpvote, totalDownvote: $totalDownvote, realmId: $realmId, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnPublisherImpl &&
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

  /// Create a copy of SnPublisher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnPublisherImplCopyWith<_$SnPublisherImpl> get copyWith =>
      __$$SnPublisherImplCopyWithImpl<_$SnPublisherImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnPublisherImplToJson(
      this,
    );
  }
}

abstract class _SnPublisher implements SnPublisher {
  const factory _SnPublisher(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final int type,
      required final String name,
      required final String nick,
      required final String description,
      required final String avatar,
      required final String banner,
      required final int totalUpvote,
      required final int totalDownvote,
      required final int? realmId,
      required final int accountId}) = _$SnPublisherImpl;

  factory _SnPublisher.fromJson(Map<String, dynamic> json) =
      _$SnPublisherImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  int get type;
  @override
  String get name;
  @override
  String get nick;
  @override
  String get description;
  @override
  String get avatar;
  @override
  String get banner;
  @override
  int get totalUpvote;
  @override
  int get totalDownvote;
  @override
  int? get realmId;
  @override
  int get accountId;

  /// Create a copy of SnPublisher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnPublisherImplCopyWith<_$SnPublisherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnSubscription _$SnSubscriptionFromJson(Map<String, dynamic> json) {
  return _SnSubscription.fromJson(json);
}

/// @nodoc
mixin _$SnSubscription {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  int get followerId => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;

  /// Serializes this SnSubscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnSubscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnSubscriptionCopyWith<SnSubscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnSubscriptionCopyWith<$Res> {
  factory $SnSubscriptionCopyWith(
          SnSubscription value, $Res Function(SnSubscription) then) =
      _$SnSubscriptionCopyWithImpl<$Res, SnSubscription>;
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
class _$SnSubscriptionCopyWithImpl<$Res, $Val extends SnSubscription>
    implements $SnSubscriptionCopyWith<$Res> {
  _$SnSubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      followerId: null == followerId
          ? _value.followerId
          : followerId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnSubscriptionImplCopyWith<$Res>
    implements $SnSubscriptionCopyWith<$Res> {
  factory _$$SnSubscriptionImplCopyWith(_$SnSubscriptionImpl value,
          $Res Function(_$SnSubscriptionImpl) then) =
      __$$SnSubscriptionImplCopyWithImpl<$Res>;
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
class __$$SnSubscriptionImplCopyWithImpl<$Res>
    extends _$SnSubscriptionCopyWithImpl<$Res, _$SnSubscriptionImpl>
    implements _$$SnSubscriptionImplCopyWith<$Res> {
  __$$SnSubscriptionImplCopyWithImpl(
      _$SnSubscriptionImpl _value, $Res Function(_$SnSubscriptionImpl) _then)
      : super(_value, _then);

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
    return _then(_$SnSubscriptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      followerId: null == followerId
          ? _value.followerId
          : followerId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnSubscriptionImpl implements _SnSubscription {
  const _$SnSubscriptionImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.followerId,
      required this.accountId});

  factory _$SnSubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnSubscriptionImplFromJson(json);

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

  @override
  String toString() {
    return 'SnSubscription(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, followerId: $followerId, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnSubscriptionImpl &&
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

  /// Create a copy of SnSubscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnSubscriptionImplCopyWith<_$SnSubscriptionImpl> get copyWith =>
      __$$SnSubscriptionImplCopyWithImpl<_$SnSubscriptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnSubscriptionImplToJson(
      this,
    );
  }
}

abstract class _SnSubscription implements SnSubscription {
  const factory _SnSubscription(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final int followerId,
      required final int accountId}) = _$SnSubscriptionImpl;

  factory _SnSubscription.fromJson(Map<String, dynamic> json) =
      _$SnSubscriptionImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  int get followerId;
  @override
  int get accountId;

  /// Create a copy of SnSubscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnSubscriptionImplCopyWith<_$SnSubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
