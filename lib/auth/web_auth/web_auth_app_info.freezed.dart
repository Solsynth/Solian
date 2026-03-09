// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'web_auth_app_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WebAuthAppInfo {

 String get id; String get slug; String get name; String get description; int get status; SnCloudFile? get picture; SnCloudFile? get background; SnVerificationMark? get verification; Map<String, String?> get links; String get projectId; SnDevProject get project; String get resourceIdentifier; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of WebAuthAppInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebAuthAppInfoCopyWith<WebAuthAppInfo> get copyWith => _$WebAuthAppInfoCopyWithImpl<WebAuthAppInfo>(this as WebAuthAppInfo, _$identity);

  /// Serializes this WebAuthAppInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebAuthAppInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&const DeepCollectionEquality().equals(other.links, links)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.project, project) || other.project == project)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,status,picture,background,verification,const DeepCollectionEquality().hash(links),projectId,project,resourceIdentifier,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'WebAuthAppInfo(id: $id, slug: $slug, name: $name, description: $description, status: $status, picture: $picture, background: $background, verification: $verification, links: $links, projectId: $projectId, project: $project, resourceIdentifier: $resourceIdentifier, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $WebAuthAppInfoCopyWith<$Res>  {
  factory $WebAuthAppInfoCopyWith(WebAuthAppInfo value, $Res Function(WebAuthAppInfo) _then) = _$WebAuthAppInfoCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String description, int status, SnCloudFile? picture, SnCloudFile? background, SnVerificationMark? verification, Map<String, String?> links, String projectId, SnDevProject project, String resourceIdentifier, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnCloudFileCopyWith<$Res>? get picture;$SnCloudFileCopyWith<$Res>? get background;$SnVerificationMarkCopyWith<$Res>? get verification;$SnDevProjectCopyWith<$Res> get project;

}
/// @nodoc
class _$WebAuthAppInfoCopyWithImpl<$Res>
    implements $WebAuthAppInfoCopyWith<$Res> {
  _$WebAuthAppInfoCopyWithImpl(this._self, this._then);

  final WebAuthAppInfo _self;
  final $Res Function(WebAuthAppInfo) _then;

/// Create a copy of WebAuthAppInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = null,Object? status = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? links = null,Object? projectId = null,Object? project = null,Object? resourceIdentifier = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as Map<String, String?>,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as SnDevProject,resourceIdentifier: null == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of WebAuthAppInfo
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
}/// Create a copy of WebAuthAppInfo
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
}/// Create a copy of WebAuthAppInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}/// Create a copy of WebAuthAppInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnDevProjectCopyWith<$Res> get project {
  
  return $SnDevProjectCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}


/// Adds pattern-matching-related methods to [WebAuthAppInfo].
extension WebAuthAppInfoPatterns on WebAuthAppInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebAuthAppInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebAuthAppInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebAuthAppInfo value)  $default,){
final _that = this;
switch (_that) {
case _WebAuthAppInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebAuthAppInfo value)?  $default,){
final _that = this;
switch (_that) {
case _WebAuthAppInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String description,  int status,  SnCloudFile? picture,  SnCloudFile? background,  SnVerificationMark? verification,  Map<String, String?> links,  String projectId,  SnDevProject project,  String resourceIdentifier,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebAuthAppInfo() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.status,_that.picture,_that.background,_that.verification,_that.links,_that.projectId,_that.project,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String description,  int status,  SnCloudFile? picture,  SnCloudFile? background,  SnVerificationMark? verification,  Map<String, String?> links,  String projectId,  SnDevProject project,  String resourceIdentifier,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _WebAuthAppInfo():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.status,_that.picture,_that.background,_that.verification,_that.links,_that.projectId,_that.project,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String description,  int status,  SnCloudFile? picture,  SnCloudFile? background,  SnVerificationMark? verification,  Map<String, String?> links,  String projectId,  SnDevProject project,  String resourceIdentifier,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _WebAuthAppInfo() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.status,_that.picture,_that.background,_that.verification,_that.links,_that.projectId,_that.project,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WebAuthAppInfo implements WebAuthAppInfo {
  const _WebAuthAppInfo({required this.id, required this.slug, required this.name, required this.description, required this.status, required this.picture, required this.background, required this.verification, required final  Map<String, String?> links, required this.projectId, required this.project, required this.resourceIdentifier, required this.createdAt, required this.updatedAt, required this.deletedAt}): _links = links;
  factory _WebAuthAppInfo.fromJson(Map<String, dynamic> json) => _$WebAuthAppInfoFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override final  String description;
@override final  int status;
@override final  SnCloudFile? picture;
@override final  SnCloudFile? background;
@override final  SnVerificationMark? verification;
 final  Map<String, String?> _links;
@override Map<String, String?> get links {
  if (_links is EqualUnmodifiableMapView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_links);
}

@override final  String projectId;
@override final  SnDevProject project;
@override final  String resourceIdentifier;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of WebAuthAppInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebAuthAppInfoCopyWith<_WebAuthAppInfo> get copyWith => __$WebAuthAppInfoCopyWithImpl<_WebAuthAppInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebAuthAppInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebAuthAppInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&const DeepCollectionEquality().equals(other._links, _links)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.project, project) || other.project == project)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,status,picture,background,verification,const DeepCollectionEquality().hash(_links),projectId,project,resourceIdentifier,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'WebAuthAppInfo(id: $id, slug: $slug, name: $name, description: $description, status: $status, picture: $picture, background: $background, verification: $verification, links: $links, projectId: $projectId, project: $project, resourceIdentifier: $resourceIdentifier, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$WebAuthAppInfoCopyWith<$Res> implements $WebAuthAppInfoCopyWith<$Res> {
  factory _$WebAuthAppInfoCopyWith(_WebAuthAppInfo value, $Res Function(_WebAuthAppInfo) _then) = __$WebAuthAppInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String description, int status, SnCloudFile? picture, SnCloudFile? background, SnVerificationMark? verification, Map<String, String?> links, String projectId, SnDevProject project, String resourceIdentifier, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnCloudFileCopyWith<$Res>? get picture;@override $SnCloudFileCopyWith<$Res>? get background;@override $SnVerificationMarkCopyWith<$Res>? get verification;@override $SnDevProjectCopyWith<$Res> get project;

}
/// @nodoc
class __$WebAuthAppInfoCopyWithImpl<$Res>
    implements _$WebAuthAppInfoCopyWith<$Res> {
  __$WebAuthAppInfoCopyWithImpl(this._self, this._then);

  final _WebAuthAppInfo _self;
  final $Res Function(_WebAuthAppInfo) _then;

/// Create a copy of WebAuthAppInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = null,Object? status = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? links = null,Object? projectId = null,Object? project = null,Object? resourceIdentifier = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_WebAuthAppInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as Map<String, String?>,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as SnDevProject,resourceIdentifier: null == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of WebAuthAppInfo
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
}/// Create a copy of WebAuthAppInfo
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
}/// Create a copy of WebAuthAppInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}/// Create a copy of WebAuthAppInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnDevProjectCopyWith<$Res> get project {
  
  return $SnDevProjectCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

// dart format on
