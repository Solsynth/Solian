// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'misc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppToken {

 String get token;
/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTokenCopyWith<AppToken> get copyWith => _$AppTokenCopyWithImpl<AppToken>(this as AppToken, _$identity);

  /// Serializes this AppToken to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppToken&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'AppToken(token: $token)';
}


}

/// @nodoc
abstract mixin class $AppTokenCopyWith<$Res>  {
  factory $AppTokenCopyWith(AppToken value, $Res Function(AppToken) _then) = _$AppTokenCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$AppTokenCopyWithImpl<$Res>
    implements $AppTokenCopyWith<$Res> {
  _$AppTokenCopyWithImpl(this._self, this._then);

  final AppToken _self;
  final $Res Function(AppToken) _then;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppToken].
extension AppTokenPatterns on AppToken {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppToken value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppToken() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppToken value)  $default,){
final _that = this;
switch (_that) {
case _AppToken():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppToken value)?  $default,){
final _that = this;
switch (_that) {
case _AppToken() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppToken() when $default != null:
return $default(_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token)  $default,) {final _that = this;
switch (_that) {
case _AppToken():
return $default(_that.token);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token)?  $default,) {final _that = this;
switch (_that) {
case _AppToken() when $default != null:
return $default(_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppToken implements AppToken {
  const _AppToken({required this.token});
  factory _AppToken.fromJson(Map<String, dynamic> json) => _$AppTokenFromJson(json);

@override final  String token;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTokenCopyWith<_AppToken> get copyWith => __$AppTokenCopyWithImpl<_AppToken>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppTokenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppToken&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'AppToken(token: $token)';
}


}

/// @nodoc
abstract mixin class _$AppTokenCopyWith<$Res> implements $AppTokenCopyWith<$Res> {
  factory _$AppTokenCopyWith(_AppToken value, $Res Function(_AppToken) _then) = __$AppTokenCopyWithImpl;
@override @useResult
$Res call({
 String token
});




}
/// @nodoc
class __$AppTokenCopyWithImpl<$Res>
    implements _$AppTokenCopyWith<$Res> {
  __$AppTokenCopyWithImpl(this._self, this._then);

  final _AppToken _self;
  final $Res Function(_AppToken) _then;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(_AppToken(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GeoIpLocation {

 double? get latitude; double? get longitude; String? get countryCode; String? get country; String? get city;
/// Create a copy of GeoIpLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeoIpLocationCopyWith<GeoIpLocation> get copyWith => _$GeoIpLocationCopyWithImpl<GeoIpLocation>(this as GeoIpLocation, _$identity);

  /// Serializes this GeoIpLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeoIpLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,countryCode,country,city);

@override
String toString() {
  return 'GeoIpLocation(latitude: $latitude, longitude: $longitude, countryCode: $countryCode, country: $country, city: $city)';
}


}

/// @nodoc
abstract mixin class $GeoIpLocationCopyWith<$Res>  {
  factory $GeoIpLocationCopyWith(GeoIpLocation value, $Res Function(GeoIpLocation) _then) = _$GeoIpLocationCopyWithImpl;
@useResult
$Res call({
 double? latitude, double? longitude, String? countryCode, String? country, String? city
});




}
/// @nodoc
class _$GeoIpLocationCopyWithImpl<$Res>
    implements $GeoIpLocationCopyWith<$Res> {
  _$GeoIpLocationCopyWithImpl(this._self, this._then);

  final GeoIpLocation _self;
  final $Res Function(GeoIpLocation) _then;

/// Create a copy of GeoIpLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = freezed,Object? longitude = freezed,Object? countryCode = freezed,Object? country = freezed,Object? city = freezed,}) {
  return _then(_self.copyWith(
latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GeoIpLocation].
extension GeoIpLocationPatterns on GeoIpLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeoIpLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeoIpLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeoIpLocation value)  $default,){
final _that = this;
switch (_that) {
case _GeoIpLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeoIpLocation value)?  $default,){
final _that = this;
switch (_that) {
case _GeoIpLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? latitude,  double? longitude,  String? countryCode,  String? country,  String? city)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeoIpLocation() when $default != null:
return $default(_that.latitude,_that.longitude,_that.countryCode,_that.country,_that.city);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? latitude,  double? longitude,  String? countryCode,  String? country,  String? city)  $default,) {final _that = this;
switch (_that) {
case _GeoIpLocation():
return $default(_that.latitude,_that.longitude,_that.countryCode,_that.country,_that.city);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? latitude,  double? longitude,  String? countryCode,  String? country,  String? city)?  $default,) {final _that = this;
switch (_that) {
case _GeoIpLocation() when $default != null:
return $default(_that.latitude,_that.longitude,_that.countryCode,_that.country,_that.city);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeoIpLocation implements GeoIpLocation {
  const _GeoIpLocation({required this.latitude, required this.longitude, required this.countryCode, required this.country, required this.city});
  factory _GeoIpLocation.fromJson(Map<String, dynamic> json) => _$GeoIpLocationFromJson(json);

@override final  double? latitude;
@override final  double? longitude;
@override final  String? countryCode;
@override final  String? country;
@override final  String? city;

/// Create a copy of GeoIpLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeoIpLocationCopyWith<_GeoIpLocation> get copyWith => __$GeoIpLocationCopyWithImpl<_GeoIpLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeoIpLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeoIpLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,countryCode,country,city);

@override
String toString() {
  return 'GeoIpLocation(latitude: $latitude, longitude: $longitude, countryCode: $countryCode, country: $country, city: $city)';
}


}

/// @nodoc
abstract mixin class _$GeoIpLocationCopyWith<$Res> implements $GeoIpLocationCopyWith<$Res> {
  factory _$GeoIpLocationCopyWith(_GeoIpLocation value, $Res Function(_GeoIpLocation) _then) = __$GeoIpLocationCopyWithImpl;
@override @useResult
$Res call({
 double? latitude, double? longitude, String? countryCode, String? country, String? city
});




}
/// @nodoc
class __$GeoIpLocationCopyWithImpl<$Res>
    implements _$GeoIpLocationCopyWith<$Res> {
  __$GeoIpLocationCopyWithImpl(this._self, this._then);

  final _GeoIpLocation _self;
  final $Res Function(_GeoIpLocation) _then;

/// Create a copy of GeoIpLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = freezed,Object? longitude = freezed,Object? countryCode = freezed,Object? country = freezed,Object? city = freezed,}) {
  return _then(_GeoIpLocation(
latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnAuthFactor {

 String get id; int get type; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; DateTime? get expiredAt; DateTime? get enabledAt; int get trustworthy; Map<String, dynamic>? get createdResponse;
/// Create a copy of SnAuthFactor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthFactorCopyWith<SnAuthFactor> get copyWith => _$SnAuthFactorCopyWithImpl<SnAuthFactor>(this as SnAuthFactor, _$identity);

  /// Serializes this SnAuthFactor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthFactor&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.enabledAt, enabledAt) || other.enabledAt == enabledAt)&&(identical(other.trustworthy, trustworthy) || other.trustworthy == trustworthy)&&const DeepCollectionEquality().equals(other.createdResponse, createdResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,createdAt,updatedAt,deletedAt,expiredAt,enabledAt,trustworthy,const DeepCollectionEquality().hash(createdResponse));

@override
String toString() {
  return 'SnAuthFactor(id: $id, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiredAt: $expiredAt, enabledAt: $enabledAt, trustworthy: $trustworthy, createdResponse: $createdResponse)';
}


}

/// @nodoc
abstract mixin class $SnAuthFactorCopyWith<$Res>  {
  factory $SnAuthFactorCopyWith(SnAuthFactor value, $Res Function(SnAuthFactor) _then) = _$SnAuthFactorCopyWithImpl;
@useResult
$Res call({
 String id, int type, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, DateTime? expiredAt, DateTime? enabledAt, int trustworthy, Map<String, dynamic>? createdResponse
});




}
/// @nodoc
class _$SnAuthFactorCopyWithImpl<$Res>
    implements $SnAuthFactorCopyWith<$Res> {
  _$SnAuthFactorCopyWithImpl(this._self, this._then);

  final SnAuthFactor _self;
  final $Res Function(SnAuthFactor) _then;

/// Create a copy of SnAuthFactor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? expiredAt = freezed,Object? enabledAt = freezed,Object? trustworthy = null,Object? createdResponse = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,enabledAt: freezed == enabledAt ? _self.enabledAt : enabledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trustworthy: null == trustworthy ? _self.trustworthy : trustworthy // ignore: cast_nullable_to_non_nullable
as int,createdResponse: freezed == createdResponse ? _self.createdResponse : createdResponse // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAuthFactor].
extension SnAuthFactorPatterns on SnAuthFactor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAuthFactor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAuthFactor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAuthFactor value)  $default,){
final _that = this;
switch (_that) {
case _SnAuthFactor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAuthFactor value)?  $default,){
final _that = this;
switch (_that) {
case _SnAuthFactor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int type,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  DateTime? expiredAt,  DateTime? enabledAt,  int trustworthy,  Map<String, dynamic>? createdResponse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAuthFactor() when $default != null:
return $default(_that.id,_that.type,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiredAt,_that.enabledAt,_that.trustworthy,_that.createdResponse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int type,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  DateTime? expiredAt,  DateTime? enabledAt,  int trustworthy,  Map<String, dynamic>? createdResponse)  $default,) {final _that = this;
switch (_that) {
case _SnAuthFactor():
return $default(_that.id,_that.type,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiredAt,_that.enabledAt,_that.trustworthy,_that.createdResponse);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int type,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  DateTime? expiredAt,  DateTime? enabledAt,  int trustworthy,  Map<String, dynamic>? createdResponse)?  $default,) {final _that = this;
switch (_that) {
case _SnAuthFactor() when $default != null:
return $default(_that.id,_that.type,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.expiredAt,_that.enabledAt,_that.trustworthy,_that.createdResponse);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAuthFactor implements SnAuthFactor {
  const _SnAuthFactor({required this.id, required this.type, required this.createdAt, required this.updatedAt, required this.deletedAt, required this.expiredAt, required this.enabledAt, required this.trustworthy, required final  Map<String, dynamic>? createdResponse}): _createdResponse = createdResponse;
  factory _SnAuthFactor.fromJson(Map<String, dynamic> json) => _$SnAuthFactorFromJson(json);

@override final  String id;
@override final  int type;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  DateTime? expiredAt;
@override final  DateTime? enabledAt;
@override final  int trustworthy;
 final  Map<String, dynamic>? _createdResponse;
@override Map<String, dynamic>? get createdResponse {
  final value = _createdResponse;
  if (value == null) return null;
  if (_createdResponse is EqualUnmodifiableMapView) return _createdResponse;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SnAuthFactor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAuthFactorCopyWith<_SnAuthFactor> get copyWith => __$SnAuthFactorCopyWithImpl<_SnAuthFactor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAuthFactorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthFactor&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.enabledAt, enabledAt) || other.enabledAt == enabledAt)&&(identical(other.trustworthy, trustworthy) || other.trustworthy == trustworthy)&&const DeepCollectionEquality().equals(other._createdResponse, _createdResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,createdAt,updatedAt,deletedAt,expiredAt,enabledAt,trustworthy,const DeepCollectionEquality().hash(_createdResponse));

@override
String toString() {
  return 'SnAuthFactor(id: $id, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiredAt: $expiredAt, enabledAt: $enabledAt, trustworthy: $trustworthy, createdResponse: $createdResponse)';
}


}

/// @nodoc
abstract mixin class _$SnAuthFactorCopyWith<$Res> implements $SnAuthFactorCopyWith<$Res> {
  factory _$SnAuthFactorCopyWith(_SnAuthFactor value, $Res Function(_SnAuthFactor) _then) = __$SnAuthFactorCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, DateTime? expiredAt, DateTime? enabledAt, int trustworthy, Map<String, dynamic>? createdResponse
});




}
/// @nodoc
class __$SnAuthFactorCopyWithImpl<$Res>
    implements _$SnAuthFactorCopyWith<$Res> {
  __$SnAuthFactorCopyWithImpl(this._self, this._then);

  final _SnAuthFactor _self;
  final $Res Function(_SnAuthFactor) _then;

/// Create a copy of SnAuthFactor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? expiredAt = freezed,Object? enabledAt = freezed,Object? trustworthy = null,Object? createdResponse = freezed,}) {
  return _then(_SnAuthFactor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,enabledAt: freezed == enabledAt ? _self.enabledAt : enabledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trustworthy: null == trustworthy ? _self.trustworthy : trustworthy // ignore: cast_nullable_to_non_nullable
as int,createdResponse: freezed == createdResponse ? _self._createdResponse : createdResponse // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$SnAccountConnection {

 String get id; String get accountId; String get provider; String get providedIdentifier; bool get isPublic; Map<String, dynamic> get meta; DateTime get lastUsedAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccountConnection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountConnectionCopyWith<SnAccountConnection> get copyWith => _$SnAccountConnectionCopyWithImpl<SnAccountConnection>(this as SnAccountConnection, _$identity);

  /// Serializes this SnAccountConnection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountConnection&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.providedIdentifier, providedIdentifier) || other.providedIdentifier == providedIdentifier)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,provider,providedIdentifier,isPublic,const DeepCollectionEquality().hash(meta),lastUsedAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountConnection(id: $id, accountId: $accountId, provider: $provider, providedIdentifier: $providedIdentifier, isPublic: $isPublic, meta: $meta, lastUsedAt: $lastUsedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountConnectionCopyWith<$Res>  {
  factory $SnAccountConnectionCopyWith(SnAccountConnection value, $Res Function(SnAccountConnection) _then) = _$SnAccountConnectionCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String provider, String providedIdentifier, bool isPublic, Map<String, dynamic> meta, DateTime lastUsedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAccountConnectionCopyWithImpl<$Res>
    implements $SnAccountConnectionCopyWith<$Res> {
  _$SnAccountConnectionCopyWithImpl(this._self, this._then);

  final SnAccountConnection _self;
  final $Res Function(SnAccountConnection) _then;

/// Create a copy of SnAccountConnection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? provider = null,Object? providedIdentifier = null,Object? isPublic = null,Object? meta = null,Object? lastUsedAt = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,providedIdentifier: null == providedIdentifier ? _self.providedIdentifier : providedIdentifier // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAccountConnection].
extension SnAccountConnectionPatterns on SnAccountConnection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountConnection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountConnection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountConnection value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountConnection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountConnection value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountConnection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String provider,  String providedIdentifier,  bool isPublic,  Map<String, dynamic> meta,  DateTime lastUsedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountConnection() when $default != null:
return $default(_that.id,_that.accountId,_that.provider,_that.providedIdentifier,_that.isPublic,_that.meta,_that.lastUsedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String provider,  String providedIdentifier,  bool isPublic,  Map<String, dynamic> meta,  DateTime lastUsedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAccountConnection():
return $default(_that.id,_that.accountId,_that.provider,_that.providedIdentifier,_that.isPublic,_that.meta,_that.lastUsedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String provider,  String providedIdentifier,  bool isPublic,  Map<String, dynamic> meta,  DateTime lastUsedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountConnection() when $default != null:
return $default(_that.id,_that.accountId,_that.provider,_that.providedIdentifier,_that.isPublic,_that.meta,_that.lastUsedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountConnection implements SnAccountConnection {
  const _SnAccountConnection({required this.id, required this.accountId, required this.provider, required this.providedIdentifier, this.isPublic = false, final  Map<String, dynamic> meta = const {}, required this.lastUsedAt, required this.createdAt, required this.updatedAt, required this.deletedAt}): _meta = meta;
  factory _SnAccountConnection.fromJson(Map<String, dynamic> json) => _$SnAccountConnectionFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String provider;
@override final  String providedIdentifier;
@override@JsonKey() final  bool isPublic;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override final  DateTime lastUsedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccountConnection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountConnectionCopyWith<_SnAccountConnection> get copyWith => __$SnAccountConnectionCopyWithImpl<_SnAccountConnection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountConnectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountConnection&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.providedIdentifier, providedIdentifier) || other.providedIdentifier == providedIdentifier)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,provider,providedIdentifier,isPublic,const DeepCollectionEquality().hash(_meta),lastUsedAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountConnection(id: $id, accountId: $accountId, provider: $provider, providedIdentifier: $providedIdentifier, isPublic: $isPublic, meta: $meta, lastUsedAt: $lastUsedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountConnectionCopyWith<$Res> implements $SnAccountConnectionCopyWith<$Res> {
  factory _$SnAccountConnectionCopyWith(_SnAccountConnection value, $Res Function(_SnAccountConnection) _then) = __$SnAccountConnectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String provider, String providedIdentifier, bool isPublic, Map<String, dynamic> meta, DateTime lastUsedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAccountConnectionCopyWithImpl<$Res>
    implements _$SnAccountConnectionCopyWith<$Res> {
  __$SnAccountConnectionCopyWithImpl(this._self, this._then);

  final _SnAccountConnection _self;
  final $Res Function(_SnAccountConnection) _then;

/// Create a copy of SnAccountConnection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? provider = null,Object? providedIdentifier = null,Object? isPublic = null,Object? meta = null,Object? lastUsedAt = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccountConnection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,providedIdentifier: null == providedIdentifier ? _self.providedIdentifier : providedIdentifier // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
