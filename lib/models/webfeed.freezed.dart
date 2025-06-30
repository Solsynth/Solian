// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webfeed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WebFeedConfig {

 bool get scrapPage;
/// Create a copy of WebFeedConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebFeedConfigCopyWith<WebFeedConfig> get copyWith => _$WebFeedConfigCopyWithImpl<WebFeedConfig>(this as WebFeedConfig, _$identity);

  /// Serializes this WebFeedConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebFeedConfig&&(identical(other.scrapPage, scrapPage) || other.scrapPage == scrapPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scrapPage);

@override
String toString() {
  return 'WebFeedConfig(scrapPage: $scrapPage)';
}


}

/// @nodoc
abstract mixin class $WebFeedConfigCopyWith<$Res>  {
  factory $WebFeedConfigCopyWith(WebFeedConfig value, $Res Function(WebFeedConfig) _then) = _$WebFeedConfigCopyWithImpl;
@useResult
$Res call({
 bool scrapPage
});




}
/// @nodoc
class _$WebFeedConfigCopyWithImpl<$Res>
    implements $WebFeedConfigCopyWith<$Res> {
  _$WebFeedConfigCopyWithImpl(this._self, this._then);

  final WebFeedConfig _self;
  final $Res Function(WebFeedConfig) _then;

/// Create a copy of WebFeedConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scrapPage = null,}) {
  return _then(_self.copyWith(
scrapPage: null == scrapPage ? _self.scrapPage : scrapPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _WebFeedConfig implements WebFeedConfig {
  const _WebFeedConfig({this.scrapPage = false});
  factory _WebFeedConfig.fromJson(Map<String, dynamic> json) => _$WebFeedConfigFromJson(json);

@override@JsonKey() final  bool scrapPage;

/// Create a copy of WebFeedConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebFeedConfigCopyWith<_WebFeedConfig> get copyWith => __$WebFeedConfigCopyWithImpl<_WebFeedConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebFeedConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebFeedConfig&&(identical(other.scrapPage, scrapPage) || other.scrapPage == scrapPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scrapPage);

@override
String toString() {
  return 'WebFeedConfig(scrapPage: $scrapPage)';
}


}

/// @nodoc
abstract mixin class _$WebFeedConfigCopyWith<$Res> implements $WebFeedConfigCopyWith<$Res> {
  factory _$WebFeedConfigCopyWith(_WebFeedConfig value, $Res Function(_WebFeedConfig) _then) = __$WebFeedConfigCopyWithImpl;
@override @useResult
$Res call({
 bool scrapPage
});




}
/// @nodoc
class __$WebFeedConfigCopyWithImpl<$Res>
    implements _$WebFeedConfigCopyWith<$Res> {
  __$WebFeedConfigCopyWithImpl(this._self, this._then);

  final _WebFeedConfig _self;
  final $Res Function(_WebFeedConfig) _then;

/// Create a copy of WebFeedConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scrapPage = null,}) {
  return _then(_WebFeedConfig(
scrapPage: null == scrapPage ? _self.scrapPage : scrapPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$WebFeed {

 String get id; String get url; String get title; String? get description; SnScrappedLink? get preview; WebFeedConfig get config; String get publisherId; List<WebArticle> get articles; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of WebFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebFeedCopyWith<WebFeed> get copyWith => _$WebFeedCopyWithImpl<WebFeed>(this as WebFeed, _$identity);

  /// Serializes this WebFeed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebFeed&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.config, config) || other.config == config)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&const DeepCollectionEquality().equals(other.articles, articles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,title,description,preview,config,publisherId,const DeepCollectionEquality().hash(articles),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'WebFeed(id: $id, url: $url, title: $title, description: $description, preview: $preview, config: $config, publisherId: $publisherId, articles: $articles, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $WebFeedCopyWith<$Res>  {
  factory $WebFeedCopyWith(WebFeed value, $Res Function(WebFeed) _then) = _$WebFeedCopyWithImpl;
@useResult
$Res call({
 String id, String url, String title, String? description, SnScrappedLink? preview, WebFeedConfig config, String publisherId, List<WebArticle> articles, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnScrappedLinkCopyWith<$Res>? get preview;$WebFeedConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$WebFeedCopyWithImpl<$Res>
    implements $WebFeedCopyWith<$Res> {
  _$WebFeedCopyWithImpl(this._self, this._then);

  final WebFeed _self;
  final $Res Function(WebFeed) _then;

/// Create a copy of WebFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? title = null,Object? description = freezed,Object? preview = freezed,Object? config = null,Object? publisherId = null,Object? articles = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as SnScrappedLink?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as WebFeedConfig,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,articles: null == articles ? _self.articles : articles // ignore: cast_nullable_to_non_nullable
as List<WebArticle>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of WebFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnScrappedLinkCopyWith<$Res>? get preview {
    if (_self.preview == null) {
    return null;
  }

  return $SnScrappedLinkCopyWith<$Res>(_self.preview!, (value) {
    return _then(_self.copyWith(preview: value));
  });
}/// Create a copy of WebFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WebFeedConfigCopyWith<$Res> get config {
  
  return $WebFeedConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _WebFeed implements WebFeed {
  const _WebFeed({required this.id, required this.url, required this.title, this.description, this.preview, this.config = const WebFeedConfig(), required this.publisherId, final  List<WebArticle> articles = const [], required this.createdAt, required this.updatedAt, this.deletedAt}): _articles = articles;
  factory _WebFeed.fromJson(Map<String, dynamic> json) => _$WebFeedFromJson(json);

@override final  String id;
@override final  String url;
@override final  String title;
@override final  String? description;
@override final  SnScrappedLink? preview;
@override@JsonKey() final  WebFeedConfig config;
@override final  String publisherId;
 final  List<WebArticle> _articles;
@override@JsonKey() List<WebArticle> get articles {
  if (_articles is EqualUnmodifiableListView) return _articles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_articles);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of WebFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebFeedCopyWith<_WebFeed> get copyWith => __$WebFeedCopyWithImpl<_WebFeed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebFeedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebFeed&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.config, config) || other.config == config)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&const DeepCollectionEquality().equals(other._articles, _articles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,title,description,preview,config,publisherId,const DeepCollectionEquality().hash(_articles),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'WebFeed(id: $id, url: $url, title: $title, description: $description, preview: $preview, config: $config, publisherId: $publisherId, articles: $articles, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$WebFeedCopyWith<$Res> implements $WebFeedCopyWith<$Res> {
  factory _$WebFeedCopyWith(_WebFeed value, $Res Function(_WebFeed) _then) = __$WebFeedCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String title, String? description, SnScrappedLink? preview, WebFeedConfig config, String publisherId, List<WebArticle> articles, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnScrappedLinkCopyWith<$Res>? get preview;@override $WebFeedConfigCopyWith<$Res> get config;

}
/// @nodoc
class __$WebFeedCopyWithImpl<$Res>
    implements _$WebFeedCopyWith<$Res> {
  __$WebFeedCopyWithImpl(this._self, this._then);

  final _WebFeed _self;
  final $Res Function(_WebFeed) _then;

/// Create a copy of WebFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? title = null,Object? description = freezed,Object? preview = freezed,Object? config = null,Object? publisherId = null,Object? articles = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_WebFeed(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as SnScrappedLink?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as WebFeedConfig,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,articles: null == articles ? _self._articles : articles // ignore: cast_nullable_to_non_nullable
as List<WebArticle>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of WebFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnScrappedLinkCopyWith<$Res>? get preview {
    if (_self.preview == null) {
    return null;
  }

  return $SnScrappedLinkCopyWith<$Res>(_self.preview!, (value) {
    return _then(_self.copyWith(preview: value));
  });
}/// Create a copy of WebFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WebFeedConfigCopyWith<$Res> get config {
  
  return $WebFeedConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// @nodoc
mixin _$WebArticle {

 String get id; String get title; String get url; String? get author; Map<String, dynamic>? get meta; SnScrappedLink? get preview; String? get content; DateTime? get publishedAt; String get feedId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of WebArticle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebArticleCopyWith<WebArticle> get copyWith => _$WebArticleCopyWithImpl<WebArticle>(this as WebArticle, _$identity);

  /// Serializes this WebArticle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebArticle&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.content, content) || other.content == content)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.feedId, feedId) || other.feedId == feedId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,author,const DeepCollectionEquality().hash(meta),preview,content,publishedAt,feedId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'WebArticle(id: $id, title: $title, url: $url, author: $author, meta: $meta, preview: $preview, content: $content, publishedAt: $publishedAt, feedId: $feedId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $WebArticleCopyWith<$Res>  {
  factory $WebArticleCopyWith(WebArticle value, $Res Function(WebArticle) _then) = _$WebArticleCopyWithImpl;
@useResult
$Res call({
 String id, String title, String url, String? author, Map<String, dynamic>? meta, SnScrappedLink? preview, String? content, DateTime? publishedAt, String feedId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnScrappedLinkCopyWith<$Res>? get preview;

}
/// @nodoc
class _$WebArticleCopyWithImpl<$Res>
    implements $WebArticleCopyWith<$Res> {
  _$WebArticleCopyWithImpl(this._self, this._then);

  final WebArticle _self;
  final $Res Function(WebArticle) _then;

/// Create a copy of WebArticle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? url = null,Object? author = freezed,Object? meta = freezed,Object? preview = freezed,Object? content = freezed,Object? publishedAt = freezed,Object? feedId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as SnScrappedLink?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedId: null == feedId ? _self.feedId : feedId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of WebArticle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnScrappedLinkCopyWith<$Res>? get preview {
    if (_self.preview == null) {
    return null;
  }

  return $SnScrappedLinkCopyWith<$Res>(_self.preview!, (value) {
    return _then(_self.copyWith(preview: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _WebArticle implements WebArticle {
  const _WebArticle({required this.id, required this.title, required this.url, this.author, final  Map<String, dynamic>? meta, this.preview, this.content, this.publishedAt, required this.feedId, required this.createdAt, required this.updatedAt, this.deletedAt}): _meta = meta;
  factory _WebArticle.fromJson(Map<String, dynamic> json) => _$WebArticleFromJson(json);

@override final  String id;
@override final  String title;
@override final  String url;
@override final  String? author;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  SnScrappedLink? preview;
@override final  String? content;
@override final  DateTime? publishedAt;
@override final  String feedId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of WebArticle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebArticleCopyWith<_WebArticle> get copyWith => __$WebArticleCopyWithImpl<_WebArticle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebArticleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebArticle&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.content, content) || other.content == content)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.feedId, feedId) || other.feedId == feedId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,author,const DeepCollectionEquality().hash(_meta),preview,content,publishedAt,feedId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'WebArticle(id: $id, title: $title, url: $url, author: $author, meta: $meta, preview: $preview, content: $content, publishedAt: $publishedAt, feedId: $feedId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$WebArticleCopyWith<$Res> implements $WebArticleCopyWith<$Res> {
  factory _$WebArticleCopyWith(_WebArticle value, $Res Function(_WebArticle) _then) = __$WebArticleCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String url, String? author, Map<String, dynamic>? meta, SnScrappedLink? preview, String? content, DateTime? publishedAt, String feedId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnScrappedLinkCopyWith<$Res>? get preview;

}
/// @nodoc
class __$WebArticleCopyWithImpl<$Res>
    implements _$WebArticleCopyWith<$Res> {
  __$WebArticleCopyWithImpl(this._self, this._then);

  final _WebArticle _self;
  final $Res Function(_WebArticle) _then;

/// Create a copy of WebArticle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? url = null,Object? author = freezed,Object? meta = freezed,Object? preview = freezed,Object? content = freezed,Object? publishedAt = freezed,Object? feedId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_WebArticle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as SnScrappedLink?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedId: null == feedId ? _self.feedId : feedId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of WebArticle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnScrappedLinkCopyWith<$Res>? get preview {
    if (_self.preview == null) {
    return null;
  }

  return $SnScrappedLinkCopyWith<$Res>(_self.preview!, (value) {
    return _then(_self.copyWith(preview: value));
  });
}
}

// dart format on
