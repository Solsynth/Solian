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

 int get id; String get title; String get description; dynamic get language; dynamic get editedAt; DateTime get publishedAt; int get visibility; String get content; int get type; Map<String, dynamic>? get meta; int get viewsUnique; int get viewsTotal; int get upvotes; int get downvotes; dynamic get threadedPostId; dynamic get threadedPost; dynamic get repliedPostId; dynamic get repliedPost; dynamic get forwardedPostId; dynamic get forwardedPost; List<SnCloudFile> get attachments; SnPublisher get publisher; List<dynamic> get reactions; List<dynamic> get tags; List<dynamic> get categories; List<dynamic> get collections; bool get empty; DateTime get createdAt; DateTime get updatedAt; dynamic get deletedAt;
/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostCopyWith<SnPost> get copyWith => _$SnPostCopyWithImpl<SnPost>(this as SnPost, _$identity);

  /// Serializes this SnPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.language, language)&&const DeepCollectionEquality().equals(other.editedAt, editedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.viewsUnique, viewsUnique) || other.viewsUnique == viewsUnique)&&(identical(other.viewsTotal, viewsTotal) || other.viewsTotal == viewsTotal)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&const DeepCollectionEquality().equals(other.threadedPostId, threadedPostId)&&const DeepCollectionEquality().equals(other.threadedPost, threadedPost)&&const DeepCollectionEquality().equals(other.repliedPostId, repliedPostId)&&const DeepCollectionEquality().equals(other.repliedPost, repliedPost)&&const DeepCollectionEquality().equals(other.forwardedPostId, forwardedPostId)&&const DeepCollectionEquality().equals(other.forwardedPost, forwardedPost)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.collections, collections)&&(identical(other.empty, empty) || other.empty == empty)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.deletedAt, deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,const DeepCollectionEquality().hash(language),const DeepCollectionEquality().hash(editedAt),publishedAt,visibility,content,type,const DeepCollectionEquality().hash(meta),viewsUnique,viewsTotal,upvotes,downvotes,const DeepCollectionEquality().hash(threadedPostId),const DeepCollectionEquality().hash(threadedPost),const DeepCollectionEquality().hash(repliedPostId),const DeepCollectionEquality().hash(repliedPost),const DeepCollectionEquality().hash(forwardedPostId),const DeepCollectionEquality().hash(forwardedPost),const DeepCollectionEquality().hash(attachments),publisher,const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(collections),empty,createdAt,updatedAt,const DeepCollectionEquality().hash(deletedAt)]);

@override
String toString() {
  return 'SnPost(id: $id, title: $title, description: $description, language: $language, editedAt: $editedAt, publishedAt: $publishedAt, visibility: $visibility, content: $content, type: $type, meta: $meta, viewsUnique: $viewsUnique, viewsTotal: $viewsTotal, upvotes: $upvotes, downvotes: $downvotes, threadedPostId: $threadedPostId, threadedPost: $threadedPost, repliedPostId: $repliedPostId, repliedPost: $repliedPost, forwardedPostId: $forwardedPostId, forwardedPost: $forwardedPost, attachments: $attachments, publisher: $publisher, reactions: $reactions, tags: $tags, categories: $categories, collections: $collections, empty: $empty, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPostCopyWith<$Res>  {
  factory $SnPostCopyWith(SnPost value, $Res Function(SnPost) _then) = _$SnPostCopyWithImpl;
@useResult
$Res call({
 int id, String title, String description, dynamic language, dynamic editedAt, DateTime publishedAt, int visibility, String content, int type, Map<String, dynamic>? meta, int viewsUnique, int viewsTotal, int upvotes, int downvotes, dynamic threadedPostId, dynamic threadedPost, dynamic repliedPostId, dynamic repliedPost, dynamic forwardedPostId, dynamic forwardedPost, List<SnCloudFile> attachments, SnPublisher publisher, List<dynamic> reactions, List<dynamic> tags, List<dynamic> categories, List<dynamic> collections, bool empty, DateTime createdAt, DateTime updatedAt, dynamic deletedAt
});


$SnPublisherCopyWith<$Res> get publisher;

}
/// @nodoc
class _$SnPostCopyWithImpl<$Res>
    implements $SnPostCopyWith<$Res> {
  _$SnPostCopyWithImpl(this._self, this._then);

  final SnPost _self;
  final $Res Function(SnPost) _then;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? language = freezed,Object? editedAt = freezed,Object? publishedAt = null,Object? visibility = null,Object? content = null,Object? type = null,Object? meta = freezed,Object? viewsUnique = null,Object? viewsTotal = null,Object? upvotes = null,Object? downvotes = null,Object? threadedPostId = freezed,Object? threadedPost = freezed,Object? repliedPostId = freezed,Object? repliedPost = freezed,Object? forwardedPostId = freezed,Object? forwardedPost = freezed,Object? attachments = null,Object? publisher = null,Object? reactions = null,Object? tags = null,Object? categories = null,Object? collections = null,Object? empty = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as dynamic,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as dynamic,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,viewsUnique: null == viewsUnique ? _self.viewsUnique : viewsUnique // ignore: cast_nullable_to_non_nullable
as int,viewsTotal: null == viewsTotal ? _self.viewsTotal : viewsTotal // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,threadedPostId: freezed == threadedPostId ? _self.threadedPostId : threadedPostId // ignore: cast_nullable_to_non_nullable
as dynamic,threadedPost: freezed == threadedPost ? _self.threadedPost : threadedPost // ignore: cast_nullable_to_non_nullable
as dynamic,repliedPostId: freezed == repliedPostId ? _self.repliedPostId : repliedPostId // ignore: cast_nullable_to_non_nullable
as dynamic,repliedPost: freezed == repliedPost ? _self.repliedPost : repliedPost // ignore: cast_nullable_to_non_nullable
as dynamic,forwardedPostId: freezed == forwardedPostId ? _self.forwardedPostId : forwardedPostId // ignore: cast_nullable_to_non_nullable
as dynamic,forwardedPost: freezed == forwardedPost ? _self.forwardedPost : forwardedPost // ignore: cast_nullable_to_non_nullable
as dynamic,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<dynamic>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<dynamic>,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<dynamic>,empty: null == empty ? _self.empty : empty // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
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
}


/// @nodoc
@JsonSerializable()

class _SnPost implements SnPost {
  const _SnPost({required this.id, required this.title, required this.description, required this.language, required this.editedAt, required this.publishedAt, required this.visibility, required this.content, required this.type, required final  Map<String, dynamic>? meta, required this.viewsUnique, required this.viewsTotal, required this.upvotes, required this.downvotes, required this.threadedPostId, required this.threadedPost, required this.repliedPostId, required this.repliedPost, required this.forwardedPostId, required this.forwardedPost, required final  List<SnCloudFile> attachments, required this.publisher, required final  List<dynamic> reactions, required final  List<dynamic> tags, required final  List<dynamic> categories, required final  List<dynamic> collections, required this.empty, required this.createdAt, required this.updatedAt, required this.deletedAt}): _meta = meta,_attachments = attachments,_reactions = reactions,_tags = tags,_categories = categories,_collections = collections;
  factory _SnPost.fromJson(Map<String, dynamic> json) => _$SnPostFromJson(json);

@override final  int id;
@override final  String title;
@override final  String description;
@override final  dynamic language;
@override final  dynamic editedAt;
@override final  DateTime publishedAt;
@override final  int visibility;
@override final  String content;
@override final  int type;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int viewsUnique;
@override final  int viewsTotal;
@override final  int upvotes;
@override final  int downvotes;
@override final  dynamic threadedPostId;
@override final  dynamic threadedPost;
@override final  dynamic repliedPostId;
@override final  dynamic repliedPost;
@override final  dynamic forwardedPostId;
@override final  dynamic forwardedPost;
 final  List<SnCloudFile> _attachments;
@override List<SnCloudFile> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  SnPublisher publisher;
 final  List<dynamic> _reactions;
@override List<dynamic> get reactions {
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactions);
}

 final  List<dynamic> _tags;
@override List<dynamic> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<dynamic> _categories;
@override List<dynamic> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<dynamic> _collections;
@override List<dynamic> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

@override final  bool empty;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  dynamic deletedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPost&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.language, language)&&const DeepCollectionEquality().equals(other.editedAt, editedAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.viewsUnique, viewsUnique) || other.viewsUnique == viewsUnique)&&(identical(other.viewsTotal, viewsTotal) || other.viewsTotal == viewsTotal)&&(identical(other.upvotes, upvotes) || other.upvotes == upvotes)&&(identical(other.downvotes, downvotes) || other.downvotes == downvotes)&&const DeepCollectionEquality().equals(other.threadedPostId, threadedPostId)&&const DeepCollectionEquality().equals(other.threadedPost, threadedPost)&&const DeepCollectionEquality().equals(other.repliedPostId, repliedPostId)&&const DeepCollectionEquality().equals(other.repliedPost, repliedPost)&&const DeepCollectionEquality().equals(other.forwardedPostId, forwardedPostId)&&const DeepCollectionEquality().equals(other.forwardedPost, forwardedPost)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._collections, _collections)&&(identical(other.empty, empty) || other.empty == empty)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.deletedAt, deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,const DeepCollectionEquality().hash(language),const DeepCollectionEquality().hash(editedAt),publishedAt,visibility,content,type,const DeepCollectionEquality().hash(_meta),viewsUnique,viewsTotal,upvotes,downvotes,const DeepCollectionEquality().hash(threadedPostId),const DeepCollectionEquality().hash(threadedPost),const DeepCollectionEquality().hash(repliedPostId),const DeepCollectionEquality().hash(repliedPost),const DeepCollectionEquality().hash(forwardedPostId),const DeepCollectionEquality().hash(forwardedPost),const DeepCollectionEquality().hash(_attachments),publisher,const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_collections),empty,createdAt,updatedAt,const DeepCollectionEquality().hash(deletedAt)]);

@override
String toString() {
  return 'SnPost(id: $id, title: $title, description: $description, language: $language, editedAt: $editedAt, publishedAt: $publishedAt, visibility: $visibility, content: $content, type: $type, meta: $meta, viewsUnique: $viewsUnique, viewsTotal: $viewsTotal, upvotes: $upvotes, downvotes: $downvotes, threadedPostId: $threadedPostId, threadedPost: $threadedPost, repliedPostId: $repliedPostId, repliedPost: $repliedPost, forwardedPostId: $forwardedPostId, forwardedPost: $forwardedPost, attachments: $attachments, publisher: $publisher, reactions: $reactions, tags: $tags, categories: $categories, collections: $collections, empty: $empty, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPostCopyWith<$Res> implements $SnPostCopyWith<$Res> {
  factory _$SnPostCopyWith(_SnPost value, $Res Function(_SnPost) _then) = __$SnPostCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String description, dynamic language, dynamic editedAt, DateTime publishedAt, int visibility, String content, int type, Map<String, dynamic>? meta, int viewsUnique, int viewsTotal, int upvotes, int downvotes, dynamic threadedPostId, dynamic threadedPost, dynamic repliedPostId, dynamic repliedPost, dynamic forwardedPostId, dynamic forwardedPost, List<SnCloudFile> attachments, SnPublisher publisher, List<dynamic> reactions, List<dynamic> tags, List<dynamic> categories, List<dynamic> collections, bool empty, DateTime createdAt, DateTime updatedAt, dynamic deletedAt
});


@override $SnPublisherCopyWith<$Res> get publisher;

}
/// @nodoc
class __$SnPostCopyWithImpl<$Res>
    implements _$SnPostCopyWith<$Res> {
  __$SnPostCopyWithImpl(this._self, this._then);

  final _SnPost _self;
  final $Res Function(_SnPost) _then;

/// Create a copy of SnPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? language = freezed,Object? editedAt = freezed,Object? publishedAt = null,Object? visibility = null,Object? content = null,Object? type = null,Object? meta = freezed,Object? viewsUnique = null,Object? viewsTotal = null,Object? upvotes = null,Object? downvotes = null,Object? threadedPostId = freezed,Object? threadedPost = freezed,Object? repliedPostId = freezed,Object? repliedPost = freezed,Object? forwardedPostId = freezed,Object? forwardedPost = freezed,Object? attachments = null,Object? publisher = null,Object? reactions = null,Object? tags = null,Object? categories = null,Object? collections = null,Object? empty = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as dynamic,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as dynamic,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,viewsUnique: null == viewsUnique ? _self.viewsUnique : viewsUnique // ignore: cast_nullable_to_non_nullable
as int,viewsTotal: null == viewsTotal ? _self.viewsTotal : viewsTotal // ignore: cast_nullable_to_non_nullable
as int,upvotes: null == upvotes ? _self.upvotes : upvotes // ignore: cast_nullable_to_non_nullable
as int,downvotes: null == downvotes ? _self.downvotes : downvotes // ignore: cast_nullable_to_non_nullable
as int,threadedPostId: freezed == threadedPostId ? _self.threadedPostId : threadedPostId // ignore: cast_nullable_to_non_nullable
as dynamic,threadedPost: freezed == threadedPost ? _self.threadedPost : threadedPost // ignore: cast_nullable_to_non_nullable
as dynamic,repliedPostId: freezed == repliedPostId ? _self.repliedPostId : repliedPostId // ignore: cast_nullable_to_non_nullable
as dynamic,repliedPost: freezed == repliedPost ? _self.repliedPost : repliedPost // ignore: cast_nullable_to_non_nullable
as dynamic,forwardedPostId: freezed == forwardedPostId ? _self.forwardedPostId : forwardedPostId // ignore: cast_nullable_to_non_nullable
as dynamic,forwardedPost: freezed == forwardedPost ? _self.forwardedPost : forwardedPost // ignore: cast_nullable_to_non_nullable
as dynamic,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<dynamic>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<dynamic>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<dynamic>,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<dynamic>,empty: null == empty ? _self.empty : empty // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
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
}


/// @nodoc
mixin _$SnPublisher {

 int get id; int get publisherType; String get name; String get nick; String get bio; SnCloudFile? get picture; SnCloudFile? get background; int get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<SnPublisher> get copyWith => _$SnPublisherCopyWithImpl<SnPublisher>(this as SnPublisher, _$identity);

  /// Serializes this SnPublisher to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisher&&(identical(other.id, id) || other.id == id)&&(identical(other.publisherType, publisherType) || other.publisherType == publisherType)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publisherType,name,nick,bio,picture,background,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPublisher(id: $id, publisherType: $publisherType, name: $name, nick: $nick, bio: $bio, picture: $picture, background: $background, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPublisherCopyWith<$Res>  {
  factory $SnPublisherCopyWith(SnPublisher value, $Res Function(SnPublisher) _then) = _$SnPublisherCopyWithImpl;
@useResult
$Res call({
 int id, int publisherType, String name, String nick, String bio, SnCloudFile? picture, SnCloudFile? background, int accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnCloudFileCopyWith<$Res>? get picture;$SnCloudFileCopyWith<$Res>? get background;

}
/// @nodoc
class _$SnPublisherCopyWithImpl<$Res>
    implements $SnPublisherCopyWith<$Res> {
  _$SnPublisherCopyWithImpl(this._self, this._then);

  final SnPublisher _self;
  final $Res Function(SnPublisher) _then;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publisherType = null,Object? name = null,Object? nick = null,Object? bio = null,Object? picture = freezed,Object? background = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,publisherType: null == publisherType ? _self.publisherType : publisherType // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _SnPublisher implements SnPublisher {
  const _SnPublisher({required this.id, required this.publisherType, required this.name, required this.nick, required this.bio, required this.picture, required this.background, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnPublisher.fromJson(Map<String, dynamic> json) => _$SnPublisherFromJson(json);

@override final  int id;
@override final  int publisherType;
@override final  String name;
@override final  String nick;
@override final  String bio;
@override final  SnCloudFile? picture;
@override final  SnCloudFile? background;
@override final  int accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherCopyWith<_SnPublisher> get copyWith => __$SnPublisherCopyWithImpl<_SnPublisher>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisher&&(identical(other.id, id) || other.id == id)&&(identical(other.publisherType, publisherType) || other.publisherType == publisherType)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publisherType,name,nick,bio,picture,background,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPublisher(id: $id, publisherType: $publisherType, name: $name, nick: $nick, bio: $bio, picture: $picture, background: $background, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherCopyWith<$Res> implements $SnPublisherCopyWith<$Res> {
  factory _$SnPublisherCopyWith(_SnPublisher value, $Res Function(_SnPublisher) _then) = __$SnPublisherCopyWithImpl;
@override @useResult
$Res call({
 int id, int publisherType, String name, String nick, String bio, SnCloudFile? picture, SnCloudFile? background, int accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnCloudFileCopyWith<$Res>? get picture;@override $SnCloudFileCopyWith<$Res>? get background;

}
/// @nodoc
class __$SnPublisherCopyWithImpl<$Res>
    implements _$SnPublisherCopyWith<$Res> {
  __$SnPublisherCopyWithImpl(this._self, this._then);

  final _SnPublisher _self;
  final $Res Function(_SnPublisher) _then;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publisherType = null,Object? name = null,Object? nick = null,Object? bio = null,Object? picture = freezed,Object? background = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPublisher(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,publisherType: null == publisherType ? _self.publisherType : publisherType // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}
}

// dart format on
