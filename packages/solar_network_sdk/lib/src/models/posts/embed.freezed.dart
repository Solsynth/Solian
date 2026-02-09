// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnScrappedLink {

 String get type; String get url; String? get title; String? get description; String? get imageUrl; String? get faviconUrl; String? get siteName; String? get contentType; String? get author; DateTime? get publishedDate;
/// Create a copy of SnScrappedLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnScrappedLinkCopyWith<SnScrappedLink> get copyWith => _$SnScrappedLinkCopyWithImpl<SnScrappedLink>(this as SnScrappedLink, _$identity);

  /// Serializes this SnScrappedLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnScrappedLink&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.faviconUrl, faviconUrl) || other.faviconUrl == faviconUrl)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.author, author) || other.author == author)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,url,title,description,imageUrl,faviconUrl,siteName,contentType,author,publishedDate);

@override
String toString() {
  return 'SnScrappedLink(type: $type, url: $url, title: $title, description: $description, imageUrl: $imageUrl, faviconUrl: $faviconUrl, siteName: $siteName, contentType: $contentType, author: $author, publishedDate: $publishedDate)';
}


}

/// @nodoc
abstract mixin class $SnScrappedLinkCopyWith<$Res>  {
  factory $SnScrappedLinkCopyWith(SnScrappedLink value, $Res Function(SnScrappedLink) _then) = _$SnScrappedLinkCopyWithImpl;
@useResult
$Res call({
 String type, String url, String? title, String? description, String? imageUrl, String? faviconUrl, String? siteName, String? contentType, String? author, DateTime? publishedDate
});




}
/// @nodoc
class _$SnScrappedLinkCopyWithImpl<$Res>
    implements $SnScrappedLinkCopyWith<$Res> {
  _$SnScrappedLinkCopyWithImpl(this._self, this._then);

  final SnScrappedLink _self;
  final $Res Function(SnScrappedLink) _then;

/// Create a copy of SnScrappedLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? url = null,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? faviconUrl = freezed,Object? siteName = freezed,Object? contentType = freezed,Object? author = freezed,Object? publishedDate = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,faviconUrl: freezed == faviconUrl ? _self.faviconUrl : faviconUrl // ignore: cast_nullable_to_non_nullable
as String?,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,publishedDate: freezed == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnScrappedLink].
extension SnScrappedLinkPatterns on SnScrappedLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnScrappedLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnScrappedLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnScrappedLink value)  $default,){
final _that = this;
switch (_that) {
case _SnScrappedLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnScrappedLink value)?  $default,){
final _that = this;
switch (_that) {
case _SnScrappedLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String url,  String? title,  String? description,  String? imageUrl,  String? faviconUrl,  String? siteName,  String? contentType,  String? author,  DateTime? publishedDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnScrappedLink() when $default != null:
return $default(_that.type,_that.url,_that.title,_that.description,_that.imageUrl,_that.faviconUrl,_that.siteName,_that.contentType,_that.author,_that.publishedDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String url,  String? title,  String? description,  String? imageUrl,  String? faviconUrl,  String? siteName,  String? contentType,  String? author,  DateTime? publishedDate)  $default,) {final _that = this;
switch (_that) {
case _SnScrappedLink():
return $default(_that.type,_that.url,_that.title,_that.description,_that.imageUrl,_that.faviconUrl,_that.siteName,_that.contentType,_that.author,_that.publishedDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String url,  String? title,  String? description,  String? imageUrl,  String? faviconUrl,  String? siteName,  String? contentType,  String? author,  DateTime? publishedDate)?  $default,) {final _that = this;
switch (_that) {
case _SnScrappedLink() when $default != null:
return $default(_that.type,_that.url,_that.title,_that.description,_that.imageUrl,_that.faviconUrl,_that.siteName,_that.contentType,_that.author,_that.publishedDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnScrappedLink implements SnScrappedLink {
  const _SnScrappedLink({required this.type, required this.url, required this.title, required this.description, required this.imageUrl, required this.faviconUrl, required this.siteName, required this.contentType, required this.author, required this.publishedDate});
  factory _SnScrappedLink.fromJson(Map<String, dynamic> json) => _$SnScrappedLinkFromJson(json);

@override final  String type;
@override final  String url;
@override final  String? title;
@override final  String? description;
@override final  String? imageUrl;
@override final  String? faviconUrl;
@override final  String? siteName;
@override final  String? contentType;
@override final  String? author;
@override final  DateTime? publishedDate;

/// Create a copy of SnScrappedLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnScrappedLinkCopyWith<_SnScrappedLink> get copyWith => __$SnScrappedLinkCopyWithImpl<_SnScrappedLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnScrappedLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnScrappedLink&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.faviconUrl, faviconUrl) || other.faviconUrl == faviconUrl)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.author, author) || other.author == author)&&(identical(other.publishedDate, publishedDate) || other.publishedDate == publishedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,url,title,description,imageUrl,faviconUrl,siteName,contentType,author,publishedDate);

@override
String toString() {
  return 'SnScrappedLink(type: $type, url: $url, title: $title, description: $description, imageUrl: $imageUrl, faviconUrl: $faviconUrl, siteName: $siteName, contentType: $contentType, author: $author, publishedDate: $publishedDate)';
}


}

/// @nodoc
abstract mixin class _$SnScrappedLinkCopyWith<$Res> implements $SnScrappedLinkCopyWith<$Res> {
  factory _$SnScrappedLinkCopyWith(_SnScrappedLink value, $Res Function(_SnScrappedLink) _then) = __$SnScrappedLinkCopyWithImpl;
@override @useResult
$Res call({
 String type, String url, String? title, String? description, String? imageUrl, String? faviconUrl, String? siteName, String? contentType, String? author, DateTime? publishedDate
});




}
/// @nodoc
class __$SnScrappedLinkCopyWithImpl<$Res>
    implements _$SnScrappedLinkCopyWith<$Res> {
  __$SnScrappedLinkCopyWithImpl(this._self, this._then);

  final _SnScrappedLink _self;
  final $Res Function(_SnScrappedLink) _then;

/// Create a copy of SnScrappedLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? url = null,Object? title = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? faviconUrl = freezed,Object? siteName = freezed,Object? contentType = freezed,Object? author = freezed,Object? publishedDate = freezed,}) {
  return _then(_SnScrappedLink(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,faviconUrl: freezed == faviconUrl ? _self.faviconUrl : faviconUrl // ignore: cast_nullable_to_non_nullable
as String?,siteName: freezed == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String?,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,publishedDate: freezed == publishedDate ? _self.publishedDate : publishedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
