// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'developer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnDeveloper {

 String get id; String get publisherId; SnPublisher? get publisher;
/// Create a copy of SnDeveloper
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnDeveloperCopyWith<SnDeveloper> get copyWith => _$SnDeveloperCopyWithImpl<SnDeveloper>(this as SnDeveloper, _$identity);

  /// Serializes this SnDeveloper to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnDeveloper&&(identical(other.id, id) || other.id == id)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publisherId,publisher);

@override
String toString() {
  return 'SnDeveloper(id: $id, publisherId: $publisherId, publisher: $publisher)';
}


}

/// @nodoc
abstract mixin class $SnDeveloperCopyWith<$Res>  {
  factory $SnDeveloperCopyWith(SnDeveloper value, $Res Function(SnDeveloper) _then) = _$SnDeveloperCopyWithImpl;
@useResult
$Res call({
 String id, String publisherId, SnPublisher? publisher
});


$SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class _$SnDeveloperCopyWithImpl<$Res>
    implements $SnDeveloperCopyWith<$Res> {
  _$SnDeveloperCopyWithImpl(this._self, this._then);

  final SnDeveloper _self;
  final $Res Function(SnDeveloper) _then;

/// Create a copy of SnDeveloper
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publisherId = null,Object? publisher = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,
  ));
}
/// Create a copy of SnDeveloper
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


/// Adds pattern-matching-related methods to [SnDeveloper].
extension SnDeveloperPatterns on SnDeveloper {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnDeveloper value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnDeveloper() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnDeveloper value)  $default,){
final _that = this;
switch (_that) {
case _SnDeveloper():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnDeveloper value)?  $default,){
final _that = this;
switch (_that) {
case _SnDeveloper() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String publisherId,  SnPublisher? publisher)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnDeveloper() when $default != null:
return $default(_that.id,_that.publisherId,_that.publisher);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String publisherId,  SnPublisher? publisher)  $default,) {final _that = this;
switch (_that) {
case _SnDeveloper():
return $default(_that.id,_that.publisherId,_that.publisher);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String publisherId,  SnPublisher? publisher)?  $default,) {final _that = this;
switch (_that) {
case _SnDeveloper() when $default != null:
return $default(_that.id,_that.publisherId,_that.publisher);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnDeveloper implements SnDeveloper {
  const _SnDeveloper({required this.id, required this.publisherId, this.publisher});
  factory _SnDeveloper.fromJson(Map<String, dynamic> json) => _$SnDeveloperFromJson(json);

@override final  String id;
@override final  String publisherId;
@override final  SnPublisher? publisher;

/// Create a copy of SnDeveloper
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnDeveloperCopyWith<_SnDeveloper> get copyWith => __$SnDeveloperCopyWithImpl<_SnDeveloper>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnDeveloperToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnDeveloper&&(identical(other.id, id) || other.id == id)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publisherId,publisher);

@override
String toString() {
  return 'SnDeveloper(id: $id, publisherId: $publisherId, publisher: $publisher)';
}


}

/// @nodoc
abstract mixin class _$SnDeveloperCopyWith<$Res> implements $SnDeveloperCopyWith<$Res> {
  factory _$SnDeveloperCopyWith(_SnDeveloper value, $Res Function(_SnDeveloper) _then) = __$SnDeveloperCopyWithImpl;
@override @useResult
$Res call({
 String id, String publisherId, SnPublisher? publisher
});


@override $SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class __$SnDeveloperCopyWithImpl<$Res>
    implements _$SnDeveloperCopyWith<$Res> {
  __$SnDeveloperCopyWithImpl(this._self, this._then);

  final _SnDeveloper _self;
  final $Res Function(_SnDeveloper) _then;

/// Create a copy of SnDeveloper
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publisherId = null,Object? publisher = freezed,}) {
  return _then(_SnDeveloper(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,
  ));
}

/// Create a copy of SnDeveloper
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


/// @nodoc
mixin _$DeveloperStats {

 int get totalCustomApps;
/// Create a copy of DeveloperStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeveloperStatsCopyWith<DeveloperStats> get copyWith => _$DeveloperStatsCopyWithImpl<DeveloperStats>(this as DeveloperStats, _$identity);

  /// Serializes this DeveloperStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeveloperStats&&(identical(other.totalCustomApps, totalCustomApps) || other.totalCustomApps == totalCustomApps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCustomApps);

@override
String toString() {
  return 'DeveloperStats(totalCustomApps: $totalCustomApps)';
}


}

/// @nodoc
abstract mixin class $DeveloperStatsCopyWith<$Res>  {
  factory $DeveloperStatsCopyWith(DeveloperStats value, $Res Function(DeveloperStats) _then) = _$DeveloperStatsCopyWithImpl;
@useResult
$Res call({
 int totalCustomApps
});




}
/// @nodoc
class _$DeveloperStatsCopyWithImpl<$Res>
    implements $DeveloperStatsCopyWith<$Res> {
  _$DeveloperStatsCopyWithImpl(this._self, this._then);

  final DeveloperStats _self;
  final $Res Function(DeveloperStats) _then;

/// Create a copy of DeveloperStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCustomApps = null,}) {
  return _then(_self.copyWith(
totalCustomApps: null == totalCustomApps ? _self.totalCustomApps : totalCustomApps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DeveloperStats].
extension DeveloperStatsPatterns on DeveloperStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeveloperStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeveloperStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeveloperStats value)  $default,){
final _that = this;
switch (_that) {
case _DeveloperStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeveloperStats value)?  $default,){
final _that = this;
switch (_that) {
case _DeveloperStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCustomApps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeveloperStats() when $default != null:
return $default(_that.totalCustomApps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCustomApps)  $default,) {final _that = this;
switch (_that) {
case _DeveloperStats():
return $default(_that.totalCustomApps);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCustomApps)?  $default,) {final _that = this;
switch (_that) {
case _DeveloperStats() when $default != null:
return $default(_that.totalCustomApps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeveloperStats implements DeveloperStats {
  const _DeveloperStats({this.totalCustomApps = 0});
  factory _DeveloperStats.fromJson(Map<String, dynamic> json) => _$DeveloperStatsFromJson(json);

@override@JsonKey() final  int totalCustomApps;

/// Create a copy of DeveloperStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeveloperStatsCopyWith<_DeveloperStats> get copyWith => __$DeveloperStatsCopyWithImpl<_DeveloperStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeveloperStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeveloperStats&&(identical(other.totalCustomApps, totalCustomApps) || other.totalCustomApps == totalCustomApps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCustomApps);

@override
String toString() {
  return 'DeveloperStats(totalCustomApps: $totalCustomApps)';
}


}

/// @nodoc
abstract mixin class _$DeveloperStatsCopyWith<$Res> implements $DeveloperStatsCopyWith<$Res> {
  factory _$DeveloperStatsCopyWith(_DeveloperStats value, $Res Function(_DeveloperStats) _then) = __$DeveloperStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalCustomApps
});




}
/// @nodoc
class __$DeveloperStatsCopyWithImpl<$Res>
    implements _$DeveloperStatsCopyWith<$Res> {
  __$DeveloperStatsCopyWithImpl(this._self, this._then);

  final _DeveloperStats _self;
  final $Res Function(_DeveloperStats) _then;

/// Create a copy of DeveloperStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCustomApps = null,}) {
  return _then(_DeveloperStats(
totalCustomApps: null == totalCustomApps ? _self.totalCustomApps : totalCustomApps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
