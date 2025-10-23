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

 String get id; String? get title; String? get description; String? get language; DateTime? get editedAt; DateTime? get publishedAt; int get visibility; String? get content; String? get slug; int get type; Map<String, dynamic>? get meta; SnPostEmbedView? get embedView; int get viewsUnique; int get viewsTotal; int get upvotes; int get downvotes; int get repliesCount; int get awardedScore; int? get pinMode; String? get threadedPostId; SnPost? get threadedPost; String? get repliedPostId; SnPost? get repliedPost; String? get forwardedPostId; SnPost? get forwardedPost; String? get realmId; SnRealm? get realm; List<SnCloudFile> get attachments; SnPublisher get publisher; Map<String, int> get reactionsCount; Map<String, bool> get reactionsMade; List<dynamic> get reactions; List<SnPostTag> get tags; List<SnPostCategory> get categories; List<dynamic> get collections; List<SnPostFeaturedRecord> get featuredRecords; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt; bool get isTruncated;
/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostCopyWith<SnPost> get copyWith => _$SnPostCopyWithImpl<SnPost>(this as SnPost, _$identity);

  /// Serializes this SnPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.language, language) || other.language == language)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.content, content) || other.content == content)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.embedView, embedView) || other.embedView == embedView)&&(identical(other.viewsUnique, viewsUnique) || other.viewsUnique == viewsUnique)&&(identical(other.viewsTotal, viewsTotal) || other.viewsTotal == viewsTotal)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.awardedScore, awardedScore) || other.awardedScore == awardedScore)&&(identical(other.pinMode, pinMode) || other.pinMode == pinMode)&&(identical(other.threadedPostId, threadedPostId) || other.threadedPostId == threadedPostId)&&(identical(other.threadedPost, threadedPost) || other.threadedPost == threadedPost)&&(identical(other.repliedPostId, repliedPostId) || other.repliedPostId == repliedPostId)&&(identical(other.repliedPost, repliedPost) || other.repliedPost == repliedPost)&&(identical(other.forwardedPostId, forwardedPostId) || other.forwardedPostId == forwardedPostId)&&(identical(other.forwardedPost, forwardedPost) || other.forwardedPost == forwardedPost)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&const DeepCollectionEquality().equals(other.reactionsCount, reactionsCount)&&const DeepCollectionEquality().equals(other.reactionsMade, reactionsMade)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.collections, collections)&&const DeepCollectionEquality().equals(other.featuredRecords, featuredRecords)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isTruncated, isTruncated) || other.isTruncated == isTruncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,language,editedAt,publishedAt,visibility,content,slug,type,const DeepCollectionEquality().hash(meta),embedView,viewsUnique,viewsTotal,upvotes,downvotes,repliesCount,awardedScore,pinMode,threadedPostId,threadedPost,repliedPostId,repliedPost,forwardedPostId,forwardedPost,realmId,realm,const DeepCollectionEquality().hash(attachments),publisher,const DeepCollectionEquality().hash(reactionsCount),const DeepCollectionEquality().hash(reactionsMade),const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(collections),const DeepCollectionEquality().hash(featuredRecords),createdAt,updatedAt,deletedAt,isTruncated]);

@override
String toString() {
  return 'SnPost(id: $id, title: $title, description: $description, language: $language, editedAt: $editedAt, publishedAt: $publishedAt, visibility: $visibility, content: $content, slug: $slug, type: $type, meta: $meta, embedView: $embedView, viewsUnique: $viewsUnique, viewsTotal: $viewsTotal, upvotes: $upvotes, downvotes: $downvotes, repliesCount: $repliesCount, awardedScore: $awardedScore, pinMode: $pinMode, threadedPostId: $threadedPostId, threadedPost: $threadedPost, repliedPostId: $repliedPostId, repliedPost: $repliedPost, forwardedPostId: $forwardedPostId, forwardedPost: $forwardedPost, realmId: $realmId, realm: $realm, attachments: $attachments, publisher: $publisher, reactionsCount: $reactionsCount, reactionsMade: $reactionsMade, reactions: $reactions, tags: $tags, categories: $categories, collections: $collections, featuredRecords: $featuredRecords, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isTruncated: $isTruncated)';
}


}

/// @nodoc
abstract mixin class $SnPostCopyWith<$Res>  {
  factory $SnPostCopyWith(SnPost value, $Res Function(SnPost) _then) = _$SnPostCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? description, String? language, DateTime? editedAt, DateTime? publishedAt, int visibility, String? content, String? slug, int type, Map<String, dynamic>? meta, SnPostEmbedView? embedView, int viewsUnique, int viewsTotal, int upvotes, int downvotes, int repliesCount, int awardedScore, int? pinMode, String? threadedPostId, SnPost? threadedPost, String? repliedPostId, SnPost? repliedPost, String? forwardedPostId, SnPost? forwardedPost, String? realmId, SnRealm? realm, List<SnCloudFile> attachments, SnPublisher publisher, Map<String, int> reactionsCount, Map<String, bool> reactionsMade, List<dynamic> reactions, List<SnPostTag> tags, List<SnPostCategory> categories, List<dynamic> collections, List<SnPostFeaturedRecord> featuredRecords, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, bool isTruncated
});


$SnPostEmbedViewCopyWith<$Res>? get embedView;$SnPostCopyWith<$Res>? get threadedPost;$SnPostCopyWith<$Res>? get repliedPost;$SnPostCopyWith<$Res>? get forwardedPost;$SnRealmCopyWith<$Res>? get realm;$SnPublisherCopyWith<$Res> get publisher;

}
/// @nodoc
class _$SnPostCopyWithImpl<$Res>
    implements $SnPostCopyWith<$Res> {
  _$SnPostCopyWithImpl(this._self, this._then);

  final SnPost _self;
  final $Res Function(SnPost) _then;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? language = freezed,Object? editedAt = freezed,Object? publishedAt = freezed,Object? visibility = null,Object? content = freezed,Object? slug = freezed,Object? type = null,Object? meta = freezed,Object? embedView = freezed,Object? viewsUnique = null,Object? viewsTotal = null,Object? upvotes = null,Object? downvotes = null,Object? repliesCount = null,Object? awardedScore = null,Object? pinMode = freezed,Object? threadedPostId = freezed,Object? threadedPost = freezed,Object? repliedPostId = freezed,Object? repliedPost = freezed,Object? forwardedPostId = freezed,Object? forwardedPost = freezed,Object? realmId = freezed,Object? realm = freezed,Object? attachments = null,Object? publisher = null,Object? reactionsCount = null,Object? reactionsMade = null,Object? reactions = null,Object? tags = null,Object? categories = null,Object? collections = null,Object? featuredRecords = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? isTruncated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,embedView: freezed == embedView ? _self.embedView : embedView // ignore: cast_nullable_to_non_nullable
as SnPostEmbedView?,viewsUnique: null == viewsUnique ? _self.viewsUnique : viewsUnique // ignore: cast_nullable_to_non_nullable
as int,viewsTotal: null == viewsTotal ? _self.viewsTotal : viewsTotal // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,awardedScore: null == awardedScore ? _self.awardedScore : awardedScore // ignore: cast_nullable_to_non_nullable
as int,pinMode: freezed == pinMode ? _self.pinMode : pinMode // ignore: cast_nullable_to_non_nullable
as int?,threadedPostId: freezed == threadedPostId ? _self.threadedPostId : threadedPostId // ignore: cast_nullable_to_non_nullable
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
as List<dynamic>,featuredRecords: null == featuredRecords ? _self.featuredRecords : featuredRecords // ignore: cast_nullable_to_non_nullable
as List<SnPostFeaturedRecord>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
$SnPostEmbedViewCopyWith<$Res>? get embedView {
    if (_self.embedView == null) {
    return null;
  }

  return $SnPostEmbedViewCopyWith<$Res>(_self.embedView!, (value) {
    return _then(_self.copyWith(embedView: value));
  });
}/// Create a copy of SnPost
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? publishedAt,  int visibility,  String? content,  String? slug,  int type,  Map<String, dynamic>? meta,  SnPostEmbedView? embedView,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  int awardedScore,  int? pinMode,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  List<SnCloudFile> attachments,  SnPublisher publisher,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections,  List<SnPostFeaturedRecord> featuredRecords,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool isTruncated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPost() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.publishedAt,_that.visibility,_that.content,_that.slug,_that.type,_that.meta,_that.embedView,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.awardedScore,_that.pinMode,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.attachments,_that.publisher,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.featuredRecords,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isTruncated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? publishedAt,  int visibility,  String? content,  String? slug,  int type,  Map<String, dynamic>? meta,  SnPostEmbedView? embedView,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  int awardedScore,  int? pinMode,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  List<SnCloudFile> attachments,  SnPublisher publisher,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections,  List<SnPostFeaturedRecord> featuredRecords,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool isTruncated)  $default,) {final _that = this;
switch (_that) {
case _SnPost():
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.publishedAt,_that.visibility,_that.content,_that.slug,_that.type,_that.meta,_that.embedView,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.awardedScore,_that.pinMode,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.attachments,_that.publisher,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.featuredRecords,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isTruncated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? publishedAt,  int visibility,  String? content,  String? slug,  int type,  Map<String, dynamic>? meta,  SnPostEmbedView? embedView,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  int awardedScore,  int? pinMode,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  List<SnCloudFile> attachments,  SnPublisher publisher,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections,  List<SnPostFeaturedRecord> featuredRecords,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool isTruncated)?  $default,) {final _that = this;
switch (_that) {
case _SnPost() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.publishedAt,_that.visibility,_that.content,_that.slug,_that.type,_that.meta,_that.embedView,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.awardedScore,_that.pinMode,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.attachments,_that.publisher,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.featuredRecords,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isTruncated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPost implements SnPost {
  const _SnPost({required this.id, this.title, this.description, this.language, this.editedAt, this.publishedAt = null, this.visibility = 0, this.content, this.slug, this.type = 0, final  Map<String, dynamic>? meta, this.embedView, this.viewsUnique = 0, this.viewsTotal = 0, this.upvotes = 0, this.downvotes = 0, this.repliesCount = 0, this.awardedScore = 0, this.pinMode, this.threadedPostId, this.threadedPost, this.repliedPostId, this.repliedPost, this.forwardedPostId, this.forwardedPost, this.realmId, this.realm, final  List<SnCloudFile> attachments = const [], required this.publisher, final  Map<String, int> reactionsCount = const {}, final  Map<String, bool> reactionsMade = const {}, final  List<dynamic> reactions = const [], final  List<SnPostTag> tags = const [], final  List<SnPostCategory> categories = const [], final  List<dynamic> collections = const [], final  List<SnPostFeaturedRecord> featuredRecords = const [], this.createdAt = null, this.updatedAt = null, this.deletedAt, this.isTruncated = false}): _meta = meta,_attachments = attachments,_reactionsCount = reactionsCount,_reactionsMade = reactionsMade,_reactions = reactions,_tags = tags,_categories = categories,_collections = collections,_featuredRecords = featuredRecords;
  factory _SnPost.fromJson(Map<String, dynamic> json) => _$SnPostFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? description;
@override final  String? language;
@override final  DateTime? editedAt;
@override@JsonKey() final  DateTime? publishedAt;
@override@JsonKey() final  int visibility;
@override final  String? content;
@override final  String? slug;
@override@JsonKey() final  int type;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  SnPostEmbedView? embedView;
@override@JsonKey() final  int viewsUnique;
@override@JsonKey() final  int viewsTotal;
@override@JsonKey() final  int upvotes;
@override@JsonKey() final  int downvotes;
@override@JsonKey() final  int repliesCount;
@override@JsonKey() final  int awardedScore;
@override final  int? pinMode;
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

 final  List<SnPostFeaturedRecord> _featuredRecords;
@override@JsonKey() List<SnPostFeaturedRecord> get featuredRecords {
  if (_featuredRecords is EqualUnmodifiableListView) return _featuredRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_featuredRecords);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.language, language) || other.language == language)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.content, content) || other.content == content)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.embedView, embedView) || other.embedView == embedView)&&(identical(other.viewsUnique, viewsUnique) || other.viewsUnique == viewsUnique)&&(identical(other.viewsTotal, viewsTotal) || other.viewsTotal == viewsTotal)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.awardedScore, awardedScore) || other.awardedScore == awardedScore)&&(identical(other.pinMode, pinMode) || other.pinMode == pinMode)&&(identical(other.threadedPostId, threadedPostId) || other.threadedPostId == threadedPostId)&&(identical(other.threadedPost, threadedPost) || other.threadedPost == threadedPost)&&(identical(other.repliedPostId, repliedPostId) || other.repliedPostId == repliedPostId)&&(identical(other.repliedPost, repliedPost) || other.repliedPost == repliedPost)&&(identical(other.forwardedPostId, forwardedPostId) || other.forwardedPostId == forwardedPostId)&&(identical(other.forwardedPost, forwardedPost) || other.forwardedPost == forwardedPost)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&const DeepCollectionEquality().equals(other._reactionsCount, _reactionsCount)&&const DeepCollectionEquality().equals(other._reactionsMade, _reactionsMade)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._collections, _collections)&&const DeepCollectionEquality().equals(other._featuredRecords, _featuredRecords)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isTruncated, isTruncated) || other.isTruncated == isTruncated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,language,editedAt,publishedAt,visibility,content,slug,type,const DeepCollectionEquality().hash(_meta),embedView,viewsUnique,viewsTotal,upvotes,downvotes,repliesCount,awardedScore,pinMode,threadedPostId,threadedPost,repliedPostId,repliedPost,forwardedPostId,forwardedPost,realmId,realm,const DeepCollectionEquality().hash(_attachments),publisher,const DeepCollectionEquality().hash(_reactionsCount),const DeepCollectionEquality().hash(_reactionsMade),const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_collections),const DeepCollectionEquality().hash(_featuredRecords),createdAt,updatedAt,deletedAt,isTruncated]);

@override
String toString() {
  return 'SnPost(id: $id, title: $title, description: $description, language: $language, editedAt: $editedAt, publishedAt: $publishedAt, visibility: $visibility, content: $content, slug: $slug, type: $type, meta: $meta, embedView: $embedView, viewsUnique: $viewsUnique, viewsTotal: $viewsTotal, upvotes: $upvotes, downvotes: $downvotes, repliesCount: $repliesCount, awardedScore: $awardedScore, pinMode: $pinMode, threadedPostId: $threadedPostId, threadedPost: $threadedPost, repliedPostId: $repliedPostId, repliedPost: $repliedPost, forwardedPostId: $forwardedPostId, forwardedPost: $forwardedPost, realmId: $realmId, realm: $realm, attachments: $attachments, publisher: $publisher, reactionsCount: $reactionsCount, reactionsMade: $reactionsMade, reactions: $reactions, tags: $tags, categories: $categories, collections: $collections, featuredRecords: $featuredRecords, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isTruncated: $isTruncated)';
}


}

/// @nodoc
abstract mixin class _$SnPostCopyWith<$Res> implements $SnPostCopyWith<$Res> {
  factory _$SnPostCopyWith(_SnPost value, $Res Function(_SnPost) _then) = __$SnPostCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? description, String? language, DateTime? editedAt, DateTime? publishedAt, int visibility, String? content, String? slug, int type, Map<String, dynamic>? meta, SnPostEmbedView? embedView, int viewsUnique, int viewsTotal, int upvotes, int downvotes, int repliesCount, int awardedScore, int? pinMode, String? threadedPostId, SnPost? threadedPost, String? repliedPostId, SnPost? repliedPost, String? forwardedPostId, SnPost? forwardedPost, String? realmId, SnRealm? realm, List<SnCloudFile> attachments, SnPublisher publisher, Map<String, int> reactionsCount, Map<String, bool> reactionsMade, List<dynamic> reactions, List<SnPostTag> tags, List<SnPostCategory> categories, List<dynamic> collections, List<SnPostFeaturedRecord> featuredRecords, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, bool isTruncated
});


@override $SnPostEmbedViewCopyWith<$Res>? get embedView;@override $SnPostCopyWith<$Res>? get threadedPost;@override $SnPostCopyWith<$Res>? get repliedPost;@override $SnPostCopyWith<$Res>? get forwardedPost;@override $SnRealmCopyWith<$Res>? get realm;@override $SnPublisherCopyWith<$Res> get publisher;

}
/// @nodoc
class __$SnPostCopyWithImpl<$Res>
    implements _$SnPostCopyWith<$Res> {
  __$SnPostCopyWithImpl(this._self, this._then);

  final _SnPost _self;
  final $Res Function(_SnPost) _then;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? language = freezed,Object? editedAt = freezed,Object? publishedAt = freezed,Object? visibility = null,Object? content = freezed,Object? slug = freezed,Object? type = null,Object? meta = freezed,Object? embedView = freezed,Object? viewsUnique = null,Object? viewsTotal = null,Object? upvotes = null,Object? downvotes = null,Object? repliesCount = null,Object? awardedScore = null,Object? pinMode = freezed,Object? threadedPostId = freezed,Object? threadedPost = freezed,Object? repliedPostId = freezed,Object? repliedPost = freezed,Object? forwardedPostId = freezed,Object? forwardedPost = freezed,Object? realmId = freezed,Object? realm = freezed,Object? attachments = null,Object? publisher = null,Object? reactionsCount = null,Object? reactionsMade = null,Object? reactions = null,Object? tags = null,Object? categories = null,Object? collections = null,Object? featuredRecords = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? isTruncated = null,}) {
  return _then(_SnPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,embedView: freezed == embedView ? _self.embedView : embedView // ignore: cast_nullable_to_non_nullable
as SnPostEmbedView?,viewsUnique: null == viewsUnique ? _self.viewsUnique : viewsUnique // ignore: cast_nullable_to_non_nullable
as int,viewsTotal: null == viewsTotal ? _self.viewsTotal : viewsTotal // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,repliesCount: null == repliesCount ? _self.repliesCount : repliesCount // ignore: cast_nullable_to_non_nullable
as int,awardedScore: null == awardedScore ? _self.awardedScore : awardedScore // ignore: cast_nullable_to_non_nullable
as int,pinMode: freezed == pinMode ? _self.pinMode : pinMode // ignore: cast_nullable_to_non_nullable
as int?,threadedPostId: freezed == threadedPostId ? _self.threadedPostId : threadedPostId // ignore: cast_nullable_to_non_nullable
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
as List<dynamic>,featuredRecords: null == featuredRecords ? _self._featuredRecords : featuredRecords // ignore: cast_nullable_to_non_nullable
as List<SnPostFeaturedRecord>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
$SnPostEmbedViewCopyWith<$Res>? get embedView {
    if (_self.embedView == null) {
    return null;
  }

  return $SnPostEmbedViewCopyWith<$Res>(_self.embedView!, (value) {
    return _then(_self.copyWith(embedView: value));
  });
}/// Create a copy of SnPost
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


/// @nodoc
mixin _$SnPostEmbedView {

 String get uri; double? get aspectRatio; PostEmbedViewRenderer get renderer;
/// Create a copy of SnPostEmbedView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostEmbedViewCopyWith<SnPostEmbedView> get copyWith => _$SnPostEmbedViewCopyWithImpl<SnPostEmbedView>(this as SnPostEmbedView, _$identity);

  /// Serializes this SnPostEmbedView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostEmbedView&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.renderer, renderer) || other.renderer == renderer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,aspectRatio,renderer);

@override
String toString() {
  return 'SnPostEmbedView(uri: $uri, aspectRatio: $aspectRatio, renderer: $renderer)';
}


}

/// @nodoc
abstract mixin class $SnPostEmbedViewCopyWith<$Res>  {
  factory $SnPostEmbedViewCopyWith(SnPostEmbedView value, $Res Function(SnPostEmbedView) _then) = _$SnPostEmbedViewCopyWithImpl;
@useResult
$Res call({
 String uri, double? aspectRatio, PostEmbedViewRenderer renderer
});




}
/// @nodoc
class _$SnPostEmbedViewCopyWithImpl<$Res>
    implements $SnPostEmbedViewCopyWith<$Res> {
  _$SnPostEmbedViewCopyWithImpl(this._self, this._then);

  final SnPostEmbedView _self;
  final $Res Function(SnPostEmbedView) _then;

/// Create a copy of SnPostEmbedView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? aspectRatio = freezed,Object? renderer = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,renderer: null == renderer ? _self.renderer : renderer // ignore: cast_nullable_to_non_nullable
as PostEmbedViewRenderer,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPostEmbedView].
extension SnPostEmbedViewPatterns on SnPostEmbedView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostEmbedView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostEmbedView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostEmbedView value)  $default,){
final _that = this;
switch (_that) {
case _SnPostEmbedView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostEmbedView value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostEmbedView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  double? aspectRatio,  PostEmbedViewRenderer renderer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostEmbedView() when $default != null:
return $default(_that.uri,_that.aspectRatio,_that.renderer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  double? aspectRatio,  PostEmbedViewRenderer renderer)  $default,) {final _that = this;
switch (_that) {
case _SnPostEmbedView():
return $default(_that.uri,_that.aspectRatio,_that.renderer);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  double? aspectRatio,  PostEmbedViewRenderer renderer)?  $default,) {final _that = this;
switch (_that) {
case _SnPostEmbedView() when $default != null:
return $default(_that.uri,_that.aspectRatio,_that.renderer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostEmbedView implements SnPostEmbedView {
  const _SnPostEmbedView({required this.uri, this.aspectRatio, this.renderer = PostEmbedViewRenderer.webView});
  factory _SnPostEmbedView.fromJson(Map<String, dynamic> json) => _$SnPostEmbedViewFromJson(json);

@override final  String uri;
@override final  double? aspectRatio;
@override@JsonKey() final  PostEmbedViewRenderer renderer;

/// Create a copy of SnPostEmbedView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostEmbedViewCopyWith<_SnPostEmbedView> get copyWith => __$SnPostEmbedViewCopyWithImpl<_SnPostEmbedView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostEmbedViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostEmbedView&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.renderer, renderer) || other.renderer == renderer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,aspectRatio,renderer);

@override
String toString() {
  return 'SnPostEmbedView(uri: $uri, aspectRatio: $aspectRatio, renderer: $renderer)';
}


}

/// @nodoc
abstract mixin class _$SnPostEmbedViewCopyWith<$Res> implements $SnPostEmbedViewCopyWith<$Res> {
  factory _$SnPostEmbedViewCopyWith(_SnPostEmbedView value, $Res Function(_SnPostEmbedView) _then) = __$SnPostEmbedViewCopyWithImpl;
@override @useResult
$Res call({
 String uri, double? aspectRatio, PostEmbedViewRenderer renderer
});




}
/// @nodoc
class __$SnPostEmbedViewCopyWithImpl<$Res>
    implements _$SnPostEmbedViewCopyWith<$Res> {
  __$SnPostEmbedViewCopyWithImpl(this._self, this._then);

  final _SnPostEmbedView _self;
  final $Res Function(_SnPostEmbedView) _then;

/// Create a copy of SnPostEmbedView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? aspectRatio = freezed,Object? renderer = null,}) {
  return _then(_SnPostEmbedView(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,renderer: null == renderer ? _self.renderer : renderer // ignore: cast_nullable_to_non_nullable
as PostEmbedViewRenderer,
  ));
}


}


/// @nodoc
mixin _$SnPostAward {

 String get id; double get amount; int get attitude; String? get message; String get postId; String get accountId; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPostAward
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostAwardCopyWith<SnPostAward> get copyWith => _$SnPostAwardCopyWithImpl<SnPostAward>(this as SnPostAward, _$identity);

  /// Serializes this SnPostAward to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostAward&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.message, message) || other.message == message)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,attitude,message,postId,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPostAward(id: $id, amount: $amount, attitude: $attitude, message: $message, postId: $postId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPostAwardCopyWith<$Res>  {
  factory $SnPostAwardCopyWith(SnPostAward value, $Res Function(SnPostAward) _then) = _$SnPostAwardCopyWithImpl;
@useResult
$Res call({
 String id, double amount, int attitude, String? message, String postId, String accountId, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnPostAwardCopyWithImpl<$Res>
    implements $SnPostAwardCopyWith<$Res> {
  _$SnPostAwardCopyWithImpl(this._self, this._then);

  final SnPostAward _self;
  final $Res Function(SnPostAward) _then;

/// Create a copy of SnPostAward
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? attitude = null,Object? message = freezed,Object? postId = null,Object? accountId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPostAward].
extension SnPostAwardPatterns on SnPostAward {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostAward value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostAward() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostAward value)  $default,){
final _that = this;
switch (_that) {
case _SnPostAward():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostAward value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostAward() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount,  int attitude,  String? message,  String postId,  String accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostAward() when $default != null:
return $default(_that.id,_that.amount,_that.attitude,_that.message,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount,  int attitude,  String? message,  String postId,  String accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPostAward():
return $default(_that.id,_that.amount,_that.attitude,_that.message,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount,  int attitude,  String? message,  String postId,  String accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPostAward() when $default != null:
return $default(_that.id,_that.amount,_that.attitude,_that.message,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostAward implements SnPostAward {
  const _SnPostAward({required this.id, required this.amount, required this.attitude, this.message, required this.postId, required this.accountId, this.createdAt = null, this.updatedAt = null, this.deletedAt});
  factory _SnPostAward.fromJson(Map<String, dynamic> json) => _$SnPostAwardFromJson(json);

@override final  String id;
@override final  double amount;
@override final  int attitude;
@override final  String? message;
@override final  String postId;
@override final  String accountId;
@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey() final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPostAward
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostAwardCopyWith<_SnPostAward> get copyWith => __$SnPostAwardCopyWithImpl<_SnPostAward>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostAwardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostAward&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.message, message) || other.message == message)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,attitude,message,postId,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPostAward(id: $id, amount: $amount, attitude: $attitude, message: $message, postId: $postId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPostAwardCopyWith<$Res> implements $SnPostAwardCopyWith<$Res> {
  factory _$SnPostAwardCopyWith(_SnPostAward value, $Res Function(_SnPostAward) _then) = __$SnPostAwardCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount, int attitude, String? message, String postId, String accountId, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnPostAwardCopyWithImpl<$Res>
    implements _$SnPostAwardCopyWith<$Res> {
  __$SnPostAwardCopyWithImpl(this._self, this._then);

  final _SnPostAward _self;
  final $Res Function(_SnPostAward) _then;

/// Create a copy of SnPostAward
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? attitude = null,Object? message = freezed,Object? postId = null,Object? accountId = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_SnPostAward(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnPostReaction {

 String get id; String get symbol; int get attitude; String get postId; String get accountId; DateTime get createdAt; DateTime get updatedAt; SnAccount? get account; DateTime? get deletedAt;
/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostReactionCopyWith<SnPostReaction> get copyWith => _$SnPostReactionCopyWithImpl<SnPostReaction>(this as SnPostReaction, _$identity);

  /// Serializes this SnPostReaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostReaction&&(identical(other.id, id) || other.id == id)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.account, account) || other.account == account)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,symbol,attitude,postId,accountId,createdAt,updatedAt,account,deletedAt);

@override
String toString() {
  return 'SnPostReaction(id: $id, symbol: $symbol, attitude: $attitude, postId: $postId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, account: $account, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPostReactionCopyWith<$Res>  {
  factory $SnPostReactionCopyWith(SnPostReaction value, $Res Function(SnPostReaction) _then) = _$SnPostReactionCopyWithImpl;
@useResult
$Res call({
 String id, String symbol, int attitude, String postId, String accountId, DateTime createdAt, DateTime updatedAt, SnAccount? account, DateTime? deletedAt
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnPostReactionCopyWithImpl<$Res>
    implements $SnPostReactionCopyWith<$Res> {
  _$SnPostReactionCopyWithImpl(this._self, this._then);

  final SnPostReaction _self;
  final $Res Function(SnPostReaction) _then;

/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? symbol = null,Object? attitude = null,Object? postId = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? account = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPostReaction].
extension SnPostReactionPatterns on SnPostReaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostReaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostReaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostReaction value)  $default,){
final _that = this;
switch (_that) {
case _SnPostReaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostReaction value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostReaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String symbol,  int attitude,  String postId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  SnAccount? account,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostReaction() when $default != null:
return $default(_that.id,_that.symbol,_that.attitude,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt,_that.account,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String symbol,  int attitude,  String postId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  SnAccount? account,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPostReaction():
return $default(_that.id,_that.symbol,_that.attitude,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt,_that.account,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String symbol,  int attitude,  String postId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  SnAccount? account,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPostReaction() when $default != null:
return $default(_that.id,_that.symbol,_that.attitude,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt,_that.account,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostReaction implements SnPostReaction {
  const _SnPostReaction({required this.id, required this.symbol, required this.attitude, required this.postId, required this.accountId, required this.createdAt, required this.updatedAt, this.account = null, this.deletedAt});
  factory _SnPostReaction.fromJson(Map<String, dynamic> json) => _$SnPostReactionFromJson(json);

@override final  String id;
@override final  String symbol;
@override final  int attitude;
@override final  String postId;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  SnAccount? account;
@override final  DateTime? deletedAt;

/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostReactionCopyWith<_SnPostReaction> get copyWith => __$SnPostReactionCopyWithImpl<_SnPostReaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostReactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostReaction&&(identical(other.id, id) || other.id == id)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.account, account) || other.account == account)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,symbol,attitude,postId,accountId,createdAt,updatedAt,account,deletedAt);

@override
String toString() {
  return 'SnPostReaction(id: $id, symbol: $symbol, attitude: $attitude, postId: $postId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, account: $account, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPostReactionCopyWith<$Res> implements $SnPostReactionCopyWith<$Res> {
  factory _$SnPostReactionCopyWith(_SnPostReaction value, $Res Function(_SnPostReaction) _then) = __$SnPostReactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String symbol, int attitude, String postId, String accountId, DateTime createdAt, DateTime updatedAt, SnAccount? account, DateTime? deletedAt
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnPostReactionCopyWithImpl<$Res>
    implements _$SnPostReactionCopyWith<$Res> {
  __$SnPostReactionCopyWithImpl(this._self, this._then);

  final _SnPostReaction _self;
  final $Res Function(_SnPostReaction) _then;

/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? symbol = null,Object? attitude = null,Object? postId = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? account = freezed,Object? deletedAt = freezed,}) {
  return _then(_SnPostReaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// @nodoc
mixin _$SnPostFeaturedRecord {

 String get id; String get postId; DateTime? get featuredAt; int get socialCredits; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPostFeaturedRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostFeaturedRecordCopyWith<SnPostFeaturedRecord> get copyWith => _$SnPostFeaturedRecordCopyWithImpl<SnPostFeaturedRecord>(this as SnPostFeaturedRecord, _$identity);

  /// Serializes this SnPostFeaturedRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostFeaturedRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.featuredAt, featuredAt) || other.featuredAt == featuredAt)&&(identical(other.socialCredits, socialCredits) || other.socialCredits == socialCredits)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,featuredAt,socialCredits,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPostFeaturedRecord(id: $id, postId: $postId, featuredAt: $featuredAt, socialCredits: $socialCredits, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPostFeaturedRecordCopyWith<$Res>  {
  factory $SnPostFeaturedRecordCopyWith(SnPostFeaturedRecord value, $Res Function(SnPostFeaturedRecord) _then) = _$SnPostFeaturedRecordCopyWithImpl;
@useResult
$Res call({
 String id, String postId, DateTime? featuredAt, int socialCredits, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnPostFeaturedRecordCopyWithImpl<$Res>
    implements $SnPostFeaturedRecordCopyWith<$Res> {
  _$SnPostFeaturedRecordCopyWithImpl(this._self, this._then);

  final SnPostFeaturedRecord _self;
  final $Res Function(SnPostFeaturedRecord) _then;

/// Create a copy of SnPostFeaturedRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? featuredAt = freezed,Object? socialCredits = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,featuredAt: freezed == featuredAt ? _self.featuredAt : featuredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,socialCredits: null == socialCredits ? _self.socialCredits : socialCredits // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPostFeaturedRecord].
extension SnPostFeaturedRecordPatterns on SnPostFeaturedRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostFeaturedRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostFeaturedRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostFeaturedRecord value)  $default,){
final _that = this;
switch (_that) {
case _SnPostFeaturedRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostFeaturedRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostFeaturedRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String postId,  DateTime? featuredAt,  int socialCredits,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostFeaturedRecord() when $default != null:
return $default(_that.id,_that.postId,_that.featuredAt,_that.socialCredits,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String postId,  DateTime? featuredAt,  int socialCredits,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPostFeaturedRecord():
return $default(_that.id,_that.postId,_that.featuredAt,_that.socialCredits,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String postId,  DateTime? featuredAt,  int socialCredits,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPostFeaturedRecord() when $default != null:
return $default(_that.id,_that.postId,_that.featuredAt,_that.socialCredits,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostFeaturedRecord implements SnPostFeaturedRecord {
  const _SnPostFeaturedRecord({required this.id, required this.postId, required this.featuredAt, required this.socialCredits, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnPostFeaturedRecord.fromJson(Map<String, dynamic> json) => _$SnPostFeaturedRecordFromJson(json);

@override final  String id;
@override final  String postId;
@override final  DateTime? featuredAt;
@override final  int socialCredits;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPostFeaturedRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostFeaturedRecordCopyWith<_SnPostFeaturedRecord> get copyWith => __$SnPostFeaturedRecordCopyWithImpl<_SnPostFeaturedRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostFeaturedRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostFeaturedRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.featuredAt, featuredAt) || other.featuredAt == featuredAt)&&(identical(other.socialCredits, socialCredits) || other.socialCredits == socialCredits)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,featuredAt,socialCredits,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPostFeaturedRecord(id: $id, postId: $postId, featuredAt: $featuredAt, socialCredits: $socialCredits, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPostFeaturedRecordCopyWith<$Res> implements $SnPostFeaturedRecordCopyWith<$Res> {
  factory _$SnPostFeaturedRecordCopyWith(_SnPostFeaturedRecord value, $Res Function(_SnPostFeaturedRecord) _then) = __$SnPostFeaturedRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String postId, DateTime? featuredAt, int socialCredits, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnPostFeaturedRecordCopyWithImpl<$Res>
    implements _$SnPostFeaturedRecordCopyWith<$Res> {
  __$SnPostFeaturedRecordCopyWithImpl(this._self, this._then);

  final _SnPostFeaturedRecord _self;
  final $Res Function(_SnPostFeaturedRecord) _then;

/// Create a copy of SnPostFeaturedRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? featuredAt = freezed,Object? socialCredits = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPostFeaturedRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,featuredAt: freezed == featuredAt ? _self.featuredAt : featuredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,socialCredits: null == socialCredits ? _self.socialCredits : socialCredits // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
