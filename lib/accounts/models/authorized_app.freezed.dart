// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authorized_app.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthorizedApp {

 String get id; int get type;@JsonKey(name: 'app_id') String get appId;@JsonKey(name: 'app_slug') String? get appSlug;@JsonKey(name: 'app_name') String? get appName;@JsonKey(name: 'app_description') String? get appDescription; SnCloudFileReference? get picture; SnCloudFileReference? get background; List<String> get scopes;@JsonKey(name: 'last_authorized_at') String? get lastAuthorizedAt;@JsonKey(name: 'last_used_at') String? get lastUsedAt;
/// Create a copy of AuthorizedApp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorizedAppCopyWith<AuthorizedApp> get copyWith => _$AuthorizedAppCopyWithImpl<AuthorizedApp>(this as AuthorizedApp, _$identity);

  /// Serializes this AuthorizedApp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorizedApp&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.appSlug, appSlug) || other.appSlug == appSlug)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.appDescription, appDescription) || other.appDescription == appDescription)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&const DeepCollectionEquality().equals(other.scopes, scopes)&&(identical(other.lastAuthorizedAt, lastAuthorizedAt) || other.lastAuthorizedAt == lastAuthorizedAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,appId,appSlug,appName,appDescription,picture,background,const DeepCollectionEquality().hash(scopes),lastAuthorizedAt,lastUsedAt);

@override
String toString() {
  return 'AuthorizedApp(id: $id, type: $type, appId: $appId, appSlug: $appSlug, appName: $appName, appDescription: $appDescription, picture: $picture, background: $background, scopes: $scopes, lastAuthorizedAt: $lastAuthorizedAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class $AuthorizedAppCopyWith<$Res>  {
  factory $AuthorizedAppCopyWith(AuthorizedApp value, $Res Function(AuthorizedApp) _then) = _$AuthorizedAppCopyWithImpl;
@useResult
$Res call({
 String id, int type,@JsonKey(name: 'app_id') String appId,@JsonKey(name: 'app_slug') String? appSlug,@JsonKey(name: 'app_name') String? appName,@JsonKey(name: 'app_description') String? appDescription, SnCloudFileReference? picture, SnCloudFileReference? background, List<String> scopes,@JsonKey(name: 'last_authorized_at') String? lastAuthorizedAt,@JsonKey(name: 'last_used_at') String? lastUsedAt
});


$SnCloudFileReferenceCopyWith<$Res>? get picture;$SnCloudFileReferenceCopyWith<$Res>? get background;

}
/// @nodoc
class _$AuthorizedAppCopyWithImpl<$Res>
    implements $AuthorizedAppCopyWith<$Res> {
  _$AuthorizedAppCopyWithImpl(this._self, this._then);

  final AuthorizedApp _self;
  final $Res Function(AuthorizedApp) _then;

/// Create a copy of AuthorizedApp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? appId = null,Object? appSlug = freezed,Object? appName = freezed,Object? appDescription = freezed,Object? picture = freezed,Object? background = freezed,Object? scopes = null,Object? lastAuthorizedAt = freezed,Object? lastUsedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,appSlug: freezed == appSlug ? _self.appSlug : appSlug // ignore: cast_nullable_to_non_nullable
as String?,appName: freezed == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String?,appDescription: freezed == appDescription ? _self.appDescription : appDescription // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,scopes: null == scopes ? _self.scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,lastAuthorizedAt: freezed == lastAuthorizedAt ? _self.lastAuthorizedAt : lastAuthorizedAt // ignore: cast_nullable_to_non_nullable
as String?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AuthorizedApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of AuthorizedApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthorizedApp].
extension AuthorizedAppPatterns on AuthorizedApp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthorizedApp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthorizedApp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthorizedApp value)  $default,){
final _that = this;
switch (_that) {
case _AuthorizedApp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthorizedApp value)?  $default,){
final _that = this;
switch (_that) {
case _AuthorizedApp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int type, @JsonKey(name: 'app_id')  String appId, @JsonKey(name: 'app_slug')  String? appSlug, @JsonKey(name: 'app_name')  String? appName, @JsonKey(name: 'app_description')  String? appDescription,  SnCloudFileReference? picture,  SnCloudFileReference? background,  List<String> scopes, @JsonKey(name: 'last_authorized_at')  String? lastAuthorizedAt, @JsonKey(name: 'last_used_at')  String? lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthorizedApp() when $default != null:
return $default(_that.id,_that.type,_that.appId,_that.appSlug,_that.appName,_that.appDescription,_that.picture,_that.background,_that.scopes,_that.lastAuthorizedAt,_that.lastUsedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int type, @JsonKey(name: 'app_id')  String appId, @JsonKey(name: 'app_slug')  String? appSlug, @JsonKey(name: 'app_name')  String? appName, @JsonKey(name: 'app_description')  String? appDescription,  SnCloudFileReference? picture,  SnCloudFileReference? background,  List<String> scopes, @JsonKey(name: 'last_authorized_at')  String? lastAuthorizedAt, @JsonKey(name: 'last_used_at')  String? lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _AuthorizedApp():
return $default(_that.id,_that.type,_that.appId,_that.appSlug,_that.appName,_that.appDescription,_that.picture,_that.background,_that.scopes,_that.lastAuthorizedAt,_that.lastUsedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int type, @JsonKey(name: 'app_id')  String appId, @JsonKey(name: 'app_slug')  String? appSlug, @JsonKey(name: 'app_name')  String? appName, @JsonKey(name: 'app_description')  String? appDescription,  SnCloudFileReference? picture,  SnCloudFileReference? background,  List<String> scopes, @JsonKey(name: 'last_authorized_at')  String? lastAuthorizedAt, @JsonKey(name: 'last_used_at')  String? lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _AuthorizedApp() when $default != null:
return $default(_that.id,_that.type,_that.appId,_that.appSlug,_that.appName,_that.appDescription,_that.picture,_that.background,_that.scopes,_that.lastAuthorizedAt,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthorizedApp implements AuthorizedApp {
  const _AuthorizedApp({required this.id, this.type = 0, @JsonKey(name: 'app_id') required this.appId, @JsonKey(name: 'app_slug') this.appSlug, @JsonKey(name: 'app_name') this.appName, @JsonKey(name: 'app_description') this.appDescription, required this.picture, required this.background, final  List<String> scopes = const [], @JsonKey(name: 'last_authorized_at') this.lastAuthorizedAt, @JsonKey(name: 'last_used_at') this.lastUsedAt}): _scopes = scopes;
  factory _AuthorizedApp.fromJson(Map<String, dynamic> json) => _$AuthorizedAppFromJson(json);

@override final  String id;
@override@JsonKey() final  int type;
@override@JsonKey(name: 'app_id') final  String appId;
@override@JsonKey(name: 'app_slug') final  String? appSlug;
@override@JsonKey(name: 'app_name') final  String? appName;
@override@JsonKey(name: 'app_description') final  String? appDescription;
@override final  SnCloudFileReference? picture;
@override final  SnCloudFileReference? background;
 final  List<String> _scopes;
@override@JsonKey() List<String> get scopes {
  if (_scopes is EqualUnmodifiableListView) return _scopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scopes);
}

@override@JsonKey(name: 'last_authorized_at') final  String? lastAuthorizedAt;
@override@JsonKey(name: 'last_used_at') final  String? lastUsedAt;

/// Create a copy of AuthorizedApp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorizedAppCopyWith<_AuthorizedApp> get copyWith => __$AuthorizedAppCopyWithImpl<_AuthorizedApp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthorizedAppToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthorizedApp&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.appSlug, appSlug) || other.appSlug == appSlug)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.appDescription, appDescription) || other.appDescription == appDescription)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&const DeepCollectionEquality().equals(other._scopes, _scopes)&&(identical(other.lastAuthorizedAt, lastAuthorizedAt) || other.lastAuthorizedAt == lastAuthorizedAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,appId,appSlug,appName,appDescription,picture,background,const DeepCollectionEquality().hash(_scopes),lastAuthorizedAt,lastUsedAt);

@override
String toString() {
  return 'AuthorizedApp(id: $id, type: $type, appId: $appId, appSlug: $appSlug, appName: $appName, appDescription: $appDescription, picture: $picture, background: $background, scopes: $scopes, lastAuthorizedAt: $lastAuthorizedAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$AuthorizedAppCopyWith<$Res> implements $AuthorizedAppCopyWith<$Res> {
  factory _$AuthorizedAppCopyWith(_AuthorizedApp value, $Res Function(_AuthorizedApp) _then) = __$AuthorizedAppCopyWithImpl;
@override @useResult
$Res call({
 String id, int type,@JsonKey(name: 'app_id') String appId,@JsonKey(name: 'app_slug') String? appSlug,@JsonKey(name: 'app_name') String? appName,@JsonKey(name: 'app_description') String? appDescription, SnCloudFileReference? picture, SnCloudFileReference? background, List<String> scopes,@JsonKey(name: 'last_authorized_at') String? lastAuthorizedAt,@JsonKey(name: 'last_used_at') String? lastUsedAt
});


@override $SnCloudFileReferenceCopyWith<$Res>? get picture;@override $SnCloudFileReferenceCopyWith<$Res>? get background;

}
/// @nodoc
class __$AuthorizedAppCopyWithImpl<$Res>
    implements _$AuthorizedAppCopyWith<$Res> {
  __$AuthorizedAppCopyWithImpl(this._self, this._then);

  final _AuthorizedApp _self;
  final $Res Function(_AuthorizedApp) _then;

/// Create a copy of AuthorizedApp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? appId = null,Object? appSlug = freezed,Object? appName = freezed,Object? appDescription = freezed,Object? picture = freezed,Object? background = freezed,Object? scopes = null,Object? lastAuthorizedAt = freezed,Object? lastUsedAt = freezed,}) {
  return _then(_AuthorizedApp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,appSlug: freezed == appSlug ? _self.appSlug : appSlug // ignore: cast_nullable_to_non_nullable
as String?,appName: freezed == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String?,appDescription: freezed == appDescription ? _self.appDescription : appDescription // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,scopes: null == scopes ? _self._scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,lastAuthorizedAt: freezed == lastAuthorizedAt ? _self.lastAuthorizedAt : lastAuthorizedAt // ignore: cast_nullable_to_non_nullable
as String?,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AuthorizedApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of AuthorizedApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}
}

// dart format on
