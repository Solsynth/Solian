// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnLiveStream {

 String get id; String? get title; String? get description; String? get slug; SnLiveStreamType get type; SnLiveStreamVisibility get visibility; SnLiveStreamStatus get status; String get roomName; String? get ingressId; String? get ingressStreamKey; String? get egressId; String? get hlsEgressId; String? get hlsPlaylistPath; DateTime? get hlsStartedAt; DateTime? get startedAt; DateTime? get endedAt; int get viewerCount; int get peakViewerCount; SnCloudFileReference? get thumbnail; Map<String, dynamic>? get metadata; String? get publisherId; SnPublisher? get publisher; String? get resourceIdentifier; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnLiveStream
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnLiveStreamCopyWith<SnLiveStream> get copyWith => _$SnLiveStreamCopyWithImpl<SnLiveStream>(this as SnLiveStream, _$identity);

  /// Serializes this SnLiveStream to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnLiveStream&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.type, type) || other.type == type)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.status, status) || other.status == status)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.ingressId, ingressId) || other.ingressId == ingressId)&&(identical(other.ingressStreamKey, ingressStreamKey) || other.ingressStreamKey == ingressStreamKey)&&(identical(other.egressId, egressId) || other.egressId == egressId)&&(identical(other.hlsEgressId, hlsEgressId) || other.hlsEgressId == hlsEgressId)&&(identical(other.hlsPlaylistPath, hlsPlaylistPath) || other.hlsPlaylistPath == hlsPlaylistPath)&&(identical(other.hlsStartedAt, hlsStartedAt) || other.hlsStartedAt == hlsStartedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.peakViewerCount, peakViewerCount) || other.peakViewerCount == peakViewerCount)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,slug,type,visibility,status,roomName,ingressId,ingressStreamKey,egressId,hlsEgressId,hlsPlaylistPath,hlsStartedAt,startedAt,endedAt,viewerCount,peakViewerCount,thumbnail,const DeepCollectionEquality().hash(metadata),publisherId,publisher,resourceIdentifier,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnLiveStream(id: $id, title: $title, description: $description, slug: $slug, type: $type, visibility: $visibility, status: $status, roomName: $roomName, ingressId: $ingressId, ingressStreamKey: $ingressStreamKey, egressId: $egressId, hlsEgressId: $hlsEgressId, hlsPlaylistPath: $hlsPlaylistPath, hlsStartedAt: $hlsStartedAt, startedAt: $startedAt, endedAt: $endedAt, viewerCount: $viewerCount, peakViewerCount: $peakViewerCount, thumbnail: $thumbnail, metadata: $metadata, publisherId: $publisherId, publisher: $publisher, resourceIdentifier: $resourceIdentifier, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnLiveStreamCopyWith<$Res>  {
  factory $SnLiveStreamCopyWith(SnLiveStream value, $Res Function(SnLiveStream) _then) = _$SnLiveStreamCopyWithImpl;
@useResult
$Res call({
 String id, String? title, String? description, String? slug, SnLiveStreamType type, SnLiveStreamVisibility visibility, SnLiveStreamStatus status, String roomName, String? ingressId, String? ingressStreamKey, String? egressId, String? hlsEgressId, String? hlsPlaylistPath, DateTime? hlsStartedAt, DateTime? startedAt, DateTime? endedAt, int viewerCount, int peakViewerCount, SnCloudFileReference? thumbnail, Map<String, dynamic>? metadata, String? publisherId, SnPublisher? publisher, String? resourceIdentifier, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});


$SnCloudFileReferenceCopyWith<$Res>? get thumbnail;$SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class _$SnLiveStreamCopyWithImpl<$Res>
    implements $SnLiveStreamCopyWith<$Res> {
  _$SnLiveStreamCopyWithImpl(this._self, this._then);

  final SnLiveStream _self;
  final $Res Function(SnLiveStream) _then;

/// Create a copy of SnLiveStream
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? slug = freezed,Object? type = null,Object? visibility = null,Object? status = null,Object? roomName = null,Object? ingressId = freezed,Object? ingressStreamKey = freezed,Object? egressId = freezed,Object? hlsEgressId = freezed,Object? hlsPlaylistPath = freezed,Object? hlsStartedAt = freezed,Object? startedAt = freezed,Object? endedAt = freezed,Object? viewerCount = null,Object? peakViewerCount = null,Object? thumbnail = freezed,Object? metadata = freezed,Object? publisherId = freezed,Object? publisher = freezed,Object? resourceIdentifier = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SnLiveStreamType,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as SnLiveStreamVisibility,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnLiveStreamStatus,roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,ingressId: freezed == ingressId ? _self.ingressId : ingressId // ignore: cast_nullable_to_non_nullable
as String?,ingressStreamKey: freezed == ingressStreamKey ? _self.ingressStreamKey : ingressStreamKey // ignore: cast_nullable_to_non_nullable
as String?,egressId: freezed == egressId ? _self.egressId : egressId // ignore: cast_nullable_to_non_nullable
as String?,hlsEgressId: freezed == hlsEgressId ? _self.hlsEgressId : hlsEgressId // ignore: cast_nullable_to_non_nullable
as String?,hlsPlaylistPath: freezed == hlsPlaylistPath ? _self.hlsPlaylistPath : hlsPlaylistPath // ignore: cast_nullable_to_non_nullable
as String?,hlsStartedAt: freezed == hlsStartedAt ? _self.hlsStartedAt : hlsStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,peakViewerCount: null == peakViewerCount ? _self.peakViewerCount : peakViewerCount // ignore: cast_nullable_to_non_nullable
as int,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,publisherId: freezed == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,resourceIdentifier: freezed == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnLiveStream
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get thumbnail {
    if (_self.thumbnail == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.thumbnail!, (value) {
    return _then(_self.copyWith(thumbnail: value));
  });
}/// Create a copy of SnLiveStream
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
}
}


/// Adds pattern-matching-related methods to [SnLiveStream].
extension SnLiveStreamPatterns on SnLiveStream {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnLiveStream value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnLiveStream() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnLiveStream value)  $default,){
final _that = this;
switch (_that) {
case _SnLiveStream():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnLiveStream value)?  $default,){
final _that = this;
switch (_that) {
case _SnLiveStream() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? title,  String? description,  String? slug,  SnLiveStreamType type,  SnLiveStreamVisibility visibility,  SnLiveStreamStatus status,  String roomName,  String? ingressId,  String? ingressStreamKey,  String? egressId,  String? hlsEgressId,  String? hlsPlaylistPath,  DateTime? hlsStartedAt,  DateTime? startedAt,  DateTime? endedAt,  int viewerCount,  int peakViewerCount,  SnCloudFileReference? thumbnail,  Map<String, dynamic>? metadata,  String? publisherId,  SnPublisher? publisher,  String? resourceIdentifier,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnLiveStream() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.slug,_that.type,_that.visibility,_that.status,_that.roomName,_that.ingressId,_that.ingressStreamKey,_that.egressId,_that.hlsEgressId,_that.hlsPlaylistPath,_that.hlsStartedAt,_that.startedAt,_that.endedAt,_that.viewerCount,_that.peakViewerCount,_that.thumbnail,_that.metadata,_that.publisherId,_that.publisher,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? title,  String? description,  String? slug,  SnLiveStreamType type,  SnLiveStreamVisibility visibility,  SnLiveStreamStatus status,  String roomName,  String? ingressId,  String? ingressStreamKey,  String? egressId,  String? hlsEgressId,  String? hlsPlaylistPath,  DateTime? hlsStartedAt,  DateTime? startedAt,  DateTime? endedAt,  int viewerCount,  int peakViewerCount,  SnCloudFileReference? thumbnail,  Map<String, dynamic>? metadata,  String? publisherId,  SnPublisher? publisher,  String? resourceIdentifier,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnLiveStream():
return $default(_that.id,_that.title,_that.description,_that.slug,_that.type,_that.visibility,_that.status,_that.roomName,_that.ingressId,_that.ingressStreamKey,_that.egressId,_that.hlsEgressId,_that.hlsPlaylistPath,_that.hlsStartedAt,_that.startedAt,_that.endedAt,_that.viewerCount,_that.peakViewerCount,_that.thumbnail,_that.metadata,_that.publisherId,_that.publisher,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? title,  String? description,  String? slug,  SnLiveStreamType type,  SnLiveStreamVisibility visibility,  SnLiveStreamStatus status,  String roomName,  String? ingressId,  String? ingressStreamKey,  String? egressId,  String? hlsEgressId,  String? hlsPlaylistPath,  DateTime? hlsStartedAt,  DateTime? startedAt,  DateTime? endedAt,  int viewerCount,  int peakViewerCount,  SnCloudFileReference? thumbnail,  Map<String, dynamic>? metadata,  String? publisherId,  SnPublisher? publisher,  String? resourceIdentifier,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnLiveStream() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.slug,_that.type,_that.visibility,_that.status,_that.roomName,_that.ingressId,_that.ingressStreamKey,_that.egressId,_that.hlsEgressId,_that.hlsPlaylistPath,_that.hlsStartedAt,_that.startedAt,_that.endedAt,_that.viewerCount,_that.peakViewerCount,_that.thumbnail,_that.metadata,_that.publisherId,_that.publisher,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnLiveStream implements SnLiveStream {
  const _SnLiveStream({required this.id, this.title, this.description, this.slug, this.type = SnLiveStreamType.regular, this.visibility = SnLiveStreamVisibility.public, this.status = SnLiveStreamStatus.pending, required this.roomName, this.ingressId, this.ingressStreamKey, this.egressId, this.hlsEgressId, this.hlsPlaylistPath, this.hlsStartedAt, this.startedAt, this.endedAt, this.viewerCount = 0, this.peakViewerCount = 0, this.thumbnail, final  Map<String, dynamic>? metadata, this.publisherId, this.publisher, this.resourceIdentifier, this.createdAt = null, this.updatedAt = null, this.deletedAt}): _metadata = metadata;
  factory _SnLiveStream.fromJson(Map<String, dynamic> json) => _$SnLiveStreamFromJson(json);

@override final  String id;
@override final  String? title;
@override final  String? description;
@override final  String? slug;
@override@JsonKey() final  SnLiveStreamType type;
@override@JsonKey() final  SnLiveStreamVisibility visibility;
@override@JsonKey() final  SnLiveStreamStatus status;
@override final  String roomName;
@override final  String? ingressId;
@override final  String? ingressStreamKey;
@override final  String? egressId;
@override final  String? hlsEgressId;
@override final  String? hlsPlaylistPath;
@override final  DateTime? hlsStartedAt;
@override final  DateTime? startedAt;
@override final  DateTime? endedAt;
@override@JsonKey() final  int viewerCount;
@override@JsonKey() final  int peakViewerCount;
@override final  SnCloudFileReference? thumbnail;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? publisherId;
@override final  SnPublisher? publisher;
@override final  String? resourceIdentifier;
@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey() final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnLiveStream
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnLiveStreamCopyWith<_SnLiveStream> get copyWith => __$SnLiveStreamCopyWithImpl<_SnLiveStream>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnLiveStreamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnLiveStream&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.type, type) || other.type == type)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.status, status) || other.status == status)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.ingressId, ingressId) || other.ingressId == ingressId)&&(identical(other.ingressStreamKey, ingressStreamKey) || other.ingressStreamKey == ingressStreamKey)&&(identical(other.egressId, egressId) || other.egressId == egressId)&&(identical(other.hlsEgressId, hlsEgressId) || other.hlsEgressId == hlsEgressId)&&(identical(other.hlsPlaylistPath, hlsPlaylistPath) || other.hlsPlaylistPath == hlsPlaylistPath)&&(identical(other.hlsStartedAt, hlsStartedAt) || other.hlsStartedAt == hlsStartedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.peakViewerCount, peakViewerCount) || other.peakViewerCount == peakViewerCount)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,slug,type,visibility,status,roomName,ingressId,ingressStreamKey,egressId,hlsEgressId,hlsPlaylistPath,hlsStartedAt,startedAt,endedAt,viewerCount,peakViewerCount,thumbnail,const DeepCollectionEquality().hash(_metadata),publisherId,publisher,resourceIdentifier,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnLiveStream(id: $id, title: $title, description: $description, slug: $slug, type: $type, visibility: $visibility, status: $status, roomName: $roomName, ingressId: $ingressId, ingressStreamKey: $ingressStreamKey, egressId: $egressId, hlsEgressId: $hlsEgressId, hlsPlaylistPath: $hlsPlaylistPath, hlsStartedAt: $hlsStartedAt, startedAt: $startedAt, endedAt: $endedAt, viewerCount: $viewerCount, peakViewerCount: $peakViewerCount, thumbnail: $thumbnail, metadata: $metadata, publisherId: $publisherId, publisher: $publisher, resourceIdentifier: $resourceIdentifier, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnLiveStreamCopyWith<$Res> implements $SnLiveStreamCopyWith<$Res> {
  factory _$SnLiveStreamCopyWith(_SnLiveStream value, $Res Function(_SnLiveStream) _then) = __$SnLiveStreamCopyWithImpl;
@override @useResult
$Res call({
 String id, String? title, String? description, String? slug, SnLiveStreamType type, SnLiveStreamVisibility visibility, SnLiveStreamStatus status, String roomName, String? ingressId, String? ingressStreamKey, String? egressId, String? hlsEgressId, String? hlsPlaylistPath, DateTime? hlsStartedAt, DateTime? startedAt, DateTime? endedAt, int viewerCount, int peakViewerCount, SnCloudFileReference? thumbnail, Map<String, dynamic>? metadata, String? publisherId, SnPublisher? publisher, String? resourceIdentifier, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});


@override $SnCloudFileReferenceCopyWith<$Res>? get thumbnail;@override $SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class __$SnLiveStreamCopyWithImpl<$Res>
    implements _$SnLiveStreamCopyWith<$Res> {
  __$SnLiveStreamCopyWithImpl(this._self, this._then);

  final _SnLiveStream _self;
  final $Res Function(_SnLiveStream) _then;

/// Create a copy of SnLiveStream
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? description = freezed,Object? slug = freezed,Object? type = null,Object? visibility = null,Object? status = null,Object? roomName = null,Object? ingressId = freezed,Object? ingressStreamKey = freezed,Object? egressId = freezed,Object? hlsEgressId = freezed,Object? hlsPlaylistPath = freezed,Object? hlsStartedAt = freezed,Object? startedAt = freezed,Object? endedAt = freezed,Object? viewerCount = null,Object? peakViewerCount = null,Object? thumbnail = freezed,Object? metadata = freezed,Object? publisherId = freezed,Object? publisher = freezed,Object? resourceIdentifier = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_SnLiveStream(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SnLiveStreamType,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as SnLiveStreamVisibility,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnLiveStreamStatus,roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,ingressId: freezed == ingressId ? _self.ingressId : ingressId // ignore: cast_nullable_to_non_nullable
as String?,ingressStreamKey: freezed == ingressStreamKey ? _self.ingressStreamKey : ingressStreamKey // ignore: cast_nullable_to_non_nullable
as String?,egressId: freezed == egressId ? _self.egressId : egressId // ignore: cast_nullable_to_non_nullable
as String?,hlsEgressId: freezed == hlsEgressId ? _self.hlsEgressId : hlsEgressId // ignore: cast_nullable_to_non_nullable
as String?,hlsPlaylistPath: freezed == hlsPlaylistPath ? _self.hlsPlaylistPath : hlsPlaylistPath // ignore: cast_nullable_to_non_nullable
as String?,hlsStartedAt: freezed == hlsStartedAt ? _self.hlsStartedAt : hlsStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,peakViewerCount: null == peakViewerCount ? _self.peakViewerCount : peakViewerCount // ignore: cast_nullable_to_non_nullable
as int,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,publisherId: freezed == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,resourceIdentifier: freezed == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnLiveStream
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get thumbnail {
    if (_self.thumbnail == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.thumbnail!, (value) {
    return _then(_self.copyWith(thumbnail: value));
  });
}/// Create a copy of SnLiveStream
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
}
}

// dart format on
