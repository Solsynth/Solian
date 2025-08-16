// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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

 String get id; String? get title; String? get description; String? get language; DateTime? get editedAt; DateTime? get publishedAt; int get visibility; String? get content; int get type; Map<String, dynamic>? get meta; int get viewsUnique; int get viewsTotal; int get upvotes; int get downvotes; int get repliesCount; String? get threadedPostId; SnPost? get threadedPost; String? get repliedPostId; SnPost? get repliedPost; String? get forwardedPostId; SnPost? get forwardedPost; String? get realmId; SnRealm? get realm; List<SnCloudFile> get attachments; SnPublisher get publisher; Map<String, int> get reactionsCount; Map<String, bool> get reactionsMade; List<dynamic> get reactions; List<SnPostTag> get tags; List<SnPostCategory> get categories; List<dynamic> get collections; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt; bool get isTruncated;
/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostCopyWith<SnPost> get copyWith => _$SnPostCopyWithImpl<SnPost>(this as SnPost, _$identity);

  /// Serializes this SnPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.language, language) || other.language == language)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.viewsUnique, viewsUnique) || other.viewsUnique == viewsUnique)&&(identical(other.viewsTotal, viewsTotal) || other.viewsTotal == viewsTotal)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.threadedPostId, threadedPostId) || other.threadedPostId == threadedPostId)&&(identical(other.threadedPost, threadedPost) || other.threadedPost == threadedPost)&&(identical(other.repliedPostId, repliedPostId) || other.repliedPostId == repliedPostId)&&(identical(other.repliedPost, repliedPost) || other.repliedPost == repliedPost)&&(identical(other.forwardedPostId, forwardedPostId) || other.forwardedPostId == forwardedPostId)&&(identical(other.forwardedPost, forwardedPost) || other.forwardedPost == forwardedPost)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&const DeepCollectionEquality().equals(other.reactionsCount, reactionsCount)&&const DeepCollectionEquality().equals(other.reactionsMade, reactionsMade)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.collections, collections)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isTruncated, isTruncated) || other.isTruncated == isTruncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,language,editedAt,publishedAt,visibility,content,type,const DeepCollectionEquality().hash(meta),viewsUnique,viewsTotal,upvotes,downvotes,repliesCount,threadedPostId,threadedPost,repliedPostId,repliedPost,forwardedPostId,forwardedPost,realmId,realm,const DeepCollectionEquality().hash(attachments),publisher,const DeepCollectionEquality().hash(reactionsCount),const DeepCollectionEquality().hash(reactionsMade),const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(collections),createdAt,updatedAt,deletedAt,isTruncated]);

@override
String toString() {
  return 'SnPost(id: $id, title: $title, description: $description, language: $language, editedAt: $editedAt, publishedAt: $publishedAt, visibility: $visibility, content: $content, type: $type, meta: $meta, viewsUnique: $viewsUnique, viewsTotal: $viewsTotal, upvotes: $upvotes, downvotes: $downvotes, repliesCount: $repliesCount, threadedPostId: $threadedPostId, threadedPost: $threadedPost, repliedPostId: $repliedPostId, repliedPost: $repliedPost, forwardedPostId: $forwardedPostId, forwardedPost: $forwardedPost, realmId: $realmId, realm: $realm, attachments: $attachments, publisher: $publisher, reactionsCount: $reactionsCount, reactionsMade: $reactionsMade, reactions: $reactions, tags: $tags, categories: $categories, collections: $collections, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isTruncated: $isTruncated)';
}


}

/// @nodoc
abstract mixin class $SnPostCopyWith<$Res>  {
  factory $SnPostCopyWith(SnPost value, $Res Function(SnPost) _then) = _$SnPostCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? description, String? language, DateTime? editedAt, DateTime? publishedAt, int visibility, String? content, int type, Map<String, dynamic>? meta, int viewsUnique, int viewsTotal, int upvotes, int downvotes, int repliesCount, String? threadedPostId, SnPost? threadedPost, String? repliedPostId, SnPost? repliedPost, String? forwardedPostId, SnPost? forwardedPost, String? realmId, SnRealm? realm, List<SnCloudFile> attachments, SnPublisher publisher, Map<String, int> reactionsCount, Map<String, bool> reactionsMade, List<dynamic> reactions, List<SnPostTag> tags, List<SnPostCategory> categories, List<dynamic> collections, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, bool isTruncated
});


$SnPostCopyWith<$Res>? get threadedPost;$SnPostCopyWith<$Res>? get repliedPost;$SnPostCopyWith<$Res>? get forwardedPost;$SnRealmCopyWith<$Res>? get realm;$SnPublisherCopyWith<$Res> get publisher;

}
/// @nodoc
class _$SnPostCopyWithImpl<$Res>
    implements $SnPostCopyWith<$Res> {
  _$SnPostCopyWithImpl(this._self, this._then);

  final SnPost _self;
  final $Res Function(SnPost) _then;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? language = freezed,Object? editedAt = freezed,Object? publishedAt = freezed,Object? visibility = null,Object? content = freezed,Object? type = null,Object? meta = freezed,Object? viewsUnique = null,Object? viewsTotal = null,Object? upvotes = null,Object? downvotes = null,Object? repliesCount = null,Object? threadedPostId = freezed,Object? threadedPost = freezed,Object? repliedPostId = freezed,Object? repliedPost = freezed,Object? forwardedPostId = freezed,Object? forwardedPost = freezed,Object? realmId = freezed,Object? realm = freezed,Object? attachments = null,Object? publisher = null,Object? reactionsCount = null,Object? reactionsMade = null,Object? reactions = null,Object? tags = null,Object? categories = null,Object? collections = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? isTruncated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,viewsUnique: null == viewsUnique ? _self.viewsUnique : viewsUnique // ignore: cast_nullable_to_non_nullable
as int,viewsTotal: null == viewsTotal ? _self.viewsTotal : viewsTotal // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,threadedPostId: freezed == threadedPostId ? _self.threadedPostId : threadedPostId // ignore: cast_nullable_to_non_nullable
as String?,threadedPost: freezed == threadedPost ? _self.threadedPost : threadedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,repliedPostId: freezed == repliedPostId ? _self.repliedPostId : repliedPostId // ignore: cast_nullable_to_non_nullable
as String?,repliedPost: freezed == repliedPost ? _self.repliedPost : repliedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,forwardedPostId: freezed == forwardedPostId ? _self.forwardedPostId : forwardedPostId // ignore: cast_nullable_to_non_nullable
as String?,forwardedPost: freezed == forwardedPost ? _self.forwardedPost : forwardedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher,reactionsCount: null == reactionsCount ? _self.reactionsCount : reactionsCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,reactionsMade: null == reactionsMade ? _self.reactionsMade : reactionsMade // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<SnPostTag>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<SnPostCategory>,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isTruncated: null == isTruncated ? _self.isTruncated : isTruncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get threadedPost {
    if (_self.threadedPost == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.threadedPost!, (value) {
    return _then(_self.copyWith(threadedPost: value));
  });
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get repliedPost {
    if (_self.repliedPost == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.repliedPost!, (value) {
    return _then(_self.copyWith(repliedPost: value));
  });
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get forwardedPost {
    if (_self.forwardedPost == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.forwardedPost!, (value) {
    return _then(_self.copyWith(forwardedPost: value));
  });
}/// Create a copy of SnPost
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
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res> get publisher {
  
  return $SnPublisherCopyWith<$Res>(_self.publisher, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPost].
extension SnPostPatterns on SnPost {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPost() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPost value)  $default,){
final _that = this;
switch (_that) {
case _SnPost():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPost value)?  $default,){
final _that = this;
switch (_that) {
case _SnPost() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? publishedAt,  int visibility,  String? content,  int type,  Map<String, dynamic>? meta,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  List<SnCloudFile> attachments,  SnPublisher publisher,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool isTruncated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPost() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.publishedAt,_that.visibility,_that.content,_that.type,_that.meta,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.attachments,_that.publisher,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isTruncated);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? publishedAt,  int visibility,  String? content,  int type,  Map<String, dynamic>? meta,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  List<SnCloudFile> attachments,  SnPublisher publisher,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool isTruncated)  $default,) {final _that = this;
switch (_that) {
case _SnPost():
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.publishedAt,_that.visibility,_that.content,_that.type,_that.meta,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.attachments,_that.publisher,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isTruncated);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? publishedAt,  int visibility,  String? content,  int type,  Map<String, dynamic>? meta,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  List<SnCloudFile> attachments,  SnPublisher publisher,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool isTruncated)?  $default,) {final _that = this;
switch (_that) {
case _SnPost() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.publishedAt,_that.visibility,_that.content,_that.type,_that.meta,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.attachments,_that.publisher,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isTruncated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPost implements SnPost {
  const _SnPost({required this.id, this.title, this.description, this.language, this.editedAt, this.publishedAt = null, this.visibility = 0, this.content, this.type = 0, final  Map<String, dynamic>? meta, this.viewsUnique = 0, this.viewsTotal = 0, this.upvotes = 0, this.downvotes = 0, this.repliesCount = 0, this.threadedPostId, this.threadedPost, this.repliedPostId, this.repliedPost, this.forwardedPostId, this.forwardedPost, this.realmId, this.realm, final  List<SnCloudFile> attachments = const [], required this.publisher, final  Map<String, int> reactionsCount = const {}, final  Map<String, bool> reactionsMade = const {}, final  List<dynamic> reactions = const [], final  List<SnPostTag> tags = const [], final  List<SnPostCategory> categories = const [], final  List<dynamic> collections = const [], this.createdAt = null, this.updatedAt = null, this.deletedAt, this.isTruncated = false}): _meta = meta,_attachments = attachments,_reactionsCount = reactionsCount,_reactionsMade = reactionsMade,_reactions = reactions,_tags = tags,_categories = categories,_collections = collections;
  factory _SnPost.fromJson(Map<String, dynamic> json) => _$SnPostFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? description;
@override final  String? language;
@override final  DateTime? editedAt;
@override@JsonKey() final  DateTime? publishedAt;
@override@JsonKey() final  int visibility;
@override final  String? content;
@override@JsonKey() final  int type;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  int viewsUnique;
@override@JsonKey() final  int viewsTotal;
@override@JsonKey() final  int upvotes;
@override@JsonKey() final  int downvotes;
@override@JsonKey() final  int repliesCount;
@override final  String? threadedPostId;
@override final  SnPost? threadedPost;
@override final  String? repliedPostId;
@override final  SnPost? repliedPost;
@override final  String? forwardedPostId;
@override final  SnPost? forwardedPost;
@override final  String? realmId;
@override final  SnRealm? realm;
 final  List<SnCloudFile> _attachments;
@override@JsonKey() List<SnCloudFile> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  SnPublisher publisher;
 final  Map<String, int> _reactionsCount;
@override@JsonKey() Map<String, int> get reactionsCount {
  if (_reactionsCount is EqualUnmodifiableMapView) return _reactionsCount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionsCount);
}

 final  Map<String, bool> _reactionsMade;
@override@JsonKey() Map<String, bool> get reactionsMade {
  if (_reactionsMade is EqualUnmodifiableMapView) return _reactionsMade;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionsMade);
}

 final  List<dynamic> _reactions;
@override@JsonKey() List<dynamic> get reactions {
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactions);
}

 final  List<SnPostTag> _tags;
@override@JsonKey() List<SnPostTag> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<SnPostCategory> _categories;
@override@JsonKey() List<SnPostCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<dynamic> _collections;
@override@JsonKey() List<dynamic> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey() final  DateTime? updatedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  bool isTruncated;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostCopyWith<_SnPost> get copyWith => __$SnPostCopyWithImpl<_SnPost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.language, language) || other.language == language)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.viewsUnique, viewsUnique) || other.viewsUnique == viewsUnique)&&(identical(other.viewsTotal, viewsTotal) || other.viewsTotal == viewsTotal)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.threadedPostId, threadedPostId) || other.threadedPostId == threadedPostId)&&(identical(other.threadedPost, threadedPost) || other.threadedPost == threadedPost)&&(identical(other.repliedPostId, repliedPostId) || other.repliedPostId == repliedPostId)&&(identical(other.repliedPost, repliedPost) || other.repliedPost == repliedPost)&&(identical(other.forwardedPostId, forwardedPostId) || other.forwardedPostId == forwardedPostId)&&(identical(other.forwardedPost, forwardedPost) || other.forwardedPost == forwardedPost)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&const DeepCollectionEquality().equals(other._reactionsCount, _reactionsCount)&&const DeepCollectionEquality().equals(other._reactionsMade, _reactionsMade)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._collections, _collections)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isTruncated, isTruncated) || other.isTruncated == isTruncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,language,editedAt,publishedAt,visibility,content,type,const DeepCollectionEquality().hash(_meta),viewsUnique,viewsTotal,upvotes,downvotes,repliesCount,threadedPostId,threadedPost,repliedPostId,repliedPost,forwardedPostId,forwardedPost,realmId,realm,const DeepCollectionEquality().hash(_attachments),publisher,const DeepCollectionEquality().hash(_reactionsCount),const DeepCollectionEquality().hash(_reactionsMade),const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_collections),createdAt,updatedAt,deletedAt,isTruncated]);

@override
String toString() {
  return 'SnPost(id: $id, title: $title, description: $description, language: $language, editedAt: $editedAt, publishedAt: $publishedAt, visibility: $visibility, content: $content, type: $type, meta: $meta, viewsUnique: $viewsUnique, viewsTotal: $viewsTotal, upvotes: $upvotes, downvotes: $downvotes, repliesCount: $repliesCount, threadedPostId: $threadedPostId, threadedPost: $threadedPost, repliedPostId: $repliedPostId, repliedPost: $repliedPost, forwardedPostId: $forwardedPostId, forwardedPost: $forwardedPost, realmId: $realmId, realm: $realm, attachments: $attachments, publisher: $publisher, reactionsCount: $reactionsCount, reactionsMade: $reactionsMade, reactions: $reactions, tags: $tags, categories: $categories, collections: $collections, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isTruncated: $isTruncated)';
}


}

/// @nodoc
abstract mixin class _$SnPostCopyWith<$Res> implements $SnPostCopyWith<$Res> {
  factory _$SnPostCopyWith(_SnPost value, $Res Function(_SnPost) _then) = __$SnPostCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? description, String? language, DateTime? editedAt, DateTime? publishedAt, int visibility, String? content, int type, Map<String, dynamic>? meta, int viewsUnique, int viewsTotal, int upvotes, int downvotes, int repliesCount, String? threadedPostId, SnPost? threadedPost, String? repliedPostId, SnPost? repliedPost, String? forwardedPostId, SnPost? forwardedPost, String? realmId, SnRealm? realm, List<SnCloudFile> attachments, SnPublisher publisher, Map<String, int> reactionsCount, Map<String, bool> reactionsMade, List<dynamic> reactions, List<SnPostTag> tags, List<SnPostCategory> categories, List<dynamic> collections, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, bool isTruncated
});


@override $SnPostCopyWith<$Res>? get threadedPost;@override $SnPostCopyWith<$Res>? get repliedPost;@override $SnPostCopyWith<$Res>? get forwardedPost;@override $SnRealmCopyWith<$Res>? get realm;@override $SnPublisherCopyWith<$Res> get publisher;

}
/// @nodoc
class __$SnPostCopyWithImpl<$Res>
    implements _$SnPostCopyWith<$Res> {
  __$SnPostCopyWithImpl(this._self, this._then);

  final _SnPost _self;
  final $Res Function(_SnPost) _then;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? language = freezed,Object? editedAt = freezed,Object? publishedAt = freezed,Object? visibility = null,Object? content = freezed,Object? type = null,Object? meta = freezed,Object? viewsUnique = null,Object? viewsTotal = null,Object? upvotes = null,Object? downvotes = null,Object? repliesCount = null,Object? threadedPostId = freezed,Object? threadedPost = freezed,Object? repliedPostId = freezed,Object? repliedPost = freezed,Object? forwardedPostId = freezed,Object? forwardedPost = freezed,Object? realmId = freezed,Object? realm = freezed,Object? attachments = null,Object? publisher = null,Object? reactionsCount = null,Object? reactionsMade = null,Object? reactions = null,Object? tags = null,Object? categories = null,Object? collections = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? isTruncated = null,}) {
  return _then(_SnPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,viewsUnique: null == viewsUnique ? _self.viewsUnique : viewsUnique // ignore: cast_nullable_to_non_nullable
as int,viewsTotal: null == viewsTotal ? _self.viewsTotal : viewsTotal // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,threadedPostId: freezed == threadedPostId ? _self.threadedPostId : threadedPostId // ignore: cast_nullable_to_non_nullable
as String?,threadedPost: freezed == threadedPost ? _self.threadedPost : threadedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,repliedPostId: freezed == repliedPostId ? _self.repliedPostId : repliedPostId // ignore: cast_nullable_to_non_nullable
as String?,repliedPost: freezed == repliedPost ? _self.repliedPost : repliedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,forwardedPostId: freezed == forwardedPostId ? _self.forwardedPostId : forwardedPostId // ignore: cast_nullable_to_non_nullable
as String?,forwardedPost: freezed == forwardedPost ? _self.forwardedPost : forwardedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher,reactionsCount: null == reactionsCount ? _self._reactionsCount : reactionsCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,reactionsMade: null == reactionsMade ? _self._reactionsMade : reactionsMade // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<SnPostTag>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<SnPostCategory>,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isTruncated: null == isTruncated ? _self.isTruncated : isTruncated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get threadedPost {
    if (_self.threadedPost == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.threadedPost!, (value) {
    return _then(_self.copyWith(threadedPost: value));
  });
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get repliedPost {
    if (_self.repliedPost == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.repliedPost!, (value) {
    return _then(_self.copyWith(repliedPost: value));
  });
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res>? get forwardedPost {
    if (_self.forwardedPost == null) {
    return null;
  }

  return $SnPostCopyWith<$Res>(_self.forwardedPost!, (value) {
    return _then(_self.copyWith(forwardedPost: value));
  });
}/// Create a copy of SnPost
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
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res> get publisher {
  
  return $SnPublisherCopyWith<$Res>(_self.publisher, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherStats {

 int get postsCreated; int get stickerPacksCreated; int get stickersCreated; int get upvoteReceived; int get downvoteReceived;
/// Create a copy of SnPublisherStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherStatsCopyWith<SnPublisherStats> get copyWith => _$SnPublisherStatsCopyWithImpl<SnPublisherStats>(this as SnPublisherStats, _$identity);

  /// Serializes this SnPublisherStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherStats&&(identical(other.postsCreated, postsCreated) || other.postsCreated == postsCreated)&&(identical(other.stickerPacksCreated, stickerPacksCreated) || other.stickerPacksCreated == stickerPacksCreated)&&(identical(other.stickersCreated, stickersCreated) || other.stickersCreated == stickersCreated)&&(identical(other.upvoteReceived, upvoteReceived) || other.upvoteReceived == upvoteReceived)&&(identical(other.downvoteReceived, downvoteReceived) || other.downvoteReceived == downvoteReceived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postsCreated,stickerPacksCreated,stickersCreated,upvoteReceived,downvoteReceived);

@override
String toString() {
  return 'SnPublisherStats(postsCreated: $postsCreated, stickerPacksCreated: $stickerPacksCreated, stickersCreated: $stickersCreated, upvoteReceived: $upvoteReceived, downvoteReceived: $downvoteReceived)';
}


}

/// @nodoc
abstract mixin class $SnPublisherStatsCopyWith<$Res>  {
  factory $SnPublisherStatsCopyWith(SnPublisherStats value, $Res Function(SnPublisherStats) _then) = _$SnPublisherStatsCopyWithImpl;
@useResult
$Res call({
 int postsCreated, int stickerPacksCreated, int stickersCreated, int upvoteReceived, int downvoteReceived
});




}
/// @nodoc
class _$SnPublisherStatsCopyWithImpl<$Res>
    implements $SnPublisherStatsCopyWith<$Res> {
  _$SnPublisherStatsCopyWithImpl(this._self, this._then);

  final SnPublisherStats _self;
  final $Res Function(SnPublisherStats) _then;

/// Create a copy of SnPublisherStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postsCreated = null,Object? stickerPacksCreated = null,Object? stickersCreated = null,Object? upvoteReceived = null,Object? downvoteReceived = null,}) {
  return _then(_self.copyWith(
postsCreated: null == postsCreated ? _self.postsCreated : postsCreated // ignore: cast_nullable_to_non_nullable
as int,stickerPacksCreated: null == stickerPacksCreated ? _self.stickerPacksCreated : stickerPacksCreated // ignore: cast_nullable_to_non_nullable
as int,stickersCreated: null == stickersCreated ? _self.stickersCreated : stickersCreated // ignore: cast_nullable_to_non_nullable
as int,upvoteReceived: null == upvoteReceived ? _self.upvoteReceived : upvoteReceived // ignore: cast_nullable_to_non_nullable
as int,downvoteReceived: null == downvoteReceived ? _self.downvoteReceived : downvoteReceived // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublisherStats].
extension SnPublisherStatsPatterns on SnPublisherStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherStats value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherStats():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherStats value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int postsCreated,  int stickerPacksCreated,  int stickersCreated,  int upvoteReceived,  int downvoteReceived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherStats() when $default != null:
return $default(_that.postsCreated,_that.stickerPacksCreated,_that.stickersCreated,_that.upvoteReceived,_that.downvoteReceived);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int postsCreated,  int stickerPacksCreated,  int stickersCreated,  int upvoteReceived,  int downvoteReceived)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherStats():
return $default(_that.postsCreated,_that.stickerPacksCreated,_that.stickersCreated,_that.upvoteReceived,_that.downvoteReceived);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int postsCreated,  int stickerPacksCreated,  int stickersCreated,  int upvoteReceived,  int downvoteReceived)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherStats() when $default != null:
return $default(_that.postsCreated,_that.stickerPacksCreated,_that.stickersCreated,_that.upvoteReceived,_that.downvoteReceived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherStats implements SnPublisherStats {
  const _SnPublisherStats({required this.postsCreated, required this.stickerPacksCreated, required this.stickersCreated, required this.upvoteReceived, required this.downvoteReceived});
  factory _SnPublisherStats.fromJson(Map<String, dynamic> json) => _$SnPublisherStatsFromJson(json);

@override final  int postsCreated;
@override final  int stickerPacksCreated;
@override final  int stickersCreated;
@override final  int upvoteReceived;
@override final  int downvoteReceived;

/// Create a copy of SnPublisherStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherStatsCopyWith<_SnPublisherStats> get copyWith => __$SnPublisherStatsCopyWithImpl<_SnPublisherStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherStats&&(identical(other.postsCreated, postsCreated) || other.postsCreated == postsCreated)&&(identical(other.stickerPacksCreated, stickerPacksCreated) || other.stickerPacksCreated == stickerPacksCreated)&&(identical(other.stickersCreated, stickersCreated) || other.stickersCreated == stickersCreated)&&(identical(other.upvoteReceived, upvoteReceived) || other.upvoteReceived == upvoteReceived)&&(identical(other.downvoteReceived, downvoteReceived) || other.downvoteReceived == downvoteReceived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postsCreated,stickerPacksCreated,stickersCreated,upvoteReceived,downvoteReceived);

@override
String toString() {
  return 'SnPublisherStats(postsCreated: $postsCreated, stickerPacksCreated: $stickerPacksCreated, stickersCreated: $stickersCreated, upvoteReceived: $upvoteReceived, downvoteReceived: $downvoteReceived)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherStatsCopyWith<$Res> implements $SnPublisherStatsCopyWith<$Res> {
  factory _$SnPublisherStatsCopyWith(_SnPublisherStats value, $Res Function(_SnPublisherStats) _then) = __$SnPublisherStatsCopyWithImpl;
@override @useResult
$Res call({
 int postsCreated, int stickerPacksCreated, int stickersCreated, int upvoteReceived, int downvoteReceived
});




}
/// @nodoc
class __$SnPublisherStatsCopyWithImpl<$Res>
    implements _$SnPublisherStatsCopyWith<$Res> {
  __$SnPublisherStatsCopyWithImpl(this._self, this._then);

  final _SnPublisherStats _self;
  final $Res Function(_SnPublisherStats) _then;

/// Create a copy of SnPublisherStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postsCreated = null,Object? stickerPacksCreated = null,Object? stickersCreated = null,Object? upvoteReceived = null,Object? downvoteReceived = null,}) {
  return _then(_SnPublisherStats(
postsCreated: null == postsCreated ? _self.postsCreated : postsCreated // ignore: cast_nullable_to_non_nullable
as int,stickerPacksCreated: null == stickerPacksCreated ? _self.stickerPacksCreated : stickerPacksCreated // ignore: cast_nullable_to_non_nullable
as int,stickersCreated: null == stickersCreated ? _self.stickersCreated : stickersCreated // ignore: cast_nullable_to_non_nullable
as int,upvoteReceived: null == upvoteReceived ? _self.upvoteReceived : upvoteReceived // ignore: cast_nullable_to_non_nullable
as int,downvoteReceived: null == downvoteReceived ? _self.downvoteReceived : downvoteReceived // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SnSubscriptionStatus {

 bool get isSubscribed; String get publisherId; String get publisherName;
/// Create a copy of SnSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSubscriptionStatusCopyWith<SnSubscriptionStatus> get copyWith => _$SnSubscriptionStatusCopyWithImpl<SnSubscriptionStatus>(this as SnSubscriptionStatus, _$identity);

  /// Serializes this SnSubscriptionStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSubscriptionStatus&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isSubscribed,publisherId,publisherName);

@override
String toString() {
  return 'SnSubscriptionStatus(isSubscribed: $isSubscribed, publisherId: $publisherId, publisherName: $publisherName)';
}


}

/// @nodoc
abstract mixin class $SnSubscriptionStatusCopyWith<$Res>  {
  factory $SnSubscriptionStatusCopyWith(SnSubscriptionStatus value, $Res Function(SnSubscriptionStatus) _then) = _$SnSubscriptionStatusCopyWithImpl;
@useResult
$Res call({
 bool isSubscribed, String publisherId, String publisherName
});




}
/// @nodoc
class _$SnSubscriptionStatusCopyWithImpl<$Res>
    implements $SnSubscriptionStatusCopyWith<$Res> {
  _$SnSubscriptionStatusCopyWithImpl(this._self, this._then);

  final SnSubscriptionStatus _self;
  final $Res Function(SnSubscriptionStatus) _then;

/// Create a copy of SnSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSubscribed = null,Object? publisherId = null,Object? publisherName = null,}) {
  return _then(_self.copyWith(
isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisherName: null == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnSubscriptionStatus].
extension SnSubscriptionStatusPatterns on SnSubscriptionStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSubscriptionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSubscriptionStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSubscriptionStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnSubscriptionStatus():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSubscriptionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnSubscriptionStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSubscribed,  String publisherId,  String publisherName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSubscriptionStatus() when $default != null:
return $default(_that.isSubscribed,_that.publisherId,_that.publisherName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSubscribed,  String publisherId,  String publisherName)  $default,) {final _that = this;
switch (_that) {
case _SnSubscriptionStatus():
return $default(_that.isSubscribed,_that.publisherId,_that.publisherName);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSubscribed,  String publisherId,  String publisherName)?  $default,) {final _that = this;
switch (_that) {
case _SnSubscriptionStatus() when $default != null:
return $default(_that.isSubscribed,_that.publisherId,_that.publisherName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSubscriptionStatus implements SnSubscriptionStatus {
  const _SnSubscriptionStatus({required this.isSubscribed, required this.publisherId, required this.publisherName});
  factory _SnSubscriptionStatus.fromJson(Map<String, dynamic> json) => _$SnSubscriptionStatusFromJson(json);

@override final  bool isSubscribed;
@override final  String publisherId;
@override final  String publisherName;

/// Create a copy of SnSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSubscriptionStatusCopyWith<_SnSubscriptionStatus> get copyWith => __$SnSubscriptionStatusCopyWithImpl<_SnSubscriptionStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSubscriptionStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSubscriptionStatus&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isSubscribed,publisherId,publisherName);

@override
String toString() {
  return 'SnSubscriptionStatus(isSubscribed: $isSubscribed, publisherId: $publisherId, publisherName: $publisherName)';
}


}

/// @nodoc
abstract mixin class _$SnSubscriptionStatusCopyWith<$Res> implements $SnSubscriptionStatusCopyWith<$Res> {
  factory _$SnSubscriptionStatusCopyWith(_SnSubscriptionStatus value, $Res Function(_SnSubscriptionStatus) _then) = __$SnSubscriptionStatusCopyWithImpl;
@override @useResult
$Res call({
 bool isSubscribed, String publisherId, String publisherName
});




}
/// @nodoc
class __$SnSubscriptionStatusCopyWithImpl<$Res>
    implements _$SnSubscriptionStatusCopyWith<$Res> {
  __$SnSubscriptionStatusCopyWithImpl(this._self, this._then);

  final _SnSubscriptionStatus _self;
  final $Res Function(_SnSubscriptionStatus) _then;

/// Create a copy of SnSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSubscribed = null,Object? publisherId = null,Object? publisherName = null,}) {
  return _then(_SnSubscriptionStatus(
isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisherName: null == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ReactInfo {

 String get icon; int get attitude;
/// Create a copy of ReactInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactInfoCopyWith<ReactInfo> get copyWith => _$ReactInfoCopyWithImpl<ReactInfo>(this as ReactInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReactInfo&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.attitude, attitude) || other.attitude == attitude));
}


@override
int get hashCode => Object.hash(runtimeType,icon,attitude);

@override
String toString() {
  return 'ReactInfo(icon: $icon, attitude: $attitude)';
}


}

/// @nodoc
abstract mixin class $ReactInfoCopyWith<$Res>  {
  factory $ReactInfoCopyWith(ReactInfo value, $Res Function(ReactInfo) _then) = _$ReactInfoCopyWithImpl;
@useResult
$Res call({
 String icon, int attitude
});




}
/// @nodoc
class _$ReactInfoCopyWithImpl<$Res>
    implements $ReactInfoCopyWith<$Res> {
  _$ReactInfoCopyWithImpl(this._self, this._then);

  final ReactInfo _self;
  final $Res Function(ReactInfo) _then;

/// Create a copy of ReactInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? attitude = null,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReactInfo].
extension ReactInfoPatterns on ReactInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReactInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReactInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReactInfo value)  $default,){
final _that = this;
switch (_that) {
case _ReactInfo():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReactInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ReactInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String icon,  int attitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReactInfo() when $default != null:
return $default(_that.icon,_that.attitude);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String icon,  int attitude)  $default,) {final _that = this;
switch (_that) {
case _ReactInfo():
return $default(_that.icon,_that.attitude);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String icon,  int attitude)?  $default,) {final _that = this;
switch (_that) {
case _ReactInfo() when $default != null:
return $default(_that.icon,_that.attitude);case _:
  return null;

}
}

}

/// @nodoc


class _ReactInfo implements ReactInfo {
  const _ReactInfo({required this.icon, required this.attitude});
  

@override final  String icon;
@override final  int attitude;

/// Create a copy of ReactInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactInfoCopyWith<_ReactInfo> get copyWith => __$ReactInfoCopyWithImpl<_ReactInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReactInfo&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.attitude, attitude) || other.attitude == attitude));
}


@override
int get hashCode => Object.hash(runtimeType,icon,attitude);

@override
String toString() {
  return 'ReactInfo(icon: $icon, attitude: $attitude)';
}


}

/// @nodoc
abstract mixin class _$ReactInfoCopyWith<$Res> implements $ReactInfoCopyWith<$Res> {
  factory _$ReactInfoCopyWith(_ReactInfo value, $Res Function(_ReactInfo) _then) = __$ReactInfoCopyWithImpl;
@override @useResult
$Res call({
 String icon, int attitude
});




}
/// @nodoc
class __$ReactInfoCopyWithImpl<$Res>
    implements _$ReactInfoCopyWith<$Res> {
  __$ReactInfoCopyWithImpl(this._self, this._then);

  final _ReactInfo _self;
  final $Res Function(_ReactInfo) _then;

/// Create a copy of ReactInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? attitude = null,}) {
  return _then(_ReactInfo(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
