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

 String get id; String? get title; String? get description; String? get language; DateTime? get editedAt; DateTime? get draftedAt; DateTime? get publishedAt; int get visibility; String? get content; String? get slug; int get type; Map<String, dynamic>? get meta; SnPostEmbedView? get embedView; int get viewsUnique; int get viewsTotal; int get upvotes; int get downvotes; int get repliesCount; int get threadedRepliesCount; double? get debugRank; int get awardedScore; int? get pinMode; String? get threadedPostId; SnPost? get threadedPost; String? get repliedPostId; SnPost? get repliedPost; String? get forwardedPostId; SnPost? get forwardedPost; String? get realmId; SnRealm? get realm; String? get publisherId; SnPublisher? get publisher; String? get actorid; SnActivityPubActor? get actor; String? get fediverseUri; int? get fediverseType; bool get isCached; int get contentType; List<SnCloudFileReference> get attachments; Map<String, int> get reactionsCount; Map<String, bool> get reactionsMade; List<dynamic> get reactions; List<SnPostTag> get tags; List<SnPostCategory> get categories;// Legacy/unspecified collections field.
// Prefer using [publisherCollections] for post-collection integration.
 List<dynamic> get collections;// Collections owned by the same publisher as the post.
// Wire format: `publisher_collections`.
@JsonKey(name: 'publisher_collections') List<SnPostCollection> get publisherCollections; List<SnPostFeaturedRecord> get featuredRecords; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt; bool get repliedGone; bool get forwardedGone; bool get isTruncated; SnActivityPubActor? get boostedBy; DateTime? get boostedAt; bool get isBookmarked;
/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostCopyWith<SnPost> get copyWith => _$SnPostCopyWithImpl<SnPost>(this as SnPost, _$identity);

  /// Serializes this SnPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.language, language) || other.language == language)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.draftedAt, draftedAt) || other.draftedAt == draftedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.content, content) || other.content == content)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.embedView, embedView) || other.embedView == embedView)&&(identical(other.viewsUnique, viewsUnique) || other.viewsUnique == viewsUnique)&&(identical(other.viewsTotal, viewsTotal) || other.viewsTotal == viewsTotal)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.threadedRepliesCount, threadedRepliesCount) || other.threadedRepliesCount == threadedRepliesCount)&&(identical(other.debugRank, debugRank) || other.debugRank == debugRank)&&(identical(other.awardedScore, awardedScore) || other.awardedScore == awardedScore)&&(identical(other.pinMode, pinMode) || other.pinMode == pinMode)&&(identical(other.threadedPostId, threadedPostId) || other.threadedPostId == threadedPostId)&&(identical(other.threadedPost, threadedPost) || other.threadedPost == threadedPost)&&(identical(other.repliedPostId, repliedPostId) || other.repliedPostId == repliedPostId)&&(identical(other.repliedPost, repliedPost) || other.repliedPost == repliedPost)&&(identical(other.forwardedPostId, forwardedPostId) || other.forwardedPostId == forwardedPostId)&&(identical(other.forwardedPost, forwardedPost) || other.forwardedPost == forwardedPost)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.actorid, actorid) || other.actorid == actorid)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.fediverseUri, fediverseUri) || other.fediverseUri == fediverseUri)&&(identical(other.fediverseType, fediverseType) || other.fediverseType == fediverseType)&&(identical(other.isCached, isCached) || other.isCached == isCached)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&const DeepCollectionEquality().equals(other.reactionsCount, reactionsCount)&&const DeepCollectionEquality().equals(other.reactionsMade, reactionsMade)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.collections, collections)&&const DeepCollectionEquality().equals(other.publisherCollections, publisherCollections)&&const DeepCollectionEquality().equals(other.featuredRecords, featuredRecords)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.repliedGone, repliedGone) || other.repliedGone == repliedGone)&&(identical(other.forwardedGone, forwardedGone) || other.forwardedGone == forwardedGone)&&(identical(other.isTruncated, isTruncated) || other.isTruncated == isTruncated)&&(identical(other.boostedBy, boostedBy) || other.boostedBy == boostedBy)&&(identical(other.boostedAt, boostedAt) || other.boostedAt == boostedAt)&&(identical(other.isBookmarked, isBookmarked) || other.isBookmarked == isBookmarked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,language,editedAt,draftedAt,publishedAt,visibility,content,slug,type,const DeepCollectionEquality().hash(meta),embedView,viewsUnique,viewsTotal,upvotes,downvotes,repliesCount,threadedRepliesCount,debugRank,awardedScore,pinMode,threadedPostId,threadedPost,repliedPostId,repliedPost,forwardedPostId,forwardedPost,realmId,realm,publisherId,publisher,actorid,actor,fediverseUri,fediverseType,isCached,contentType,const DeepCollectionEquality().hash(attachments),const DeepCollectionEquality().hash(reactionsCount),const DeepCollectionEquality().hash(reactionsMade),const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(collections),const DeepCollectionEquality().hash(publisherCollections),const DeepCollectionEquality().hash(featuredRecords),createdAt,updatedAt,deletedAt,repliedGone,forwardedGone,isTruncated,boostedBy,boostedAt,isBookmarked]);

@override
String toString() {
  return 'SnPost(id: $id, title: $title, description: $description, language: $language, editedAt: $editedAt, draftedAt: $draftedAt, publishedAt: $publishedAt, visibility: $visibility, content: $content, slug: $slug, type: $type, meta: $meta, embedView: $embedView, viewsUnique: $viewsUnique, viewsTotal: $viewsTotal, upvotes: $upvotes, downvotes: $downvotes, repliesCount: $repliesCount, threadedRepliesCount: $threadedRepliesCount, debugRank: $debugRank, awardedScore: $awardedScore, pinMode: $pinMode, threadedPostId: $threadedPostId, threadedPost: $threadedPost, repliedPostId: $repliedPostId, repliedPost: $repliedPost, forwardedPostId: $forwardedPostId, forwardedPost: $forwardedPost, realmId: $realmId, realm: $realm, publisherId: $publisherId, publisher: $publisher, actorid: $actorid, actor: $actor, fediverseUri: $fediverseUri, fediverseType: $fediverseType, isCached: $isCached, contentType: $contentType, attachments: $attachments, reactionsCount: $reactionsCount, reactionsMade: $reactionsMade, reactions: $reactions, tags: $tags, categories: $categories, collections: $collections, publisherCollections: $publisherCollections, featuredRecords: $featuredRecords, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, repliedGone: $repliedGone, forwardedGone: $forwardedGone, isTruncated: $isTruncated, boostedBy: $boostedBy, boostedAt: $boostedAt, isBookmarked: $isBookmarked)';
}


}

/// @nodoc
abstract mixin class $SnPostCopyWith<$Res>  {
  factory $SnPostCopyWith(SnPost value, $Res Function(SnPost) _then) = _$SnPostCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? description, String? language, DateTime? editedAt, DateTime? draftedAt, DateTime? publishedAt, int visibility, String? content, String? slug, int type, Map<String, dynamic>? meta, SnPostEmbedView? embedView, int viewsUnique, int viewsTotal, int upvotes, int downvotes, int repliesCount, int threadedRepliesCount, double? debugRank, int awardedScore, int? pinMode, String? threadedPostId, SnPost? threadedPost, String? repliedPostId, SnPost? repliedPost, String? forwardedPostId, SnPost? forwardedPost, String? realmId, SnRealm? realm, String? publisherId, SnPublisher? publisher, String? actorid, SnActivityPubActor? actor, String? fediverseUri, int? fediverseType, bool isCached, int contentType, List<SnCloudFileReference> attachments, Map<String, int> reactionsCount, Map<String, bool> reactionsMade, List<dynamic> reactions, List<SnPostTag> tags, List<SnPostCategory> categories, List<dynamic> collections,@JsonKey(name: 'publisher_collections') List<SnPostCollection> publisherCollections, List<SnPostFeaturedRecord> featuredRecords, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, bool repliedGone, bool forwardedGone, bool isTruncated, SnActivityPubActor? boostedBy, DateTime? boostedAt, bool isBookmarked
});


$SnPostEmbedViewCopyWith<$Res>? get embedView;$SnPostCopyWith<$Res>? get threadedPost;$SnPostCopyWith<$Res>? get repliedPost;$SnPostCopyWith<$Res>? get forwardedPost;$SnRealmCopyWith<$Res>? get realm;$SnPublisherCopyWith<$Res>? get publisher;$SnActivityPubActorCopyWith<$Res>? get actor;$SnActivityPubActorCopyWith<$Res>? get boostedBy;

}
/// @nodoc
class _$SnPostCopyWithImpl<$Res>
    implements $SnPostCopyWith<$Res> {
  _$SnPostCopyWithImpl(this._self, this._then);

  final SnPost _self;
  final $Res Function(SnPost) _then;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? language = freezed,Object? editedAt = freezed,Object? draftedAt = freezed,Object? publishedAt = freezed,Object? visibility = null,Object? content = freezed,Object? slug = freezed,Object? type = null,Object? meta = freezed,Object? embedView = freezed,Object? viewsUnique = null,Object? viewsTotal = null,Object? upvotes = null,Object? downvotes = null,Object? repliesCount = null,Object? threadedRepliesCount = null,Object? debugRank = freezed,Object? awardedScore = null,Object? pinMode = freezed,Object? threadedPostId = freezed,Object? threadedPost = freezed,Object? repliedPostId = freezed,Object? repliedPost = freezed,Object? forwardedPostId = freezed,Object? forwardedPost = freezed,Object? realmId = freezed,Object? realm = freezed,Object? publisherId = freezed,Object? publisher = freezed,Object? actorid = freezed,Object? actor = freezed,Object? fediverseUri = freezed,Object? fediverseType = freezed,Object? isCached = null,Object? contentType = null,Object? attachments = null,Object? reactionsCount = null,Object? reactionsMade = null,Object? reactions = null,Object? tags = null,Object? categories = null,Object? collections = null,Object? publisherCollections = null,Object? featuredRecords = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? repliedGone = null,Object? forwardedGone = null,Object? isTruncated = null,Object? boostedBy = freezed,Object? boostedAt = freezed,Object? isBookmarked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,draftedAt: freezed == draftedAt ? _self.draftedAt : draftedAt // ignore: cast_nullable_to_non_nullable
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
as int,threadedRepliesCount: null == threadedRepliesCount ? _self.threadedRepliesCount : threadedRepliesCount // ignore: cast_nullable_to_non_nullable
as int,debugRank: freezed == debugRank ? _self.debugRank : debugRank // ignore: cast_nullable_to_non_nullable
as double?,awardedScore: null == awardedScore ? _self.awardedScore : awardedScore // ignore: cast_nullable_to_non_nullable
as int,pinMode: freezed == pinMode ? _self.pinMode : pinMode // ignore: cast_nullable_to_non_nullable
as int?,threadedPostId: freezed == threadedPostId ? _self.threadedPostId : threadedPostId // ignore: cast_nullable_to_non_nullable
as String?,threadedPost: freezed == threadedPost ? _self.threadedPost : threadedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,repliedPostId: freezed == repliedPostId ? _self.repliedPostId : repliedPostId // ignore: cast_nullable_to_non_nullable
as String?,repliedPost: freezed == repliedPost ? _self.repliedPost : repliedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,forwardedPostId: freezed == forwardedPostId ? _self.forwardedPostId : forwardedPostId // ignore: cast_nullable_to_non_nullable
as String?,forwardedPost: freezed == forwardedPost ? _self.forwardedPost : forwardedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,publisherId: freezed == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,actorid: freezed == actorid ? _self.actorid : actorid // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as SnActivityPubActor?,fediverseUri: freezed == fediverseUri ? _self.fediverseUri : fediverseUri // ignore: cast_nullable_to_non_nullable
as String?,fediverseType: freezed == fediverseType ? _self.fediverseType : fediverseType // ignore: cast_nullable_to_non_nullable
as int?,isCached: null == isCached ? _self.isCached : isCached // ignore: cast_nullable_to_non_nullable
as bool,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as int,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,reactionsCount: null == reactionsCount ? _self.reactionsCount : reactionsCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,reactionsMade: null == reactionsMade ? _self.reactionsMade : reactionsMade // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<SnPostTag>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<SnPostCategory>,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<dynamic>,publisherCollections: null == publisherCollections ? _self.publisherCollections : publisherCollections // ignore: cast_nullable_to_non_nullable
as List<SnPostCollection>,featuredRecords: null == featuredRecords ? _self.featuredRecords : featuredRecords // ignore: cast_nullable_to_non_nullable
as List<SnPostFeaturedRecord>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,repliedGone: null == repliedGone ? _self.repliedGone : repliedGone // ignore: cast_nullable_to_non_nullable
as bool,forwardedGone: null == forwardedGone ? _self.forwardedGone : forwardedGone // ignore: cast_nullable_to_non_nullable
as bool,isTruncated: null == isTruncated ? _self.isTruncated : isTruncated // ignore: cast_nullable_to_non_nullable
as bool,boostedBy: freezed == boostedBy ? _self.boostedBy : boostedBy // ignore: cast_nullable_to_non_nullable
as SnActivityPubActor?,boostedAt: freezed == boostedAt ? _self.boostedAt : boostedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
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
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $SnActivityPubActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<$Res>? get boostedBy {
    if (_self.boostedBy == null) {
    return null;
  }

  return $SnActivityPubActorCopyWith<$Res>(_self.boostedBy!, (value) {
    return _then(_self.copyWith(boostedBy: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? draftedAt,  DateTime? publishedAt,  int visibility,  String? content,  String? slug,  int type,  Map<String, dynamic>? meta,  SnPostEmbedView? embedView,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  int threadedRepliesCount,  double? debugRank,  int awardedScore,  int? pinMode,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  String? publisherId,  SnPublisher? publisher,  String? actorid,  SnActivityPubActor? actor,  String? fediverseUri,  int? fediverseType,  bool isCached,  int contentType,  List<SnCloudFileReference> attachments,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections, @JsonKey(name: 'publisher_collections')  List<SnPostCollection> publisherCollections,  List<SnPostFeaturedRecord> featuredRecords,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool repliedGone,  bool forwardedGone,  bool isTruncated,  SnActivityPubActor? boostedBy,  DateTime? boostedAt,  bool isBookmarked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPost() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.draftedAt,_that.publishedAt,_that.visibility,_that.content,_that.slug,_that.type,_that.meta,_that.embedView,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.threadedRepliesCount,_that.debugRank,_that.awardedScore,_that.pinMode,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.publisherId,_that.publisher,_that.actorid,_that.actor,_that.fediverseUri,_that.fediverseType,_that.isCached,_that.contentType,_that.attachments,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.publisherCollections,_that.featuredRecords,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.repliedGone,_that.forwardedGone,_that.isTruncated,_that.boostedBy,_that.boostedAt,_that.isBookmarked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? draftedAt,  DateTime? publishedAt,  int visibility,  String? content,  String? slug,  int type,  Map<String, dynamic>? meta,  SnPostEmbedView? embedView,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  int threadedRepliesCount,  double? debugRank,  int awardedScore,  int? pinMode,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  String? publisherId,  SnPublisher? publisher,  String? actorid,  SnActivityPubActor? actor,  String? fediverseUri,  int? fediverseType,  bool isCached,  int contentType,  List<SnCloudFileReference> attachments,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections, @JsonKey(name: 'publisher_collections')  List<SnPostCollection> publisherCollections,  List<SnPostFeaturedRecord> featuredRecords,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool repliedGone,  bool forwardedGone,  bool isTruncated,  SnActivityPubActor? boostedBy,  DateTime? boostedAt,  bool isBookmarked)  $default,) {final _that = this;
switch (_that) {
case _SnPost():
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.draftedAt,_that.publishedAt,_that.visibility,_that.content,_that.slug,_that.type,_that.meta,_that.embedView,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.threadedRepliesCount,_that.debugRank,_that.awardedScore,_that.pinMode,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.publisherId,_that.publisher,_that.actorid,_that.actor,_that.fediverseUri,_that.fediverseType,_that.isCached,_that.contentType,_that.attachments,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.publisherCollections,_that.featuredRecords,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.repliedGone,_that.forwardedGone,_that.isTruncated,_that.boostedBy,_that.boostedAt,_that.isBookmarked);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? description,  String? language,  DateTime? editedAt,  DateTime? draftedAt,  DateTime? publishedAt,  int visibility,  String? content,  String? slug,  int type,  Map<String, dynamic>? meta,  SnPostEmbedView? embedView,  int viewsUnique,  int viewsTotal,  int upvotes,  int downvotes,  int repliesCount,  int threadedRepliesCount,  double? debugRank,  int awardedScore,  int? pinMode,  String? threadedPostId,  SnPost? threadedPost,  String? repliedPostId,  SnPost? repliedPost,  String? forwardedPostId,  SnPost? forwardedPost,  String? realmId,  SnRealm? realm,  String? publisherId,  SnPublisher? publisher,  String? actorid,  SnActivityPubActor? actor,  String? fediverseUri,  int? fediverseType,  bool isCached,  int contentType,  List<SnCloudFileReference> attachments,  Map<String, int> reactionsCount,  Map<String, bool> reactionsMade,  List<dynamic> reactions,  List<SnPostTag> tags,  List<SnPostCategory> categories,  List<dynamic> collections, @JsonKey(name: 'publisher_collections')  List<SnPostCollection> publisherCollections,  List<SnPostFeaturedRecord> featuredRecords,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  bool repliedGone,  bool forwardedGone,  bool isTruncated,  SnActivityPubActor? boostedBy,  DateTime? boostedAt,  bool isBookmarked)?  $default,) {final _that = this;
switch (_that) {
case _SnPost() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.language,_that.editedAt,_that.draftedAt,_that.publishedAt,_that.visibility,_that.content,_that.slug,_that.type,_that.meta,_that.embedView,_that.viewsUnique,_that.viewsTotal,_that.upvotes,_that.downvotes,_that.repliesCount,_that.threadedRepliesCount,_that.debugRank,_that.awardedScore,_that.pinMode,_that.threadedPostId,_that.threadedPost,_that.repliedPostId,_that.repliedPost,_that.forwardedPostId,_that.forwardedPost,_that.realmId,_that.realm,_that.publisherId,_that.publisher,_that.actorid,_that.actor,_that.fediverseUri,_that.fediverseType,_that.isCached,_that.contentType,_that.attachments,_that.reactionsCount,_that.reactionsMade,_that.reactions,_that.tags,_that.categories,_that.collections,_that.publisherCollections,_that.featuredRecords,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.repliedGone,_that.forwardedGone,_that.isTruncated,_that.boostedBy,_that.boostedAt,_that.isBookmarked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPost implements SnPost {
  const _SnPost({required this.id, this.title, this.description, this.language, this.editedAt, this.draftedAt = null, this.publishedAt = null, this.visibility = 0, this.content, this.slug, this.type = 0, final  Map<String, dynamic>? meta, this.embedView, this.viewsUnique = 0, this.viewsTotal = 0, this.upvotes = 0, this.downvotes = 0, this.repliesCount = 0, this.threadedRepliesCount = 0, this.debugRank, this.awardedScore = 0, this.pinMode, this.threadedPostId, this.threadedPost, this.repliedPostId, this.repliedPost, this.forwardedPostId, this.forwardedPost, this.realmId, this.realm, this.publisherId, this.publisher, this.actorid, this.actor, this.fediverseUri, this.fediverseType, this.isCached = true, this.contentType = 0, final  List<SnCloudFileReference> attachments = const [], final  Map<String, int> reactionsCount = const {}, final  Map<String, bool> reactionsMade = const {}, final  List<dynamic> reactions = const [], final  List<SnPostTag> tags = const [], final  List<SnPostCategory> categories = const [], final  List<dynamic> collections = const [], @JsonKey(name: 'publisher_collections') final  List<SnPostCollection> publisherCollections = const [], final  List<SnPostFeaturedRecord> featuredRecords = const [], this.createdAt = null, this.updatedAt = null, this.deletedAt, this.repliedGone = false, this.forwardedGone = false, this.isTruncated = false, this.boostedBy = null, this.boostedAt = null, this.isBookmarked = false}): _meta = meta,_attachments = attachments,_reactionsCount = reactionsCount,_reactionsMade = reactionsMade,_reactions = reactions,_tags = tags,_categories = categories,_collections = collections,_publisherCollections = publisherCollections,_featuredRecords = featuredRecords;
  factory _SnPost.fromJson(Map<String, dynamic> json) => _$SnPostFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? description;
@override final  String? language;
@override final  DateTime? editedAt;
@override@JsonKey() final  DateTime? draftedAt;
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
@override@JsonKey() final  int threadedRepliesCount;
@override final  double? debugRank;
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
@override final  String? publisherId;
@override final  SnPublisher? publisher;
@override final  String? actorid;
@override final  SnActivityPubActor? actor;
@override final  String? fediverseUri;
@override final  int? fediverseType;
@override@JsonKey() final  bool isCached;
@override@JsonKey() final  int contentType;
 final  List<SnCloudFileReference> _attachments;
@override@JsonKey() List<SnCloudFileReference> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

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

// Legacy/unspecified collections field.
// Prefer using [publisherCollections] for post-collection integration.
 final  List<dynamic> _collections;
// Legacy/unspecified collections field.
// Prefer using [publisherCollections] for post-collection integration.
@override@JsonKey() List<dynamic> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

// Collections owned by the same publisher as the post.
// Wire format: `publisher_collections`.
 final  List<SnPostCollection> _publisherCollections;
// Collections owned by the same publisher as the post.
// Wire format: `publisher_collections`.
@override@JsonKey(name: 'publisher_collections') List<SnPostCollection> get publisherCollections {
  if (_publisherCollections is EqualUnmodifiableListView) return _publisherCollections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publisherCollections);
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
@override@JsonKey() final  bool repliedGone;
@override@JsonKey() final  bool forwardedGone;
@override@JsonKey() final  bool isTruncated;
@override@JsonKey() final  SnActivityPubActor? boostedBy;
@override@JsonKey() final  DateTime? boostedAt;
@override@JsonKey() final  bool isBookmarked;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.language, language) || other.language == language)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.draftedAt, draftedAt) || other.draftedAt == draftedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.content, content) || other.content == content)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.embedView, embedView) || other.embedView == embedView)&&(identical(other.viewsUnique, viewsUnique) || other.viewsUnique == viewsUnique)&&(identical(other.viewsTotal, viewsTotal) || other.viewsTotal == viewsTotal)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&(identical(other.repliesCount, repliesCount) || other.repliesCount == repliesCount)&&(identical(other.threadedRepliesCount, threadedRepliesCount) || other.threadedRepliesCount == threadedRepliesCount)&&(identical(other.debugRank, debugRank) || other.debugRank == debugRank)&&(identical(other.awardedScore, awardedScore) || other.awardedScore == awardedScore)&&(identical(other.pinMode, pinMode) || other.pinMode == pinMode)&&(identical(other.threadedPostId, threadedPostId) || other.threadedPostId == threadedPostId)&&(identical(other.threadedPost, threadedPost) || other.threadedPost == threadedPost)&&(identical(other.repliedPostId, repliedPostId) || other.repliedPostId == repliedPostId)&&(identical(other.repliedPost, repliedPost) || other.repliedPost == repliedPost)&&(identical(other.forwardedPostId, forwardedPostId) || other.forwardedPostId == forwardedPostId)&&(identical(other.forwardedPost, forwardedPost) || other.forwardedPost == forwardedPost)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.actorid, actorid) || other.actorid == actorid)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.fediverseUri, fediverseUri) || other.fediverseUri == fediverseUri)&&(identical(other.fediverseType, fediverseType) || other.fediverseType == fediverseType)&&(identical(other.isCached, isCached) || other.isCached == isCached)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&const DeepCollectionEquality().equals(other._reactionsCount, _reactionsCount)&&const DeepCollectionEquality().equals(other._reactionsMade, _reactionsMade)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._collections, _collections)&&const DeepCollectionEquality().equals(other._publisherCollections, _publisherCollections)&&const DeepCollectionEquality().equals(other._featuredRecords, _featuredRecords)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.repliedGone, repliedGone) || other.repliedGone == repliedGone)&&(identical(other.forwardedGone, forwardedGone) || other.forwardedGone == forwardedGone)&&(identical(other.isTruncated, isTruncated) || other.isTruncated == isTruncated)&&(identical(other.boostedBy, boostedBy) || other.boostedBy == boostedBy)&&(identical(other.boostedAt, boostedAt) || other.boostedAt == boostedAt)&&(identical(other.isBookmarked, isBookmarked) || other.isBookmarked == isBookmarked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,language,editedAt,draftedAt,publishedAt,visibility,content,slug,type,const DeepCollectionEquality().hash(_meta),embedView,viewsUnique,viewsTotal,upvotes,downvotes,repliesCount,threadedRepliesCount,debugRank,awardedScore,pinMode,threadedPostId,threadedPost,repliedPostId,repliedPost,forwardedPostId,forwardedPost,realmId,realm,publisherId,publisher,actorid,actor,fediverseUri,fediverseType,isCached,contentType,const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_reactionsCount),const DeepCollectionEquality().hash(_reactionsMade),const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_collections),const DeepCollectionEquality().hash(_publisherCollections),const DeepCollectionEquality().hash(_featuredRecords),createdAt,updatedAt,deletedAt,repliedGone,forwardedGone,isTruncated,boostedBy,boostedAt,isBookmarked]);

@override
String toString() {
  return 'SnPost(id: $id, title: $title, description: $description, language: $language, editedAt: $editedAt, draftedAt: $draftedAt, publishedAt: $publishedAt, visibility: $visibility, content: $content, slug: $slug, type: $type, meta: $meta, embedView: $embedView, viewsUnique: $viewsUnique, viewsTotal: $viewsTotal, upvotes: $upvotes, downvotes: $downvotes, repliesCount: $repliesCount, threadedRepliesCount: $threadedRepliesCount, debugRank: $debugRank, awardedScore: $awardedScore, pinMode: $pinMode, threadedPostId: $threadedPostId, threadedPost: $threadedPost, repliedPostId: $repliedPostId, repliedPost: $repliedPost, forwardedPostId: $forwardedPostId, forwardedPost: $forwardedPost, realmId: $realmId, realm: $realm, publisherId: $publisherId, publisher: $publisher, actorid: $actorid, actor: $actor, fediverseUri: $fediverseUri, fediverseType: $fediverseType, isCached: $isCached, contentType: $contentType, attachments: $attachments, reactionsCount: $reactionsCount, reactionsMade: $reactionsMade, reactions: $reactions, tags: $tags, categories: $categories, collections: $collections, publisherCollections: $publisherCollections, featuredRecords: $featuredRecords, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, repliedGone: $repliedGone, forwardedGone: $forwardedGone, isTruncated: $isTruncated, boostedBy: $boostedBy, boostedAt: $boostedAt, isBookmarked: $isBookmarked)';
}


}

/// @nodoc
abstract mixin class _$SnPostCopyWith<$Res> implements $SnPostCopyWith<$Res> {
  factory _$SnPostCopyWith(_SnPost value, $Res Function(_SnPost) _then) = __$SnPostCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? description, String? language, DateTime? editedAt, DateTime? draftedAt, DateTime? publishedAt, int visibility, String? content, String? slug, int type, Map<String, dynamic>? meta, SnPostEmbedView? embedView, int viewsUnique, int viewsTotal, int upvotes, int downvotes, int repliesCount, int threadedRepliesCount, double? debugRank, int awardedScore, int? pinMode, String? threadedPostId, SnPost? threadedPost, String? repliedPostId, SnPost? repliedPost, String? forwardedPostId, SnPost? forwardedPost, String? realmId, SnRealm? realm, String? publisherId, SnPublisher? publisher, String? actorid, SnActivityPubActor? actor, String? fediverseUri, int? fediverseType, bool isCached, int contentType, List<SnCloudFileReference> attachments, Map<String, int> reactionsCount, Map<String, bool> reactionsMade, List<dynamic> reactions, List<SnPostTag> tags, List<SnPostCategory> categories, List<dynamic> collections,@JsonKey(name: 'publisher_collections') List<SnPostCollection> publisherCollections, List<SnPostFeaturedRecord> featuredRecords, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, bool repliedGone, bool forwardedGone, bool isTruncated, SnActivityPubActor? boostedBy, DateTime? boostedAt, bool isBookmarked
});


@override $SnPostEmbedViewCopyWith<$Res>? get embedView;@override $SnPostCopyWith<$Res>? get threadedPost;@override $SnPostCopyWith<$Res>? get repliedPost;@override $SnPostCopyWith<$Res>? get forwardedPost;@override $SnRealmCopyWith<$Res>? get realm;@override $SnPublisherCopyWith<$Res>? get publisher;@override $SnActivityPubActorCopyWith<$Res>? get actor;@override $SnActivityPubActorCopyWith<$Res>? get boostedBy;

}
/// @nodoc
class __$SnPostCopyWithImpl<$Res>
    implements _$SnPostCopyWith<$Res> {
  __$SnPostCopyWithImpl(this._self, this._then);

  final _SnPost _self;
  final $Res Function(_SnPost) _then;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? language = freezed,Object? editedAt = freezed,Object? draftedAt = freezed,Object? publishedAt = freezed,Object? visibility = null,Object? content = freezed,Object? slug = freezed,Object? type = null,Object? meta = freezed,Object? embedView = freezed,Object? viewsUnique = null,Object? viewsTotal = null,Object? upvotes = null,Object? downvotes = null,Object? repliesCount = null,Object? threadedRepliesCount = null,Object? debugRank = freezed,Object? awardedScore = null,Object? pinMode = freezed,Object? threadedPostId = freezed,Object? threadedPost = freezed,Object? repliedPostId = freezed,Object? repliedPost = freezed,Object? forwardedPostId = freezed,Object? forwardedPost = freezed,Object? realmId = freezed,Object? realm = freezed,Object? publisherId = freezed,Object? publisher = freezed,Object? actorid = freezed,Object? actor = freezed,Object? fediverseUri = freezed,Object? fediverseType = freezed,Object? isCached = null,Object? contentType = null,Object? attachments = null,Object? reactionsCount = null,Object? reactionsMade = null,Object? reactions = null,Object? tags = null,Object? categories = null,Object? collections = null,Object? publisherCollections = null,Object? featuredRecords = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? repliedGone = null,Object? forwardedGone = null,Object? isTruncated = null,Object? boostedBy = freezed,Object? boostedAt = freezed,Object? isBookmarked = null,}) {
  return _then(_SnPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,draftedAt: freezed == draftedAt ? _self.draftedAt : draftedAt // ignore: cast_nullable_to_non_nullable
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
as int,threadedRepliesCount: null == threadedRepliesCount ? _self.threadedRepliesCount : threadedRepliesCount // ignore: cast_nullable_to_non_nullable
as int,debugRank: freezed == debugRank ? _self.debugRank : debugRank // ignore: cast_nullable_to_non_nullable
as double?,awardedScore: null == awardedScore ? _self.awardedScore : awardedScore // ignore: cast_nullable_to_non_nullable
as int,pinMode: freezed == pinMode ? _self.pinMode : pinMode // ignore: cast_nullable_to_non_nullable
as int?,threadedPostId: freezed == threadedPostId ? _self.threadedPostId : threadedPostId // ignore: cast_nullable_to_non_nullable
as String?,threadedPost: freezed == threadedPost ? _self.threadedPost : threadedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,repliedPostId: freezed == repliedPostId ? _self.repliedPostId : repliedPostId // ignore: cast_nullable_to_non_nullable
as String?,repliedPost: freezed == repliedPost ? _self.repliedPost : repliedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,forwardedPostId: freezed == forwardedPostId ? _self.forwardedPostId : forwardedPostId // ignore: cast_nullable_to_non_nullable
as String?,forwardedPost: freezed == forwardedPost ? _self.forwardedPost : forwardedPost // ignore: cast_nullable_to_non_nullable
as SnPost?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,publisherId: freezed == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,actorid: freezed == actorid ? _self.actorid : actorid // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as SnActivityPubActor?,fediverseUri: freezed == fediverseUri ? _self.fediverseUri : fediverseUri // ignore: cast_nullable_to_non_nullable
as String?,fediverseType: freezed == fediverseType ? _self.fediverseType : fediverseType // ignore: cast_nullable_to_non_nullable
as int?,isCached: null == isCached ? _self.isCached : isCached // ignore: cast_nullable_to_non_nullable
as bool,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as int,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,reactionsCount: null == reactionsCount ? _self._reactionsCount : reactionsCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,reactionsMade: null == reactionsMade ? _self._reactionsMade : reactionsMade // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<SnPostTag>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<SnPostCategory>,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<dynamic>,publisherCollections: null == publisherCollections ? _self._publisherCollections : publisherCollections // ignore: cast_nullable_to_non_nullable
as List<SnPostCollection>,featuredRecords: null == featuredRecords ? _self._featuredRecords : featuredRecords // ignore: cast_nullable_to_non_nullable
as List<SnPostFeaturedRecord>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,repliedGone: null == repliedGone ? _self.repliedGone : repliedGone // ignore: cast_nullable_to_non_nullable
as bool,forwardedGone: null == forwardedGone ? _self.forwardedGone : forwardedGone // ignore: cast_nullable_to_non_nullable
as bool,isTruncated: null == isTruncated ? _self.isTruncated : isTruncated // ignore: cast_nullable_to_non_nullable
as bool,boostedBy: freezed == boostedBy ? _self.boostedBy : boostedBy // ignore: cast_nullable_to_non_nullable
as SnActivityPubActor?,boostedAt: freezed == boostedAt ? _self.boostedAt : boostedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
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
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $SnActivityPubActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<$Res>? get boostedBy {
    if (_self.boostedBy == null) {
    return null;
  }

  return $SnActivityPubActorCopyWith<$Res>(_self.boostedBy!, (value) {
    return _then(_self.copyWith(boostedBy: value));
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
mixin _$SnPublisherSubscriptionCompact {

 String get accountId; String get publisherId; SnPublisher get publisher;
/// Create a copy of SnPublisherSubscriptionCompact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionCompactCopyWith<SnPublisherSubscriptionCompact> get copyWith => _$SnPublisherSubscriptionCompactCopyWithImpl<SnPublisherSubscriptionCompact>(this as SnPublisherSubscriptionCompact, _$identity);

  /// Serializes this SnPublisherSubscriptionCompact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherSubscriptionCompact&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,publisherId,publisher);

@override
String toString() {
  return 'SnPublisherSubscriptionCompact(accountId: $accountId, publisherId: $publisherId, publisher: $publisher)';
}


}

/// @nodoc
abstract mixin class $SnPublisherSubscriptionCompactCopyWith<$Res>  {
  factory $SnPublisherSubscriptionCompactCopyWith(SnPublisherSubscriptionCompact value, $Res Function(SnPublisherSubscriptionCompact) _then) = _$SnPublisherSubscriptionCompactCopyWithImpl;
@useResult
$Res call({
 String accountId, String publisherId, SnPublisher publisher
});


$SnPublisherCopyWith<$Res> get publisher;

}
/// @nodoc
class _$SnPublisherSubscriptionCompactCopyWithImpl<$Res>
    implements $SnPublisherSubscriptionCompactCopyWith<$Res> {
  _$SnPublisherSubscriptionCompactCopyWithImpl(this._self, this._then);

  final SnPublisherSubscriptionCompact _self;
  final $Res Function(SnPublisherSubscriptionCompact) _then;

/// Create a copy of SnPublisherSubscriptionCompact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? publisherId = null,Object? publisher = null,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher,
  ));
}
/// Create a copy of SnPublisherSubscriptionCompact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res> get publisher {
  
  return $SnPublisherCopyWith<$Res>(_self.publisher, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherSubscriptionCompact].
extension SnPublisherSubscriptionCompactPatterns on SnPublisherSubscriptionCompact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionCompact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionCompact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionCompact value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionCompact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherSubscriptionCompact value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionCompact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  String publisherId,  SnPublisher publisher)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionCompact() when $default != null:
return $default(_that.accountId,_that.publisherId,_that.publisher);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  String publisherId,  SnPublisher publisher)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionCompact():
return $default(_that.accountId,_that.publisherId,_that.publisher);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  String publisherId,  SnPublisher publisher)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionCompact() when $default != null:
return $default(_that.accountId,_that.publisherId,_that.publisher);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherSubscriptionCompact implements SnPublisherSubscriptionCompact {
  const _SnPublisherSubscriptionCompact({required this.accountId, required this.publisherId, required this.publisher});
  factory _SnPublisherSubscriptionCompact.fromJson(Map<String, dynamic> json) => _$SnPublisherSubscriptionCompactFromJson(json);

@override final  String accountId;
@override final  String publisherId;
@override final  SnPublisher publisher;

/// Create a copy of SnPublisherSubscriptionCompact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherSubscriptionCompactCopyWith<_SnPublisherSubscriptionCompact> get copyWith => __$SnPublisherSubscriptionCompactCopyWithImpl<_SnPublisherSubscriptionCompact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherSubscriptionCompactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherSubscriptionCompact&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,publisherId,publisher);

@override
String toString() {
  return 'SnPublisherSubscriptionCompact(accountId: $accountId, publisherId: $publisherId, publisher: $publisher)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherSubscriptionCompactCopyWith<$Res> implements $SnPublisherSubscriptionCompactCopyWith<$Res> {
  factory _$SnPublisherSubscriptionCompactCopyWith(_SnPublisherSubscriptionCompact value, $Res Function(_SnPublisherSubscriptionCompact) _then) = __$SnPublisherSubscriptionCompactCopyWithImpl;
@override @useResult
$Res call({
 String accountId, String publisherId, SnPublisher publisher
});


@override $SnPublisherCopyWith<$Res> get publisher;

}
/// @nodoc
class __$SnPublisherSubscriptionCompactCopyWithImpl<$Res>
    implements _$SnPublisherSubscriptionCompactCopyWith<$Res> {
  __$SnPublisherSubscriptionCompactCopyWithImpl(this._self, this._then);

  final _SnPublisherSubscriptionCompact _self;
  final $Res Function(_SnPublisherSubscriptionCompact) _then;

/// Create a copy of SnPublisherSubscriptionCompact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? publisherId = null,Object? publisher = null,}) {
  return _then(_SnPublisherSubscriptionCompact(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher,
  ));
}

/// Create a copy of SnPublisherSubscriptionCompact
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

 String get id; String get symbol; int get attitude; String get postId; DateTime get createdAt; DateTime get updatedAt; String? get actorId; SnActivityPubActor? get actor; String? get accountId; SnAccount? get account; bool? get isLocal; String? get fediverseUri; DateTime? get deletedAt;
/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostReactionCopyWith<SnPostReaction> get copyWith => _$SnPostReactionCopyWithImpl<SnPostReaction>(this as SnPostReaction, _$identity);

  /// Serializes this SnPostReaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostReaction&&(identical(other.id, id) || other.id == id)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.isLocal, isLocal) || other.isLocal == isLocal)&&(identical(other.fediverseUri, fediverseUri) || other.fediverseUri == fediverseUri)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,symbol,attitude,postId,createdAt,updatedAt,actorId,actor,accountId,account,isLocal,fediverseUri,deletedAt);

@override
String toString() {
  return 'SnPostReaction(id: $id, symbol: $symbol, attitude: $attitude, postId: $postId, createdAt: $createdAt, updatedAt: $updatedAt, actorId: $actorId, actor: $actor, accountId: $accountId, account: $account, isLocal: $isLocal, fediverseUri: $fediverseUri, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPostReactionCopyWith<$Res>  {
  factory $SnPostReactionCopyWith(SnPostReaction value, $Res Function(SnPostReaction) _then) = _$SnPostReactionCopyWithImpl;
@useResult
$Res call({
 String id, String symbol, int attitude, String postId, DateTime createdAt, DateTime updatedAt, String? actorId, SnActivityPubActor? actor, String? accountId, SnAccount? account, bool? isLocal, String? fediverseUri, DateTime? deletedAt
});


$SnActivityPubActorCopyWith<$Res>? get actor;$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnPostReactionCopyWithImpl<$Res>
    implements $SnPostReactionCopyWith<$Res> {
  _$SnPostReactionCopyWithImpl(this._self, this._then);

  final SnPostReaction _self;
  final $Res Function(SnPostReaction) _then;

/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? symbol = null,Object? attitude = null,Object? postId = null,Object? createdAt = null,Object? updatedAt = null,Object? actorId = freezed,Object? actor = freezed,Object? accountId = freezed,Object? account = freezed,Object? isLocal = freezed,Object? fediverseUri = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as SnActivityPubActor?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,isLocal: freezed == isLocal ? _self.isLocal : isLocal // ignore: cast_nullable_to_non_nullable
as bool?,fediverseUri: freezed == fediverseUri ? _self.fediverseUri : fediverseUri // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $SnActivityPubActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}/// Create a copy of SnPostReaction
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String symbol,  int attitude,  String postId,  DateTime createdAt,  DateTime updatedAt,  String? actorId,  SnActivityPubActor? actor,  String? accountId,  SnAccount? account,  bool? isLocal,  String? fediverseUri,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostReaction() when $default != null:
return $default(_that.id,_that.symbol,_that.attitude,_that.postId,_that.createdAt,_that.updatedAt,_that.actorId,_that.actor,_that.accountId,_that.account,_that.isLocal,_that.fediverseUri,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String symbol,  int attitude,  String postId,  DateTime createdAt,  DateTime updatedAt,  String? actorId,  SnActivityPubActor? actor,  String? accountId,  SnAccount? account,  bool? isLocal,  String? fediverseUri,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPostReaction():
return $default(_that.id,_that.symbol,_that.attitude,_that.postId,_that.createdAt,_that.updatedAt,_that.actorId,_that.actor,_that.accountId,_that.account,_that.isLocal,_that.fediverseUri,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String symbol,  int attitude,  String postId,  DateTime createdAt,  DateTime updatedAt,  String? actorId,  SnActivityPubActor? actor,  String? accountId,  SnAccount? account,  bool? isLocal,  String? fediverseUri,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPostReaction() when $default != null:
return $default(_that.id,_that.symbol,_that.attitude,_that.postId,_that.createdAt,_that.updatedAt,_that.actorId,_that.actor,_that.accountId,_that.account,_that.isLocal,_that.fediverseUri,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostReaction implements SnPostReaction {
  const _SnPostReaction({required this.id, required this.symbol, required this.attitude, required this.postId, required this.createdAt, required this.updatedAt, this.actorId, this.actor, this.accountId, this.account, this.isLocal, this.fediverseUri, this.deletedAt});
  factory _SnPostReaction.fromJson(Map<String, dynamic> json) => _$SnPostReactionFromJson(json);

@override final  String id;
@override final  String symbol;
@override final  int attitude;
@override final  String postId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? actorId;
@override final  SnActivityPubActor? actor;
@override final  String? accountId;
@override final  SnAccount? account;
@override final  bool? isLocal;
@override final  String? fediverseUri;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostReaction&&(identical(other.id, id) || other.id == id)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.isLocal, isLocal) || other.isLocal == isLocal)&&(identical(other.fediverseUri, fediverseUri) || other.fediverseUri == fediverseUri)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,symbol,attitude,postId,createdAt,updatedAt,actorId,actor,accountId,account,isLocal,fediverseUri,deletedAt);

@override
String toString() {
  return 'SnPostReaction(id: $id, symbol: $symbol, attitude: $attitude, postId: $postId, createdAt: $createdAt, updatedAt: $updatedAt, actorId: $actorId, actor: $actor, accountId: $accountId, account: $account, isLocal: $isLocal, fediverseUri: $fediverseUri, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPostReactionCopyWith<$Res> implements $SnPostReactionCopyWith<$Res> {
  factory _$SnPostReactionCopyWith(_SnPostReaction value, $Res Function(_SnPostReaction) _then) = __$SnPostReactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String symbol, int attitude, String postId, DateTime createdAt, DateTime updatedAt, String? actorId, SnActivityPubActor? actor, String? accountId, SnAccount? account, bool? isLocal, String? fediverseUri, DateTime? deletedAt
});


@override $SnActivityPubActorCopyWith<$Res>? get actor;@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnPostReactionCopyWithImpl<$Res>
    implements _$SnPostReactionCopyWith<$Res> {
  __$SnPostReactionCopyWithImpl(this._self, this._then);

  final _SnPostReaction _self;
  final $Res Function(_SnPostReaction) _then;

/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? symbol = null,Object? attitude = null,Object? postId = null,Object? createdAt = null,Object? updatedAt = null,Object? actorId = freezed,Object? actor = freezed,Object? accountId = freezed,Object? account = freezed,Object? isLocal = freezed,Object? fediverseUri = freezed,Object? deletedAt = freezed,}) {
  return _then(_SnPostReaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as SnActivityPubActor?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,isLocal: freezed == isLocal ? _self.isLocal : isLocal // ignore: cast_nullable_to_non_nullable
as bool?,fediverseUri: freezed == fediverseUri ? _self.fediverseUri : fediverseUri // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPostReaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $SnActivityPubActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}/// Create a copy of SnPostReaction
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
mixin _$SnPostBookmark {

 String get id; String get postId; String get accountId; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of SnPostBookmark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostBookmarkCopyWith<SnPostBookmark> get copyWith => _$SnPostBookmarkCopyWithImpl<SnPostBookmark>(this as SnPostBookmark, _$identity);

  /// Serializes this SnPostBookmark to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostBookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,accountId,createdAt,updatedAt);

@override
String toString() {
  return 'SnPostBookmark(id: $id, postId: $postId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnPostBookmarkCopyWith<$Res>  {
  factory $SnPostBookmarkCopyWith(SnPostBookmark value, $Res Function(SnPostBookmark) _then) = _$SnPostBookmarkCopyWithImpl;
@useResult
$Res call({
 String id, String postId, String accountId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$SnPostBookmarkCopyWithImpl<$Res>
    implements $SnPostBookmarkCopyWith<$Res> {
  _$SnPostBookmarkCopyWithImpl(this._self, this._then);

  final SnPostBookmark _self;
  final $Res Function(SnPostBookmark) _then;

/// Create a copy of SnPostBookmark
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? accountId = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPostBookmark].
extension SnPostBookmarkPatterns on SnPostBookmark {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostBookmark value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostBookmark() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostBookmark value)  $default,){
final _that = this;
switch (_that) {
case _SnPostBookmark():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostBookmark value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostBookmark() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String postId,  String accountId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostBookmark() when $default != null:
return $default(_that.id,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String postId,  String accountId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPostBookmark():
return $default(_that.id,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String postId,  String accountId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPostBookmark() when $default != null:
return $default(_that.id,_that.postId,_that.accountId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostBookmark implements SnPostBookmark {
  const _SnPostBookmark({required this.id, required this.postId, required this.accountId, this.createdAt = null, this.updatedAt = null});
  factory _SnPostBookmark.fromJson(Map<String, dynamic> json) => _$SnPostBookmarkFromJson(json);

@override final  String id;
@override final  String postId;
@override final  String accountId;
@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey() final  DateTime? updatedAt;

/// Create a copy of SnPostBookmark
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostBookmarkCopyWith<_SnPostBookmark> get copyWith => __$SnPostBookmarkCopyWithImpl<_SnPostBookmark>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostBookmarkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostBookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,accountId,createdAt,updatedAt);

@override
String toString() {
  return 'SnPostBookmark(id: $id, postId: $postId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPostBookmarkCopyWith<$Res> implements $SnPostBookmarkCopyWith<$Res> {
  factory _$SnPostBookmarkCopyWith(_SnPostBookmark value, $Res Function(_SnPostBookmark) _then) = __$SnPostBookmarkCopyWithImpl;
@override @useResult
$Res call({
 String id, String postId, String accountId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$SnPostBookmarkCopyWithImpl<$Res>
    implements _$SnPostBookmarkCopyWith<$Res> {
  __$SnPostBookmarkCopyWithImpl(this._self, this._then);

  final _SnPostBookmark _self;
  final $Res Function(_SnPostBookmark) _then;

/// Create a copy of SnPostBookmark
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? accountId = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SnPostBookmark(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$UserReactionListingItem {

 SnPostReaction get reaction; SnPost get post;
/// Create a copy of UserReactionListingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReactionListingItemCopyWith<UserReactionListingItem> get copyWith => _$UserReactionListingItemCopyWithImpl<UserReactionListingItem>(this as UserReactionListingItem, _$identity);

  /// Serializes this UserReactionListingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserReactionListingItem&&(identical(other.reaction, reaction) || other.reaction == reaction)&&(identical(other.post, post) || other.post == post));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reaction,post);

@override
String toString() {
  return 'UserReactionListingItem(reaction: $reaction, post: $post)';
}


}

/// @nodoc
abstract mixin class $UserReactionListingItemCopyWith<$Res>  {
  factory $UserReactionListingItemCopyWith(UserReactionListingItem value, $Res Function(UserReactionListingItem) _then) = _$UserReactionListingItemCopyWithImpl;
@useResult
$Res call({
 SnPostReaction reaction, SnPost post
});


$SnPostReactionCopyWith<$Res> get reaction;$SnPostCopyWith<$Res> get post;

}
/// @nodoc
class _$UserReactionListingItemCopyWithImpl<$Res>
    implements $UserReactionListingItemCopyWith<$Res> {
  _$UserReactionListingItemCopyWithImpl(this._self, this._then);

  final UserReactionListingItem _self;
  final $Res Function(UserReactionListingItem) _then;

/// Create a copy of UserReactionListingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reaction = null,Object? post = null,}) {
  return _then(_self.copyWith(
reaction: null == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as SnPostReaction,post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as SnPost,
  ));
}
/// Create a copy of UserReactionListingItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostReactionCopyWith<$Res> get reaction {
  
  return $SnPostReactionCopyWith<$Res>(_self.reaction, (value) {
    return _then(_self.copyWith(reaction: value));
  });
}/// Create a copy of UserReactionListingItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res> get post {
  
  return $SnPostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserReactionListingItem].
extension UserReactionListingItemPatterns on UserReactionListingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserReactionListingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserReactionListingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserReactionListingItem value)  $default,){
final _that = this;
switch (_that) {
case _UserReactionListingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserReactionListingItem value)?  $default,){
final _that = this;
switch (_that) {
case _UserReactionListingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnPostReaction reaction,  SnPost post)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserReactionListingItem() when $default != null:
return $default(_that.reaction,_that.post);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnPostReaction reaction,  SnPost post)  $default,) {final _that = this;
switch (_that) {
case _UserReactionListingItem():
return $default(_that.reaction,_that.post);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnPostReaction reaction,  SnPost post)?  $default,) {final _that = this;
switch (_that) {
case _UserReactionListingItem() when $default != null:
return $default(_that.reaction,_that.post);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserReactionListingItem implements UserReactionListingItem {
  const _UserReactionListingItem({required this.reaction, required this.post});
  factory _UserReactionListingItem.fromJson(Map<String, dynamic> json) => _$UserReactionListingItemFromJson(json);

@override final  SnPostReaction reaction;
@override final  SnPost post;

/// Create a copy of UserReactionListingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReactionListingItemCopyWith<_UserReactionListingItem> get copyWith => __$UserReactionListingItemCopyWithImpl<_UserReactionListingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserReactionListingItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserReactionListingItem&&(identical(other.reaction, reaction) || other.reaction == reaction)&&(identical(other.post, post) || other.post == post));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reaction,post);

@override
String toString() {
  return 'UserReactionListingItem(reaction: $reaction, post: $post)';
}


}

/// @nodoc
abstract mixin class _$UserReactionListingItemCopyWith<$Res> implements $UserReactionListingItemCopyWith<$Res> {
  factory _$UserReactionListingItemCopyWith(_UserReactionListingItem value, $Res Function(_UserReactionListingItem) _then) = __$UserReactionListingItemCopyWithImpl;
@override @useResult
$Res call({
 SnPostReaction reaction, SnPost post
});


@override $SnPostReactionCopyWith<$Res> get reaction;@override $SnPostCopyWith<$Res> get post;

}
/// @nodoc
class __$UserReactionListingItemCopyWithImpl<$Res>
    implements _$UserReactionListingItemCopyWith<$Res> {
  __$UserReactionListingItemCopyWithImpl(this._self, this._then);

  final _UserReactionListingItem _self;
  final $Res Function(_UserReactionListingItem) _then;

/// Create a copy of UserReactionListingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reaction = null,Object? post = null,}) {
  return _then(_UserReactionListingItem(
reaction: null == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as SnPostReaction,post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as SnPost,
  ));
}

/// Create a copy of UserReactionListingItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostReactionCopyWith<$Res> get reaction {
  
  return $SnPostReactionCopyWith<$Res>(_self.reaction, (value) {
    return _then(_self.copyWith(reaction: value));
  });
}/// Create a copy of UserReactionListingItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCopyWith<$Res> get post {
  
  return $SnPostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
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
