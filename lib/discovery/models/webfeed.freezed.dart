// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webfeed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnWebFeedConfig {

 bool get scrapPage;
/// Create a copy of SnWebFeedConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWebFeedConfigCopyWith<SnWebFeedConfig> get copyWith => _$SnWebFeedConfigCopyWithImpl<SnWebFeedConfig>(this as SnWebFeedConfig, _$identity);

  /// Serializes this SnWebFeedConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWebFeedConfig&&(identical(other.scrapPage, scrapPage) || other.scrapPage == scrapPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scrapPage);

@override
String toString() {
  return 'SnWebFeedConfig(scrapPage: $scrapPage)';
}


}

/// @nodoc
abstract mixin class $SnWebFeedConfigCopyWith<$Res>  {
  factory $SnWebFeedConfigCopyWith(SnWebFeedConfig value, $Res Function(SnWebFeedConfig) _then) = _$SnWebFeedConfigCopyWithImpl;
@useResult
$Res call({
 bool scrapPage
});




}
/// @nodoc
class _$SnWebFeedConfigCopyWithImpl<$Res>
    implements $SnWebFeedConfigCopyWith<$Res> {
  _$SnWebFeedConfigCopyWithImpl(this._self, this._then);

  final SnWebFeedConfig _self;
  final $Res Function(SnWebFeedConfig) _then;

/// Create a copy of SnWebFeedConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scrapPage = null,}) {
  return _then(_self.copyWith(
scrapPage: null == scrapPage ? _self.scrapPage : scrapPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SnWebFeedConfig].
extension SnWebFeedConfigPatterns on SnWebFeedConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWebFeedConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWebFeedConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWebFeedConfig value)  $default,){
final _that = this;
switch (_that) {
case _SnWebFeedConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWebFeedConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SnWebFeedConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool scrapPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWebFeedConfig() when $default != null:
return $default(_that.scrapPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool scrapPage)  $default,) {final _that = this;
switch (_that) {
case _SnWebFeedConfig():
return $default(_that.scrapPage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool scrapPage)?  $default,) {final _that = this;
switch (_that) {
case _SnWebFeedConfig() when $default != null:
return $default(_that.scrapPage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWebFeedConfig implements SnWebFeedConfig {
  const _SnWebFeedConfig({this.scrapPage = false});
  factory _SnWebFeedConfig.fromJson(Map<String, dynamic> json) => _$SnWebFeedConfigFromJson(json);

@override@JsonKey() final  bool scrapPage;

/// Create a copy of SnWebFeedConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWebFeedConfigCopyWith<_SnWebFeedConfig> get copyWith => __$SnWebFeedConfigCopyWithImpl<_SnWebFeedConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWebFeedConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWebFeedConfig&&(identical(other.scrapPage, scrapPage) || other.scrapPage == scrapPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scrapPage);

@override
String toString() {
  return 'SnWebFeedConfig(scrapPage: $scrapPage)';
}


}

/// @nodoc
abstract mixin class _$SnWebFeedConfigCopyWith<$Res> implements $SnWebFeedConfigCopyWith<$Res> {
  factory _$SnWebFeedConfigCopyWith(_SnWebFeedConfig value, $Res Function(_SnWebFeedConfig) _then) = __$SnWebFeedConfigCopyWithImpl;
@override @useResult
$Res call({
 bool scrapPage
});




}
/// @nodoc
class __$SnWebFeedConfigCopyWithImpl<$Res>
    implements _$SnWebFeedConfigCopyWith<$Res> {
  __$SnWebFeedConfigCopyWithImpl(this._self, this._then);

  final _SnWebFeedConfig _self;
  final $Res Function(_SnWebFeedConfig) _then;

/// Create a copy of SnWebFeedConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scrapPage = null,}) {
  return _then(_SnWebFeedConfig(
scrapPage: null == scrapPage ? _self.scrapPage : scrapPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SnWebFeed {

 String get id; String get url; String get title; String? get description; SnScrappedLink? get preview; SnWebFeedConfig get config; String get publisherId; List<SnWebArticle> get articles; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnWebFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWebFeedCopyWith<SnWebFeed> get copyWith => _$SnWebFeedCopyWithImpl<SnWebFeed>(this as SnWebFeed, _$identity);

  /// Serializes this SnWebFeed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWebFeed&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.config, config) || other.config == config)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&const DeepCollectionEquality().equals(other.articles, articles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,title,description,preview,config,publisherId,const DeepCollectionEquality().hash(articles),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWebFeed(id: $id, url: $url, title: $title, description: $description, preview: $preview, config: $config, publisherId: $publisherId, articles: $articles, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnWebFeedCopyWith<$Res>  {
  factory $SnWebFeedCopyWith(SnWebFeed value, $Res Function(SnWebFeed) _then) = _$SnWebFeedCopyWithImpl;
@useResult
$Res call({
 String id, String url, String title, String? description, SnScrappedLink? preview, SnWebFeedConfig config, String publisherId, List<SnWebArticle> articles, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnScrappedLinkCopyWith<$Res>? get preview;$SnWebFeedConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$SnWebFeedCopyWithImpl<$Res>
    implements $SnWebFeedCopyWith<$Res> {
  _$SnWebFeedCopyWithImpl(this._self, this._then);

  final SnWebFeed _self;
  final $Res Function(SnWebFeed) _then;

/// Create a copy of SnWebFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? title = null,Object? description = freezed,Object? preview = freezed,Object? config = null,Object? publisherId = null,Object? articles = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as SnScrappedLink?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as SnWebFeedConfig,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,articles: null == articles ? _self.articles : articles // ignore: cast_nullable_to_non_nullable
as List<SnWebArticle>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnWebFeed
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
}/// Create a copy of SnWebFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWebFeedConfigCopyWith<$Res> get config {
  
  return $SnWebFeedConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnWebFeed].
extension SnWebFeedPatterns on SnWebFeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWebFeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWebFeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWebFeed value)  $default,){
final _that = this;
switch (_that) {
case _SnWebFeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWebFeed value)?  $default,){
final _that = this;
switch (_that) {
case _SnWebFeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String title,  String? description,  SnScrappedLink? preview,  SnWebFeedConfig config,  String publisherId,  List<SnWebArticle> articles,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWebFeed() when $default != null:
return $default(_that.id,_that.url,_that.title,_that.description,_that.preview,_that.config,_that.publisherId,_that.articles,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String title,  String? description,  SnScrappedLink? preview,  SnWebFeedConfig config,  String publisherId,  List<SnWebArticle> articles,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnWebFeed():
return $default(_that.id,_that.url,_that.title,_that.description,_that.preview,_that.config,_that.publisherId,_that.articles,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String title,  String? description,  SnScrappedLink? preview,  SnWebFeedConfig config,  String publisherId,  List<SnWebArticle> articles,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnWebFeed() when $default != null:
return $default(_that.id,_that.url,_that.title,_that.description,_that.preview,_that.config,_that.publisherId,_that.articles,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWebFeed implements SnWebFeed {
  const _SnWebFeed({required this.id, required this.url, required this.title, this.description, this.preview, this.config = const SnWebFeedConfig(), required this.publisherId, final  List<SnWebArticle> articles = const [], required this.createdAt, required this.updatedAt, this.deletedAt}): _articles = articles;
  factory _SnWebFeed.fromJson(Map<String, dynamic> json) => _$SnWebFeedFromJson(json);

@override final  String id;
@override final  String url;
@override final  String title;
@override final  String? description;
@override final  SnScrappedLink? preview;
@override@JsonKey() final  SnWebFeedConfig config;
@override final  String publisherId;
 final  List<SnWebArticle> _articles;
@override@JsonKey() List<SnWebArticle> get articles {
  if (_articles is EqualUnmodifiableListView) return _articles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_articles);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnWebFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWebFeedCopyWith<_SnWebFeed> get copyWith => __$SnWebFeedCopyWithImpl<_SnWebFeed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWebFeedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWebFeed&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.config, config) || other.config == config)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&const DeepCollectionEquality().equals(other._articles, _articles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,title,description,preview,config,publisherId,const DeepCollectionEquality().hash(_articles),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWebFeed(id: $id, url: $url, title: $title, description: $description, preview: $preview, config: $config, publisherId: $publisherId, articles: $articles, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnWebFeedCopyWith<$Res> implements $SnWebFeedCopyWith<$Res> {
  factory _$SnWebFeedCopyWith(_SnWebFeed value, $Res Function(_SnWebFeed) _then) = __$SnWebFeedCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String title, String? description, SnScrappedLink? preview, SnWebFeedConfig config, String publisherId, List<SnWebArticle> articles, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnScrappedLinkCopyWith<$Res>? get preview;@override $SnWebFeedConfigCopyWith<$Res> get config;

}
/// @nodoc
class __$SnWebFeedCopyWithImpl<$Res>
    implements _$SnWebFeedCopyWith<$Res> {
  __$SnWebFeedCopyWithImpl(this._self, this._then);

  final _SnWebFeed _self;
  final $Res Function(_SnWebFeed) _then;

/// Create a copy of SnWebFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? title = null,Object? description = freezed,Object? preview = freezed,Object? config = null,Object? publisherId = null,Object? articles = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnWebFeed(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as SnScrappedLink?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as SnWebFeedConfig,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,articles: null == articles ? _self._articles : articles // ignore: cast_nullable_to_non_nullable
as List<SnWebArticle>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnWebFeed
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
}/// Create a copy of SnWebFeed
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWebFeedConfigCopyWith<$Res> get config {
  
  return $SnWebFeedConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// @nodoc
mixin _$SnWebArticle {

 String get id; String get title; String get url; String? get author; Map<String, dynamic>? get meta; SnScrappedLink? get preview; SnWebFeed? get feed; String? get content; DateTime? get publishedAt; String get feedId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnWebArticle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWebArticleCopyWith<SnWebArticle> get copyWith => _$SnWebArticleCopyWithImpl<SnWebArticle>(this as SnWebArticle, _$identity);

  /// Serializes this SnWebArticle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWebArticle&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.feed, feed) || other.feed == feed)&&(identical(other.content, content) || other.content == content)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.feedId, feedId) || other.feedId == feedId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,author,const DeepCollectionEquality().hash(meta),preview,feed,content,publishedAt,feedId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWebArticle(id: $id, title: $title, url: $url, author: $author, meta: $meta, preview: $preview, feed: $feed, content: $content, publishedAt: $publishedAt, feedId: $feedId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnWebArticleCopyWith<$Res>  {
  factory $SnWebArticleCopyWith(SnWebArticle value, $Res Function(SnWebArticle) _then) = _$SnWebArticleCopyWithImpl;
@useResult
$Res call({
 String id, String title, String url, String? author, Map<String, dynamic>? meta, SnScrappedLink? preview, SnWebFeed? feed, String? content, DateTime? publishedAt, String feedId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnScrappedLinkCopyWith<$Res>? get preview;$SnWebFeedCopyWith<$Res>? get feed;

}
/// @nodoc
class _$SnWebArticleCopyWithImpl<$Res>
    implements $SnWebArticleCopyWith<$Res> {
  _$SnWebArticleCopyWithImpl(this._self, this._then);

  final SnWebArticle _self;
  final $Res Function(SnWebArticle) _then;

/// Create a copy of SnWebArticle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? url = null,Object? author = freezed,Object? meta = freezed,Object? preview = freezed,Object? feed = freezed,Object? content = freezed,Object? publishedAt = freezed,Object? feedId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as SnScrappedLink?,feed: freezed == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as SnWebFeed?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedId: null == feedId ? _self.feedId : feedId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnWebArticle
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
}/// Create a copy of SnWebArticle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWebFeedCopyWith<$Res>? get feed {
    if (_self.feed == null) {
    return null;
  }

  return $SnWebFeedCopyWith<$Res>(_self.feed!, (value) {
    return _then(_self.copyWith(feed: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnWebArticle].
extension SnWebArticlePatterns on SnWebArticle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWebArticle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWebArticle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWebArticle value)  $default,){
final _that = this;
switch (_that) {
case _SnWebArticle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWebArticle value)?  $default,){
final _that = this;
switch (_that) {
case _SnWebArticle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String url,  String? author,  Map<String, dynamic>? meta,  SnScrappedLink? preview,  SnWebFeed? feed,  String? content,  DateTime? publishedAt,  String feedId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWebArticle() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.author,_that.meta,_that.preview,_that.feed,_that.content,_that.publishedAt,_that.feedId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String url,  String? author,  Map<String, dynamic>? meta,  SnScrappedLink? preview,  SnWebFeed? feed,  String? content,  DateTime? publishedAt,  String feedId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnWebArticle():
return $default(_that.id,_that.title,_that.url,_that.author,_that.meta,_that.preview,_that.feed,_that.content,_that.publishedAt,_that.feedId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String url,  String? author,  Map<String, dynamic>? meta,  SnScrappedLink? preview,  SnWebFeed? feed,  String? content,  DateTime? publishedAt,  String feedId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnWebArticle() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.author,_that.meta,_that.preview,_that.feed,_that.content,_that.publishedAt,_that.feedId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWebArticle implements SnWebArticle {
  const _SnWebArticle({required this.id, required this.title, required this.url, this.author, final  Map<String, dynamic>? meta, this.preview, this.feed, this.content, this.publishedAt, required this.feedId, required this.createdAt, required this.updatedAt, this.deletedAt}): _meta = meta;
  factory _SnWebArticle.fromJson(Map<String, dynamic> json) => _$SnWebArticleFromJson(json);

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
@override final  SnWebFeed? feed;
@override final  String? content;
@override final  DateTime? publishedAt;
@override final  String feedId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnWebArticle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWebArticleCopyWith<_SnWebArticle> get copyWith => __$SnWebArticleCopyWithImpl<_SnWebArticle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWebArticleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWebArticle&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.preview, preview) || other.preview == preview)&&(identical(other.feed, feed) || other.feed == feed)&&(identical(other.content, content) || other.content == content)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.feedId, feedId) || other.feedId == feedId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,author,const DeepCollectionEquality().hash(_meta),preview,feed,content,publishedAt,feedId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWebArticle(id: $id, title: $title, url: $url, author: $author, meta: $meta, preview: $preview, feed: $feed, content: $content, publishedAt: $publishedAt, feedId: $feedId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnWebArticleCopyWith<$Res> implements $SnWebArticleCopyWith<$Res> {
  factory _$SnWebArticleCopyWith(_SnWebArticle value, $Res Function(_SnWebArticle) _then) = __$SnWebArticleCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String url, String? author, Map<String, dynamic>? meta, SnScrappedLink? preview, SnWebFeed? feed, String? content, DateTime? publishedAt, String feedId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnScrappedLinkCopyWith<$Res>? get preview;@override $SnWebFeedCopyWith<$Res>? get feed;

}
/// @nodoc
class __$SnWebArticleCopyWithImpl<$Res>
    implements _$SnWebArticleCopyWith<$Res> {
  __$SnWebArticleCopyWithImpl(this._self, this._then);

  final _SnWebArticle _self;
  final $Res Function(_SnWebArticle) _then;

/// Create a copy of SnWebArticle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? url = null,Object? author = freezed,Object? meta = freezed,Object? preview = freezed,Object? feed = freezed,Object? content = freezed,Object? publishedAt = freezed,Object? feedId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnWebArticle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as SnScrappedLink?,feed: freezed == feed ? _self.feed : feed // ignore: cast_nullable_to_non_nullable
as SnWebFeed?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedId: null == feedId ? _self.feedId : feedId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnWebArticle
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
}/// Create a copy of SnWebArticle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWebFeedCopyWith<$Res>? get feed {
    if (_self.feed == null) {
    return null;
  }

  return $SnWebFeedCopyWith<$Res>(_self.feed!, (value) {
    return _then(_self.copyWith(feed: value));
  });
}
}

// dart format on
