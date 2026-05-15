// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progression.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnProgressBadgeRewardDefinition {

 String get type; String? get label; String? get caption; Map<String, dynamic>? get meta;
/// Create a copy of SnProgressBadgeRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnProgressBadgeRewardDefinitionCopyWith<SnProgressBadgeRewardDefinition> get copyWith => _$SnProgressBadgeRewardDefinitionCopyWithImpl<SnProgressBadgeRewardDefinition>(this as SnProgressBadgeRewardDefinition, _$identity);

  /// Serializes this SnProgressBadgeRewardDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnProgressBadgeRewardDefinition&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.meta, meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,label,caption,const DeepCollectionEquality().hash(meta));

@override
String toString() {
  return 'SnProgressBadgeRewardDefinition(type: $type, label: $label, caption: $caption, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $SnProgressBadgeRewardDefinitionCopyWith<$Res>  {
  factory $SnProgressBadgeRewardDefinitionCopyWith(SnProgressBadgeRewardDefinition value, $Res Function(SnProgressBadgeRewardDefinition) _then) = _$SnProgressBadgeRewardDefinitionCopyWithImpl;
@useResult
$Res call({
 String type, String? label, String? caption, Map<String, dynamic>? meta
});




}
/// @nodoc
class _$SnProgressBadgeRewardDefinitionCopyWithImpl<$Res>
    implements $SnProgressBadgeRewardDefinitionCopyWith<$Res> {
  _$SnProgressBadgeRewardDefinitionCopyWithImpl(this._self, this._then);

  final SnProgressBadgeRewardDefinition _self;
  final $Res Function(SnProgressBadgeRewardDefinition) _then;

/// Create a copy of SnProgressBadgeRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? label = freezed,Object? caption = freezed,Object? meta = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnProgressBadgeRewardDefinition].
extension SnProgressBadgeRewardDefinitionPatterns on SnProgressBadgeRewardDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnProgressBadgeRewardDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnProgressBadgeRewardDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnProgressBadgeRewardDefinition value)  $default,){
final _that = this;
switch (_that) {
case _SnProgressBadgeRewardDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnProgressBadgeRewardDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _SnProgressBadgeRewardDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? label,  String? caption,  Map<String, dynamic>? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnProgressBadgeRewardDefinition() when $default != null:
return $default(_that.type,_that.label,_that.caption,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? label,  String? caption,  Map<String, dynamic>? meta)  $default,) {final _that = this;
switch (_that) {
case _SnProgressBadgeRewardDefinition():
return $default(_that.type,_that.label,_that.caption,_that.meta);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? label,  String? caption,  Map<String, dynamic>? meta)?  $default,) {final _that = this;
switch (_that) {
case _SnProgressBadgeRewardDefinition() when $default != null:
return $default(_that.type,_that.label,_that.caption,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnProgressBadgeRewardDefinition implements SnProgressBadgeRewardDefinition {
  const _SnProgressBadgeRewardDefinition({required this.type, this.label, this.caption, final  Map<String, dynamic>? meta}): _meta = meta;
  factory _SnProgressBadgeRewardDefinition.fromJson(Map<String, dynamic> json) => _$SnProgressBadgeRewardDefinitionFromJson(json);

@override final  String type;
@override final  String? label;
@override final  String? caption;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SnProgressBadgeRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnProgressBadgeRewardDefinitionCopyWith<_SnProgressBadgeRewardDefinition> get copyWith => __$SnProgressBadgeRewardDefinitionCopyWithImpl<_SnProgressBadgeRewardDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnProgressBadgeRewardDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnProgressBadgeRewardDefinition&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other._meta, _meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,label,caption,const DeepCollectionEquality().hash(_meta));

@override
String toString() {
  return 'SnProgressBadgeRewardDefinition(type: $type, label: $label, caption: $caption, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$SnProgressBadgeRewardDefinitionCopyWith<$Res> implements $SnProgressBadgeRewardDefinitionCopyWith<$Res> {
  factory _$SnProgressBadgeRewardDefinitionCopyWith(_SnProgressBadgeRewardDefinition value, $Res Function(_SnProgressBadgeRewardDefinition) _then) = __$SnProgressBadgeRewardDefinitionCopyWithImpl;
@override @useResult
$Res call({
 String type, String? label, String? caption, Map<String, dynamic>? meta
});




}
/// @nodoc
class __$SnProgressBadgeRewardDefinitionCopyWithImpl<$Res>
    implements _$SnProgressBadgeRewardDefinitionCopyWith<$Res> {
  __$SnProgressBadgeRewardDefinitionCopyWithImpl(this._self, this._then);

  final _SnProgressBadgeRewardDefinition _self;
  final $Res Function(_SnProgressBadgeRewardDefinition) _then;

/// Create a copy of SnProgressBadgeRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? label = freezed,Object? caption = freezed,Object? meta = freezed,}) {
  return _then(_SnProgressBadgeRewardDefinition(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$SnProgressRewardDefinition {

 int get experience; num get sourcePoints; String get sourcePointsCurrency; SnProgressBadgeRewardDefinition? get badge;
/// Create a copy of SnProgressRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<SnProgressRewardDefinition> get copyWith => _$SnProgressRewardDefinitionCopyWithImpl<SnProgressRewardDefinition>(this as SnProgressRewardDefinition, _$identity);

  /// Serializes this SnProgressRewardDefinition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnProgressRewardDefinition&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.sourcePoints, sourcePoints) || other.sourcePoints == sourcePoints)&&(identical(other.sourcePointsCurrency, sourcePointsCurrency) || other.sourcePointsCurrency == sourcePointsCurrency)&&(identical(other.badge, badge) || other.badge == badge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,experience,sourcePoints,sourcePointsCurrency,badge);

@override
String toString() {
  return 'SnProgressRewardDefinition(experience: $experience, sourcePoints: $sourcePoints, sourcePointsCurrency: $sourcePointsCurrency, badge: $badge)';
}


}

/// @nodoc
abstract mixin class $SnProgressRewardDefinitionCopyWith<$Res>  {
  factory $SnProgressRewardDefinitionCopyWith(SnProgressRewardDefinition value, $Res Function(SnProgressRewardDefinition) _then) = _$SnProgressRewardDefinitionCopyWithImpl;
@useResult
$Res call({
 int experience, num sourcePoints, String sourcePointsCurrency, SnProgressBadgeRewardDefinition? badge
});


$SnProgressBadgeRewardDefinitionCopyWith<$Res>? get badge;

}
/// @nodoc
class _$SnProgressRewardDefinitionCopyWithImpl<$Res>
    implements $SnProgressRewardDefinitionCopyWith<$Res> {
  _$SnProgressRewardDefinitionCopyWithImpl(this._self, this._then);

  final SnProgressRewardDefinition _self;
  final $Res Function(SnProgressRewardDefinition) _then;

/// Create a copy of SnProgressRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? experience = null,Object? sourcePoints = null,Object? sourcePointsCurrency = null,Object? badge = freezed,}) {
  return _then(_self.copyWith(
experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,sourcePoints: null == sourcePoints ? _self.sourcePoints : sourcePoints // ignore: cast_nullable_to_non_nullable
as num,sourcePointsCurrency: null == sourcePointsCurrency ? _self.sourcePointsCurrency : sourcePointsCurrency // ignore: cast_nullable_to_non_nullable
as String,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as SnProgressBadgeRewardDefinition?,
  ));
}
/// Create a copy of SnProgressRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressBadgeRewardDefinitionCopyWith<$Res>? get badge {
    if (_self.badge == null) {
    return null;
  }

  return $SnProgressBadgeRewardDefinitionCopyWith<$Res>(_self.badge!, (value) {
    return _then(_self.copyWith(badge: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnProgressRewardDefinition].
extension SnProgressRewardDefinitionPatterns on SnProgressRewardDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnProgressRewardDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnProgressRewardDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnProgressRewardDefinition value)  $default,){
final _that = this;
switch (_that) {
case _SnProgressRewardDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnProgressRewardDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _SnProgressRewardDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int experience,  num sourcePoints,  String sourcePointsCurrency,  SnProgressBadgeRewardDefinition? badge)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnProgressRewardDefinition() when $default != null:
return $default(_that.experience,_that.sourcePoints,_that.sourcePointsCurrency,_that.badge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int experience,  num sourcePoints,  String sourcePointsCurrency,  SnProgressBadgeRewardDefinition? badge)  $default,) {final _that = this;
switch (_that) {
case _SnProgressRewardDefinition():
return $default(_that.experience,_that.sourcePoints,_that.sourcePointsCurrency,_that.badge);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int experience,  num sourcePoints,  String sourcePointsCurrency,  SnProgressBadgeRewardDefinition? badge)?  $default,) {final _that = this;
switch (_that) {
case _SnProgressRewardDefinition() when $default != null:
return $default(_that.experience,_that.sourcePoints,_that.sourcePointsCurrency,_that.badge);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnProgressRewardDefinition implements SnProgressRewardDefinition {
  const _SnProgressRewardDefinition({this.experience = 0, this.sourcePoints = 0, this.sourcePointsCurrency = 'points', this.badge});
  factory _SnProgressRewardDefinition.fromJson(Map<String, dynamic> json) => _$SnProgressRewardDefinitionFromJson(json);

@override@JsonKey() final  int experience;
@override@JsonKey() final  num sourcePoints;
@override@JsonKey() final  String sourcePointsCurrency;
@override final  SnProgressBadgeRewardDefinition? badge;

/// Create a copy of SnProgressRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnProgressRewardDefinitionCopyWith<_SnProgressRewardDefinition> get copyWith => __$SnProgressRewardDefinitionCopyWithImpl<_SnProgressRewardDefinition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnProgressRewardDefinitionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnProgressRewardDefinition&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.sourcePoints, sourcePoints) || other.sourcePoints == sourcePoints)&&(identical(other.sourcePointsCurrency, sourcePointsCurrency) || other.sourcePointsCurrency == sourcePointsCurrency)&&(identical(other.badge, badge) || other.badge == badge));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,experience,sourcePoints,sourcePointsCurrency,badge);

@override
String toString() {
  return 'SnProgressRewardDefinition(experience: $experience, sourcePoints: $sourcePoints, sourcePointsCurrency: $sourcePointsCurrency, badge: $badge)';
}


}

/// @nodoc
abstract mixin class _$SnProgressRewardDefinitionCopyWith<$Res> implements $SnProgressRewardDefinitionCopyWith<$Res> {
  factory _$SnProgressRewardDefinitionCopyWith(_SnProgressRewardDefinition value, $Res Function(_SnProgressRewardDefinition) _then) = __$SnProgressRewardDefinitionCopyWithImpl;
@override @useResult
$Res call({
 int experience, num sourcePoints, String sourcePointsCurrency, SnProgressBadgeRewardDefinition? badge
});


@override $SnProgressBadgeRewardDefinitionCopyWith<$Res>? get badge;

}
/// @nodoc
class __$SnProgressRewardDefinitionCopyWithImpl<$Res>
    implements _$SnProgressRewardDefinitionCopyWith<$Res> {
  __$SnProgressRewardDefinitionCopyWithImpl(this._self, this._then);

  final _SnProgressRewardDefinition _self;
  final $Res Function(_SnProgressRewardDefinition) _then;

/// Create a copy of SnProgressRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? experience = null,Object? sourcePoints = null,Object? sourcePointsCurrency = null,Object? badge = freezed,}) {
  return _then(_SnProgressRewardDefinition(
experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,sourcePoints: null == sourcePoints ? _self.sourcePoints : sourcePoints // ignore: cast_nullable_to_non_nullable
as num,sourcePointsCurrency: null == sourcePointsCurrency ? _self.sourcePointsCurrency : sourcePointsCurrency // ignore: cast_nullable_to_non_nullable
as String,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as SnProgressBadgeRewardDefinition?,
  ));
}

/// Create a copy of SnProgressRewardDefinition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressBadgeRewardDefinitionCopyWith<$Res>? get badge {
    if (_self.badge == null) {
    return null;
  }

  return $SnProgressBadgeRewardDefinitionCopyWith<$Res>(_self.badge!, (value) {
    return _then(_self.copyWith(badge: value));
  });
}
}


/// @nodoc
mixin _$SnQuestScheduleConfig {

 String get repeatability; List<int> get activeDaysOfWeek;
/// Create a copy of SnQuestScheduleConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnQuestScheduleConfigCopyWith<SnQuestScheduleConfig> get copyWith => _$SnQuestScheduleConfigCopyWithImpl<SnQuestScheduleConfig>(this as SnQuestScheduleConfig, _$identity);

  /// Serializes this SnQuestScheduleConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnQuestScheduleConfig&&(identical(other.repeatability, repeatability) || other.repeatability == repeatability)&&const DeepCollectionEquality().equals(other.activeDaysOfWeek, activeDaysOfWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,repeatability,const DeepCollectionEquality().hash(activeDaysOfWeek));

@override
String toString() {
  return 'SnQuestScheduleConfig(repeatability: $repeatability, activeDaysOfWeek: $activeDaysOfWeek)';
}


}

/// @nodoc
abstract mixin class $SnQuestScheduleConfigCopyWith<$Res>  {
  factory $SnQuestScheduleConfigCopyWith(SnQuestScheduleConfig value, $Res Function(SnQuestScheduleConfig) _then) = _$SnQuestScheduleConfigCopyWithImpl;
@useResult
$Res call({
 String repeatability, List<int> activeDaysOfWeek
});




}
/// @nodoc
class _$SnQuestScheduleConfigCopyWithImpl<$Res>
    implements $SnQuestScheduleConfigCopyWith<$Res> {
  _$SnQuestScheduleConfigCopyWithImpl(this._self, this._then);

  final SnQuestScheduleConfig _self;
  final $Res Function(SnQuestScheduleConfig) _then;

/// Create a copy of SnQuestScheduleConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? repeatability = null,Object? activeDaysOfWeek = null,}) {
  return _then(_self.copyWith(
repeatability: null == repeatability ? _self.repeatability : repeatability // ignore: cast_nullable_to_non_nullable
as String,activeDaysOfWeek: null == activeDaysOfWeek ? _self.activeDaysOfWeek : activeDaysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnQuestScheduleConfig].
extension SnQuestScheduleConfigPatterns on SnQuestScheduleConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnQuestScheduleConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnQuestScheduleConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnQuestScheduleConfig value)  $default,){
final _that = this;
switch (_that) {
case _SnQuestScheduleConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnQuestScheduleConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SnQuestScheduleConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String repeatability,  List<int> activeDaysOfWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnQuestScheduleConfig() when $default != null:
return $default(_that.repeatability,_that.activeDaysOfWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String repeatability,  List<int> activeDaysOfWeek)  $default,) {final _that = this;
switch (_that) {
case _SnQuestScheduleConfig():
return $default(_that.repeatability,_that.activeDaysOfWeek);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String repeatability,  List<int> activeDaysOfWeek)?  $default,) {final _that = this;
switch (_that) {
case _SnQuestScheduleConfig() when $default != null:
return $default(_that.repeatability,_that.activeDaysOfWeek);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnQuestScheduleConfig implements SnQuestScheduleConfig {
  const _SnQuestScheduleConfig({this.repeatability = 'none', final  List<int> activeDaysOfWeek = const []}): _activeDaysOfWeek = activeDaysOfWeek;
  factory _SnQuestScheduleConfig.fromJson(Map<String, dynamic> json) => _$SnQuestScheduleConfigFromJson(json);

@override@JsonKey() final  String repeatability;
 final  List<int> _activeDaysOfWeek;
@override@JsonKey() List<int> get activeDaysOfWeek {
  if (_activeDaysOfWeek is EqualUnmodifiableListView) return _activeDaysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeDaysOfWeek);
}


/// Create a copy of SnQuestScheduleConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnQuestScheduleConfigCopyWith<_SnQuestScheduleConfig> get copyWith => __$SnQuestScheduleConfigCopyWithImpl<_SnQuestScheduleConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnQuestScheduleConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnQuestScheduleConfig&&(identical(other.repeatability, repeatability) || other.repeatability == repeatability)&&const DeepCollectionEquality().equals(other._activeDaysOfWeek, _activeDaysOfWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,repeatability,const DeepCollectionEquality().hash(_activeDaysOfWeek));

@override
String toString() {
  return 'SnQuestScheduleConfig(repeatability: $repeatability, activeDaysOfWeek: $activeDaysOfWeek)';
}


}

/// @nodoc
abstract mixin class _$SnQuestScheduleConfigCopyWith<$Res> implements $SnQuestScheduleConfigCopyWith<$Res> {
  factory _$SnQuestScheduleConfigCopyWith(_SnQuestScheduleConfig value, $Res Function(_SnQuestScheduleConfig) _then) = __$SnQuestScheduleConfigCopyWithImpl;
@override @useResult
$Res call({
 String repeatability, List<int> activeDaysOfWeek
});




}
/// @nodoc
class __$SnQuestScheduleConfigCopyWithImpl<$Res>
    implements _$SnQuestScheduleConfigCopyWith<$Res> {
  __$SnQuestScheduleConfigCopyWithImpl(this._self, this._then);

  final _SnQuestScheduleConfig _self;
  final $Res Function(_SnQuestScheduleConfig) _then;

/// Create a copy of SnQuestScheduleConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? repeatability = null,Object? activeDaysOfWeek = null,}) {
  return _then(_SnQuestScheduleConfig(
repeatability: null == repeatability ? _self.repeatability : repeatability // ignore: cast_nullable_to_non_nullable
as String,activeDaysOfWeek: null == activeDaysOfWeek ? _self._activeDaysOfWeek : activeDaysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$SnSeriesStage {

 String get identifier; String get title; int get seriesOrder; int get targetCount; bool get isCompleted; DateTime? get completedAt;
/// Create a copy of SnSeriesStage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSeriesStageCopyWith<SnSeriesStage> get copyWith => _$SnSeriesStageCopyWithImpl<SnSeriesStage>(this as SnSeriesStage, _$identity);

  /// Serializes this SnSeriesStage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSeriesStage&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.seriesOrder, seriesOrder) || other.seriesOrder == seriesOrder)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identifier,title,seriesOrder,targetCount,isCompleted,completedAt);

@override
String toString() {
  return 'SnSeriesStage(identifier: $identifier, title: $title, seriesOrder: $seriesOrder, targetCount: $targetCount, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $SnSeriesStageCopyWith<$Res>  {
  factory $SnSeriesStageCopyWith(SnSeriesStage value, $Res Function(SnSeriesStage) _then) = _$SnSeriesStageCopyWithImpl;
@useResult
$Res call({
 String identifier, String title, int seriesOrder, int targetCount, bool isCompleted, DateTime? completedAt
});




}
/// @nodoc
class _$SnSeriesStageCopyWithImpl<$Res>
    implements $SnSeriesStageCopyWith<$Res> {
  _$SnSeriesStageCopyWithImpl(this._self, this._then);

  final SnSeriesStage _self;
  final $Res Function(SnSeriesStage) _then;

/// Create a copy of SnSeriesStage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identifier = null,Object? title = null,Object? seriesOrder = null,Object? targetCount = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,seriesOrder: null == seriesOrder ? _self.seriesOrder : seriesOrder // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnSeriesStage].
extension SnSeriesStagePatterns on SnSeriesStage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSeriesStage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSeriesStage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSeriesStage value)  $default,){
final _that = this;
switch (_that) {
case _SnSeriesStage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSeriesStage value)?  $default,){
final _that = this;
switch (_that) {
case _SnSeriesStage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identifier,  String title,  int seriesOrder,  int targetCount,  bool isCompleted,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSeriesStage() when $default != null:
return $default(_that.identifier,_that.title,_that.seriesOrder,_that.targetCount,_that.isCompleted,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identifier,  String title,  int seriesOrder,  int targetCount,  bool isCompleted,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _SnSeriesStage():
return $default(_that.identifier,_that.title,_that.seriesOrder,_that.targetCount,_that.isCompleted,_that.completedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identifier,  String title,  int seriesOrder,  int targetCount,  bool isCompleted,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnSeriesStage() when $default != null:
return $default(_that.identifier,_that.title,_that.seriesOrder,_that.targetCount,_that.isCompleted,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSeriesStage implements SnSeriesStage {
  const _SnSeriesStage({required this.identifier, required this.title, this.seriesOrder = 0, this.targetCount = 1, this.isCompleted = false, this.completedAt});
  factory _SnSeriesStage.fromJson(Map<String, dynamic> json) => _$SnSeriesStageFromJson(json);

@override final  String identifier;
@override final  String title;
@override@JsonKey() final  int seriesOrder;
@override@JsonKey() final  int targetCount;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completedAt;

/// Create a copy of SnSeriesStage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSeriesStageCopyWith<_SnSeriesStage> get copyWith => __$SnSeriesStageCopyWithImpl<_SnSeriesStage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSeriesStageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSeriesStage&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.seriesOrder, seriesOrder) || other.seriesOrder == seriesOrder)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identifier,title,seriesOrder,targetCount,isCompleted,completedAt);

@override
String toString() {
  return 'SnSeriesStage(identifier: $identifier, title: $title, seriesOrder: $seriesOrder, targetCount: $targetCount, isCompleted: $isCompleted, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$SnSeriesStageCopyWith<$Res> implements $SnSeriesStageCopyWith<$Res> {
  factory _$SnSeriesStageCopyWith(_SnSeriesStage value, $Res Function(_SnSeriesStage) _then) = __$SnSeriesStageCopyWithImpl;
@override @useResult
$Res call({
 String identifier, String title, int seriesOrder, int targetCount, bool isCompleted, DateTime? completedAt
});




}
/// @nodoc
class __$SnSeriesStageCopyWithImpl<$Res>
    implements _$SnSeriesStageCopyWith<$Res> {
  __$SnSeriesStageCopyWithImpl(this._self, this._then);

  final _SnSeriesStage _self;
  final $Res Function(_SnSeriesStage) _then;

/// Create a copy of SnSeriesStage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identifier = null,Object? title = null,Object? seriesOrder = null,Object? targetCount = null,Object? isCompleted = null,Object? completedAt = freezed,}) {
  return _then(_SnSeriesStage(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,seriesOrder: null == seriesOrder ? _self.seriesOrder : seriesOrder // ignore: cast_nullable_to_non_nullable
as int,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnAchievementStats {

 int get totalCount; int get completedCount; int get hiddenTotalCount; int get hiddenCompletedCount; num get completionPercentage;
/// Create a copy of SnAchievementStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAchievementStatsCopyWith<SnAchievementStats> get copyWith => _$SnAchievementStatsCopyWithImpl<SnAchievementStats>(this as SnAchievementStats, _$identity);

  /// Serializes this SnAchievementStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAchievementStats&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.hiddenTotalCount, hiddenTotalCount) || other.hiddenTotalCount == hiddenTotalCount)&&(identical(other.hiddenCompletedCount, hiddenCompletedCount) || other.hiddenCompletedCount == hiddenCompletedCount)&&(identical(other.completionPercentage, completionPercentage) || other.completionPercentage == completionPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCount,completedCount,hiddenTotalCount,hiddenCompletedCount,completionPercentage);

@override
String toString() {
  return 'SnAchievementStats(totalCount: $totalCount, completedCount: $completedCount, hiddenTotalCount: $hiddenTotalCount, hiddenCompletedCount: $hiddenCompletedCount, completionPercentage: $completionPercentage)';
}


}

/// @nodoc
abstract mixin class $SnAchievementStatsCopyWith<$Res>  {
  factory $SnAchievementStatsCopyWith(SnAchievementStats value, $Res Function(SnAchievementStats) _then) = _$SnAchievementStatsCopyWithImpl;
@useResult
$Res call({
 int totalCount, int completedCount, int hiddenTotalCount, int hiddenCompletedCount, num completionPercentage
});




}
/// @nodoc
class _$SnAchievementStatsCopyWithImpl<$Res>
    implements $SnAchievementStatsCopyWith<$Res> {
  _$SnAchievementStatsCopyWithImpl(this._self, this._then);

  final SnAchievementStats _self;
  final $Res Function(SnAchievementStats) _then;

/// Create a copy of SnAchievementStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCount = null,Object? completedCount = null,Object? hiddenTotalCount = null,Object? hiddenCompletedCount = null,Object? completionPercentage = null,}) {
  return _then(_self.copyWith(
totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,hiddenTotalCount: null == hiddenTotalCount ? _self.hiddenTotalCount : hiddenTotalCount // ignore: cast_nullable_to_non_nullable
as int,hiddenCompletedCount: null == hiddenCompletedCount ? _self.hiddenCompletedCount : hiddenCompletedCount // ignore: cast_nullable_to_non_nullable
as int,completionPercentage: null == completionPercentage ? _self.completionPercentage : completionPercentage // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAchievementStats].
extension SnAchievementStatsPatterns on SnAchievementStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAchievementStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAchievementStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAchievementStats value)  $default,){
final _that = this;
switch (_that) {
case _SnAchievementStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAchievementStats value)?  $default,){
final _that = this;
switch (_that) {
case _SnAchievementStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCount,  int completedCount,  int hiddenTotalCount,  int hiddenCompletedCount,  num completionPercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAchievementStats() when $default != null:
return $default(_that.totalCount,_that.completedCount,_that.hiddenTotalCount,_that.hiddenCompletedCount,_that.completionPercentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCount,  int completedCount,  int hiddenTotalCount,  int hiddenCompletedCount,  num completionPercentage)  $default,) {final _that = this;
switch (_that) {
case _SnAchievementStats():
return $default(_that.totalCount,_that.completedCount,_that.hiddenTotalCount,_that.hiddenCompletedCount,_that.completionPercentage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCount,  int completedCount,  int hiddenTotalCount,  int hiddenCompletedCount,  num completionPercentage)?  $default,) {final _that = this;
switch (_that) {
case _SnAchievementStats() when $default != null:
return $default(_that.totalCount,_that.completedCount,_that.hiddenTotalCount,_that.hiddenCompletedCount,_that.completionPercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAchievementStats implements SnAchievementStats {
  const _SnAchievementStats({this.totalCount = 0, this.completedCount = 0, this.hiddenTotalCount = 0, this.hiddenCompletedCount = 0, this.completionPercentage = 0});
  factory _SnAchievementStats.fromJson(Map<String, dynamic> json) => _$SnAchievementStatsFromJson(json);

@override@JsonKey() final  int totalCount;
@override@JsonKey() final  int completedCount;
@override@JsonKey() final  int hiddenTotalCount;
@override@JsonKey() final  int hiddenCompletedCount;
@override@JsonKey() final  num completionPercentage;

/// Create a copy of SnAchievementStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAchievementStatsCopyWith<_SnAchievementStats> get copyWith => __$SnAchievementStatsCopyWithImpl<_SnAchievementStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAchievementStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAchievementStats&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.hiddenTotalCount, hiddenTotalCount) || other.hiddenTotalCount == hiddenTotalCount)&&(identical(other.hiddenCompletedCount, hiddenCompletedCount) || other.hiddenCompletedCount == hiddenCompletedCount)&&(identical(other.completionPercentage, completionPercentage) || other.completionPercentage == completionPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCount,completedCount,hiddenTotalCount,hiddenCompletedCount,completionPercentage);

@override
String toString() {
  return 'SnAchievementStats(totalCount: $totalCount, completedCount: $completedCount, hiddenTotalCount: $hiddenTotalCount, hiddenCompletedCount: $hiddenCompletedCount, completionPercentage: $completionPercentage)';
}


}

/// @nodoc
abstract mixin class _$SnAchievementStatsCopyWith<$Res> implements $SnAchievementStatsCopyWith<$Res> {
  factory _$SnAchievementStatsCopyWith(_SnAchievementStats value, $Res Function(_SnAchievementStats) _then) = __$SnAchievementStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalCount, int completedCount, int hiddenTotalCount, int hiddenCompletedCount, num completionPercentage
});




}
/// @nodoc
class __$SnAchievementStatsCopyWithImpl<$Res>
    implements _$SnAchievementStatsCopyWith<$Res> {
  __$SnAchievementStatsCopyWithImpl(this._self, this._then);

  final _SnAchievementStats _self;
  final $Res Function(_SnAchievementStats) _then;

/// Create a copy of SnAchievementStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCount = null,Object? completedCount = null,Object? hiddenTotalCount = null,Object? hiddenCompletedCount = null,Object? completionPercentage = null,}) {
  return _then(_SnAchievementStats(
totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,hiddenTotalCount: null == hiddenTotalCount ? _self.hiddenTotalCount : hiddenTotalCount // ignore: cast_nullable_to_non_nullable
as int,hiddenCompletedCount: null == hiddenCompletedCount ? _self.hiddenCompletedCount : hiddenCompletedCount // ignore: cast_nullable_to_non_nullable
as int,completionPercentage: null == completionPercentage ? _self.completionPercentage : completionPercentage // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$SnAchievementState {

 String get identifier; String get title; String get summary; String? get icon; int get sortOrder; bool get hidden; bool get isEnabled; int get targetCount; int get progressCount; bool get isCompleted; DateTime? get completedAt; SnProgressRewardDefinition? get reward; String? get seriesIdentifier; String? get seriesTitle; int get seriesOrder; int get seriesTotalSteps; int get seriesCompletedSteps; List<SnSeriesStage> get seriesStages;
/// Create a copy of SnAchievementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAchievementStateCopyWith<SnAchievementState> get copyWith => _$SnAchievementStateCopyWithImpl<SnAchievementState>(this as SnAchievementState, _$identity);

  /// Serializes this SnAchievementState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAchievementState&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.progressCount, progressCount) || other.progressCount == progressCount)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.seriesIdentifier, seriesIdentifier) || other.seriesIdentifier == seriesIdentifier)&&(identical(other.seriesTitle, seriesTitle) || other.seriesTitle == seriesTitle)&&(identical(other.seriesOrder, seriesOrder) || other.seriesOrder == seriesOrder)&&(identical(other.seriesTotalSteps, seriesTotalSteps) || other.seriesTotalSteps == seriesTotalSteps)&&(identical(other.seriesCompletedSteps, seriesCompletedSteps) || other.seriesCompletedSteps == seriesCompletedSteps)&&const DeepCollectionEquality().equals(other.seriesStages, seriesStages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identifier,title,summary,icon,sortOrder,hidden,isEnabled,targetCount,progressCount,isCompleted,completedAt,reward,seriesIdentifier,seriesTitle,seriesOrder,seriesTotalSteps,seriesCompletedSteps,const DeepCollectionEquality().hash(seriesStages));

@override
String toString() {
  return 'SnAchievementState(identifier: $identifier, title: $title, summary: $summary, icon: $icon, sortOrder: $sortOrder, hidden: $hidden, isEnabled: $isEnabled, targetCount: $targetCount, progressCount: $progressCount, isCompleted: $isCompleted, completedAt: $completedAt, reward: $reward, seriesIdentifier: $seriesIdentifier, seriesTitle: $seriesTitle, seriesOrder: $seriesOrder, seriesTotalSteps: $seriesTotalSteps, seriesCompletedSteps: $seriesCompletedSteps, seriesStages: $seriesStages)';
}


}

/// @nodoc
abstract mixin class $SnAchievementStateCopyWith<$Res>  {
  factory $SnAchievementStateCopyWith(SnAchievementState value, $Res Function(SnAchievementState) _then) = _$SnAchievementStateCopyWithImpl;
@useResult
$Res call({
 String identifier, String title, String summary, String? icon, int sortOrder, bool hidden, bool isEnabled, int targetCount, int progressCount, bool isCompleted, DateTime? completedAt, SnProgressRewardDefinition? reward, String? seriesIdentifier, String? seriesTitle, int seriesOrder, int seriesTotalSteps, int seriesCompletedSteps, List<SnSeriesStage> seriesStages
});


$SnProgressRewardDefinitionCopyWith<$Res>? get reward;

}
/// @nodoc
class _$SnAchievementStateCopyWithImpl<$Res>
    implements $SnAchievementStateCopyWith<$Res> {
  _$SnAchievementStateCopyWithImpl(this._self, this._then);

  final SnAchievementState _self;
  final $Res Function(SnAchievementState) _then;

/// Create a copy of SnAchievementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identifier = null,Object? title = null,Object? summary = null,Object? icon = freezed,Object? sortOrder = null,Object? hidden = null,Object? isEnabled = null,Object? targetCount = null,Object? progressCount = null,Object? isCompleted = null,Object? completedAt = freezed,Object? reward = freezed,Object? seriesIdentifier = freezed,Object? seriesTitle = freezed,Object? seriesOrder = null,Object? seriesTotalSteps = null,Object? seriesCompletedSteps = null,Object? seriesStages = null,}) {
  return _then(_self.copyWith(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,progressCount: null == progressCount ? _self.progressCount : progressCount // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as SnProgressRewardDefinition?,seriesIdentifier: freezed == seriesIdentifier ? _self.seriesIdentifier : seriesIdentifier // ignore: cast_nullable_to_non_nullable
as String?,seriesTitle: freezed == seriesTitle ? _self.seriesTitle : seriesTitle // ignore: cast_nullable_to_non_nullable
as String?,seriesOrder: null == seriesOrder ? _self.seriesOrder : seriesOrder // ignore: cast_nullable_to_non_nullable
as int,seriesTotalSteps: null == seriesTotalSteps ? _self.seriesTotalSteps : seriesTotalSteps // ignore: cast_nullable_to_non_nullable
as int,seriesCompletedSteps: null == seriesCompletedSteps ? _self.seriesCompletedSteps : seriesCompletedSteps // ignore: cast_nullable_to_non_nullable
as int,seriesStages: null == seriesStages ? _self.seriesStages : seriesStages // ignore: cast_nullable_to_non_nullable
as List<SnSeriesStage>,
  ));
}
/// Create a copy of SnAchievementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<$Res>? get reward {
    if (_self.reward == null) {
    return null;
  }

  return $SnProgressRewardDefinitionCopyWith<$Res>(_self.reward!, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnAchievementState].
extension SnAchievementStatePatterns on SnAchievementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAchievementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAchievementState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAchievementState value)  $default,){
final _that = this;
switch (_that) {
case _SnAchievementState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAchievementState value)?  $default,){
final _that = this;
switch (_that) {
case _SnAchievementState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identifier,  String title,  String summary,  String? icon,  int sortOrder,  bool hidden,  bool isEnabled,  int targetCount,  int progressCount,  bool isCompleted,  DateTime? completedAt,  SnProgressRewardDefinition? reward,  String? seriesIdentifier,  String? seriesTitle,  int seriesOrder,  int seriesTotalSteps,  int seriesCompletedSteps,  List<SnSeriesStage> seriesStages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAchievementState() when $default != null:
return $default(_that.identifier,_that.title,_that.summary,_that.icon,_that.sortOrder,_that.hidden,_that.isEnabled,_that.targetCount,_that.progressCount,_that.isCompleted,_that.completedAt,_that.reward,_that.seriesIdentifier,_that.seriesTitle,_that.seriesOrder,_that.seriesTotalSteps,_that.seriesCompletedSteps,_that.seriesStages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identifier,  String title,  String summary,  String? icon,  int sortOrder,  bool hidden,  bool isEnabled,  int targetCount,  int progressCount,  bool isCompleted,  DateTime? completedAt,  SnProgressRewardDefinition? reward,  String? seriesIdentifier,  String? seriesTitle,  int seriesOrder,  int seriesTotalSteps,  int seriesCompletedSteps,  List<SnSeriesStage> seriesStages)  $default,) {final _that = this;
switch (_that) {
case _SnAchievementState():
return $default(_that.identifier,_that.title,_that.summary,_that.icon,_that.sortOrder,_that.hidden,_that.isEnabled,_that.targetCount,_that.progressCount,_that.isCompleted,_that.completedAt,_that.reward,_that.seriesIdentifier,_that.seriesTitle,_that.seriesOrder,_that.seriesTotalSteps,_that.seriesCompletedSteps,_that.seriesStages);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identifier,  String title,  String summary,  String? icon,  int sortOrder,  bool hidden,  bool isEnabled,  int targetCount,  int progressCount,  bool isCompleted,  DateTime? completedAt,  SnProgressRewardDefinition? reward,  String? seriesIdentifier,  String? seriesTitle,  int seriesOrder,  int seriesTotalSteps,  int seriesCompletedSteps,  List<SnSeriesStage> seriesStages)?  $default,) {final _that = this;
switch (_that) {
case _SnAchievementState() when $default != null:
return $default(_that.identifier,_that.title,_that.summary,_that.icon,_that.sortOrder,_that.hidden,_that.isEnabled,_that.targetCount,_that.progressCount,_that.isCompleted,_that.completedAt,_that.reward,_that.seriesIdentifier,_that.seriesTitle,_that.seriesOrder,_that.seriesTotalSteps,_that.seriesCompletedSteps,_that.seriesStages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAchievementState implements SnAchievementState {
  const _SnAchievementState({required this.identifier, required this.title, required this.summary, this.icon, this.sortOrder = 0, this.hidden = false, this.isEnabled = true, this.targetCount = 1, this.progressCount = 0, this.isCompleted = false, this.completedAt, this.reward, this.seriesIdentifier, this.seriesTitle, this.seriesOrder = 0, this.seriesTotalSteps = 0, this.seriesCompletedSteps = 0, final  List<SnSeriesStage> seriesStages = const []}): _seriesStages = seriesStages;
  factory _SnAchievementState.fromJson(Map<String, dynamic> json) => _$SnAchievementStateFromJson(json);

@override final  String identifier;
@override final  String title;
@override final  String summary;
@override final  String? icon;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool hidden;
@override@JsonKey() final  bool isEnabled;
@override@JsonKey() final  int targetCount;
@override@JsonKey() final  int progressCount;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completedAt;
@override final  SnProgressRewardDefinition? reward;
@override final  String? seriesIdentifier;
@override final  String? seriesTitle;
@override@JsonKey() final  int seriesOrder;
@override@JsonKey() final  int seriesTotalSteps;
@override@JsonKey() final  int seriesCompletedSteps;
 final  List<SnSeriesStage> _seriesStages;
@override@JsonKey() List<SnSeriesStage> get seriesStages {
  if (_seriesStages is EqualUnmodifiableListView) return _seriesStages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seriesStages);
}


/// Create a copy of SnAchievementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAchievementStateCopyWith<_SnAchievementState> get copyWith => __$SnAchievementStateCopyWithImpl<_SnAchievementState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAchievementStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAchievementState&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.progressCount, progressCount) || other.progressCount == progressCount)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.seriesIdentifier, seriesIdentifier) || other.seriesIdentifier == seriesIdentifier)&&(identical(other.seriesTitle, seriesTitle) || other.seriesTitle == seriesTitle)&&(identical(other.seriesOrder, seriesOrder) || other.seriesOrder == seriesOrder)&&(identical(other.seriesTotalSteps, seriesTotalSteps) || other.seriesTotalSteps == seriesTotalSteps)&&(identical(other.seriesCompletedSteps, seriesCompletedSteps) || other.seriesCompletedSteps == seriesCompletedSteps)&&const DeepCollectionEquality().equals(other._seriesStages, _seriesStages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identifier,title,summary,icon,sortOrder,hidden,isEnabled,targetCount,progressCount,isCompleted,completedAt,reward,seriesIdentifier,seriesTitle,seriesOrder,seriesTotalSteps,seriesCompletedSteps,const DeepCollectionEquality().hash(_seriesStages));

@override
String toString() {
  return 'SnAchievementState(identifier: $identifier, title: $title, summary: $summary, icon: $icon, sortOrder: $sortOrder, hidden: $hidden, isEnabled: $isEnabled, targetCount: $targetCount, progressCount: $progressCount, isCompleted: $isCompleted, completedAt: $completedAt, reward: $reward, seriesIdentifier: $seriesIdentifier, seriesTitle: $seriesTitle, seriesOrder: $seriesOrder, seriesTotalSteps: $seriesTotalSteps, seriesCompletedSteps: $seriesCompletedSteps, seriesStages: $seriesStages)';
}


}

/// @nodoc
abstract mixin class _$SnAchievementStateCopyWith<$Res> implements $SnAchievementStateCopyWith<$Res> {
  factory _$SnAchievementStateCopyWith(_SnAchievementState value, $Res Function(_SnAchievementState) _then) = __$SnAchievementStateCopyWithImpl;
@override @useResult
$Res call({
 String identifier, String title, String summary, String? icon, int sortOrder, bool hidden, bool isEnabled, int targetCount, int progressCount, bool isCompleted, DateTime? completedAt, SnProgressRewardDefinition? reward, String? seriesIdentifier, String? seriesTitle, int seriesOrder, int seriesTotalSteps, int seriesCompletedSteps, List<SnSeriesStage> seriesStages
});


@override $SnProgressRewardDefinitionCopyWith<$Res>? get reward;

}
/// @nodoc
class __$SnAchievementStateCopyWithImpl<$Res>
    implements _$SnAchievementStateCopyWith<$Res> {
  __$SnAchievementStateCopyWithImpl(this._self, this._then);

  final _SnAchievementState _self;
  final $Res Function(_SnAchievementState) _then;

/// Create a copy of SnAchievementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identifier = null,Object? title = null,Object? summary = null,Object? icon = freezed,Object? sortOrder = null,Object? hidden = null,Object? isEnabled = null,Object? targetCount = null,Object? progressCount = null,Object? isCompleted = null,Object? completedAt = freezed,Object? reward = freezed,Object? seriesIdentifier = freezed,Object? seriesTitle = freezed,Object? seriesOrder = null,Object? seriesTotalSteps = null,Object? seriesCompletedSteps = null,Object? seriesStages = null,}) {
  return _then(_SnAchievementState(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,progressCount: null == progressCount ? _self.progressCount : progressCount // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as SnProgressRewardDefinition?,seriesIdentifier: freezed == seriesIdentifier ? _self.seriesIdentifier : seriesIdentifier // ignore: cast_nullable_to_non_nullable
as String?,seriesTitle: freezed == seriesTitle ? _self.seriesTitle : seriesTitle // ignore: cast_nullable_to_non_nullable
as String?,seriesOrder: null == seriesOrder ? _self.seriesOrder : seriesOrder // ignore: cast_nullable_to_non_nullable
as int,seriesTotalSteps: null == seriesTotalSteps ? _self.seriesTotalSteps : seriesTotalSteps // ignore: cast_nullable_to_non_nullable
as int,seriesCompletedSteps: null == seriesCompletedSteps ? _self.seriesCompletedSteps : seriesCompletedSteps // ignore: cast_nullable_to_non_nullable
as int,seriesStages: null == seriesStages ? _self._seriesStages : seriesStages // ignore: cast_nullable_to_non_nullable
as List<SnSeriesStage>,
  ));
}

/// Create a copy of SnAchievementState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<$Res>? get reward {
    if (_self.reward == null) {
    return null;
  }

  return $SnProgressRewardDefinitionCopyWith<$Res>(_self.reward!, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// @nodoc
mixin _$SnQuestState {

 String get identifier; String get title; String get summary; String? get icon; int get sortOrder; bool get hidden; bool get isEnabled; int get targetCount; int get progressCount; bool get isCompleted; DateTime? get completedAt; String get periodKey; DateTime? get nextResetAt; SnQuestScheduleConfig? get schedule; SnProgressRewardDefinition? get reward; String? get seriesIdentifier; String? get seriesTitle; int get seriesOrder; int get seriesTotalSteps; int get seriesCompletedSteps; List<SnSeriesStage> get seriesStages;
/// Create a copy of SnQuestState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnQuestStateCopyWith<SnQuestState> get copyWith => _$SnQuestStateCopyWithImpl<SnQuestState>(this as SnQuestState, _$identity);

  /// Serializes this SnQuestState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnQuestState&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.progressCount, progressCount) || other.progressCount == progressCount)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.nextResetAt, nextResetAt) || other.nextResetAt == nextResetAt)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.seriesIdentifier, seriesIdentifier) || other.seriesIdentifier == seriesIdentifier)&&(identical(other.seriesTitle, seriesTitle) || other.seriesTitle == seriesTitle)&&(identical(other.seriesOrder, seriesOrder) || other.seriesOrder == seriesOrder)&&(identical(other.seriesTotalSteps, seriesTotalSteps) || other.seriesTotalSteps == seriesTotalSteps)&&(identical(other.seriesCompletedSteps, seriesCompletedSteps) || other.seriesCompletedSteps == seriesCompletedSteps)&&const DeepCollectionEquality().equals(other.seriesStages, seriesStages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,identifier,title,summary,icon,sortOrder,hidden,isEnabled,targetCount,progressCount,isCompleted,completedAt,periodKey,nextResetAt,schedule,reward,seriesIdentifier,seriesTitle,seriesOrder,seriesTotalSteps,seriesCompletedSteps,const DeepCollectionEquality().hash(seriesStages)]);

@override
String toString() {
  return 'SnQuestState(identifier: $identifier, title: $title, summary: $summary, icon: $icon, sortOrder: $sortOrder, hidden: $hidden, isEnabled: $isEnabled, targetCount: $targetCount, progressCount: $progressCount, isCompleted: $isCompleted, completedAt: $completedAt, periodKey: $periodKey, nextResetAt: $nextResetAt, schedule: $schedule, reward: $reward, seriesIdentifier: $seriesIdentifier, seriesTitle: $seriesTitle, seriesOrder: $seriesOrder, seriesTotalSteps: $seriesTotalSteps, seriesCompletedSteps: $seriesCompletedSteps, seriesStages: $seriesStages)';
}


}

/// @nodoc
abstract mixin class $SnQuestStateCopyWith<$Res>  {
  factory $SnQuestStateCopyWith(SnQuestState value, $Res Function(SnQuestState) _then) = _$SnQuestStateCopyWithImpl;
@useResult
$Res call({
 String identifier, String title, String summary, String? icon, int sortOrder, bool hidden, bool isEnabled, int targetCount, int progressCount, bool isCompleted, DateTime? completedAt, String periodKey, DateTime? nextResetAt, SnQuestScheduleConfig? schedule, SnProgressRewardDefinition? reward, String? seriesIdentifier, String? seriesTitle, int seriesOrder, int seriesTotalSteps, int seriesCompletedSteps, List<SnSeriesStage> seriesStages
});


$SnQuestScheduleConfigCopyWith<$Res>? get schedule;$SnProgressRewardDefinitionCopyWith<$Res>? get reward;

}
/// @nodoc
class _$SnQuestStateCopyWithImpl<$Res>
    implements $SnQuestStateCopyWith<$Res> {
  _$SnQuestStateCopyWithImpl(this._self, this._then);

  final SnQuestState _self;
  final $Res Function(SnQuestState) _then;

/// Create a copy of SnQuestState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identifier = null,Object? title = null,Object? summary = null,Object? icon = freezed,Object? sortOrder = null,Object? hidden = null,Object? isEnabled = null,Object? targetCount = null,Object? progressCount = null,Object? isCompleted = null,Object? completedAt = freezed,Object? periodKey = null,Object? nextResetAt = freezed,Object? schedule = freezed,Object? reward = freezed,Object? seriesIdentifier = freezed,Object? seriesTitle = freezed,Object? seriesOrder = null,Object? seriesTotalSteps = null,Object? seriesCompletedSteps = null,Object? seriesStages = null,}) {
  return _then(_self.copyWith(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,progressCount: null == progressCount ? _self.progressCount : progressCount // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,periodKey: null == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String,nextResetAt: freezed == nextResetAt ? _self.nextResetAt : nextResetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as SnQuestScheduleConfig?,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as SnProgressRewardDefinition?,seriesIdentifier: freezed == seriesIdentifier ? _self.seriesIdentifier : seriesIdentifier // ignore: cast_nullable_to_non_nullable
as String?,seriesTitle: freezed == seriesTitle ? _self.seriesTitle : seriesTitle // ignore: cast_nullable_to_non_nullable
as String?,seriesOrder: null == seriesOrder ? _self.seriesOrder : seriesOrder // ignore: cast_nullable_to_non_nullable
as int,seriesTotalSteps: null == seriesTotalSteps ? _self.seriesTotalSteps : seriesTotalSteps // ignore: cast_nullable_to_non_nullable
as int,seriesCompletedSteps: null == seriesCompletedSteps ? _self.seriesCompletedSteps : seriesCompletedSteps // ignore: cast_nullable_to_non_nullable
as int,seriesStages: null == seriesStages ? _self.seriesStages : seriesStages // ignore: cast_nullable_to_non_nullable
as List<SnSeriesStage>,
  ));
}
/// Create a copy of SnQuestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnQuestScheduleConfigCopyWith<$Res>? get schedule {
    if (_self.schedule == null) {
    return null;
  }

  return $SnQuestScheduleConfigCopyWith<$Res>(_self.schedule!, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}/// Create a copy of SnQuestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<$Res>? get reward {
    if (_self.reward == null) {
    return null;
  }

  return $SnProgressRewardDefinitionCopyWith<$Res>(_self.reward!, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnQuestState].
extension SnQuestStatePatterns on SnQuestState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnQuestState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnQuestState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnQuestState value)  $default,){
final _that = this;
switch (_that) {
case _SnQuestState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnQuestState value)?  $default,){
final _that = this;
switch (_that) {
case _SnQuestState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identifier,  String title,  String summary,  String? icon,  int sortOrder,  bool hidden,  bool isEnabled,  int targetCount,  int progressCount,  bool isCompleted,  DateTime? completedAt,  String periodKey,  DateTime? nextResetAt,  SnQuestScheduleConfig? schedule,  SnProgressRewardDefinition? reward,  String? seriesIdentifier,  String? seriesTitle,  int seriesOrder,  int seriesTotalSteps,  int seriesCompletedSteps,  List<SnSeriesStage> seriesStages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnQuestState() when $default != null:
return $default(_that.identifier,_that.title,_that.summary,_that.icon,_that.sortOrder,_that.hidden,_that.isEnabled,_that.targetCount,_that.progressCount,_that.isCompleted,_that.completedAt,_that.periodKey,_that.nextResetAt,_that.schedule,_that.reward,_that.seriesIdentifier,_that.seriesTitle,_that.seriesOrder,_that.seriesTotalSteps,_that.seriesCompletedSteps,_that.seriesStages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identifier,  String title,  String summary,  String? icon,  int sortOrder,  bool hidden,  bool isEnabled,  int targetCount,  int progressCount,  bool isCompleted,  DateTime? completedAt,  String periodKey,  DateTime? nextResetAt,  SnQuestScheduleConfig? schedule,  SnProgressRewardDefinition? reward,  String? seriesIdentifier,  String? seriesTitle,  int seriesOrder,  int seriesTotalSteps,  int seriesCompletedSteps,  List<SnSeriesStage> seriesStages)  $default,) {final _that = this;
switch (_that) {
case _SnQuestState():
return $default(_that.identifier,_that.title,_that.summary,_that.icon,_that.sortOrder,_that.hidden,_that.isEnabled,_that.targetCount,_that.progressCount,_that.isCompleted,_that.completedAt,_that.periodKey,_that.nextResetAt,_that.schedule,_that.reward,_that.seriesIdentifier,_that.seriesTitle,_that.seriesOrder,_that.seriesTotalSteps,_that.seriesCompletedSteps,_that.seriesStages);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identifier,  String title,  String summary,  String? icon,  int sortOrder,  bool hidden,  bool isEnabled,  int targetCount,  int progressCount,  bool isCompleted,  DateTime? completedAt,  String periodKey,  DateTime? nextResetAt,  SnQuestScheduleConfig? schedule,  SnProgressRewardDefinition? reward,  String? seriesIdentifier,  String? seriesTitle,  int seriesOrder,  int seriesTotalSteps,  int seriesCompletedSteps,  List<SnSeriesStage> seriesStages)?  $default,) {final _that = this;
switch (_that) {
case _SnQuestState() when $default != null:
return $default(_that.identifier,_that.title,_that.summary,_that.icon,_that.sortOrder,_that.hidden,_that.isEnabled,_that.targetCount,_that.progressCount,_that.isCompleted,_that.completedAt,_that.periodKey,_that.nextResetAt,_that.schedule,_that.reward,_that.seriesIdentifier,_that.seriesTitle,_that.seriesOrder,_that.seriesTotalSteps,_that.seriesCompletedSteps,_that.seriesStages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnQuestState implements SnQuestState {
  const _SnQuestState({required this.identifier, required this.title, required this.summary, this.icon, this.sortOrder = 0, this.hidden = false, this.isEnabled = true, this.targetCount = 1, this.progressCount = 0, this.isCompleted = false, this.completedAt, this.periodKey = '', this.nextResetAt, this.schedule, this.reward, this.seriesIdentifier, this.seriesTitle, this.seriesOrder = 0, this.seriesTotalSteps = 0, this.seriesCompletedSteps = 0, final  List<SnSeriesStage> seriesStages = const []}): _seriesStages = seriesStages;
  factory _SnQuestState.fromJson(Map<String, dynamic> json) => _$SnQuestStateFromJson(json);

@override final  String identifier;
@override final  String title;
@override final  String summary;
@override final  String? icon;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool hidden;
@override@JsonKey() final  bool isEnabled;
@override@JsonKey() final  int targetCount;
@override@JsonKey() final  int progressCount;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completedAt;
@override@JsonKey() final  String periodKey;
@override final  DateTime? nextResetAt;
@override final  SnQuestScheduleConfig? schedule;
@override final  SnProgressRewardDefinition? reward;
@override final  String? seriesIdentifier;
@override final  String? seriesTitle;
@override@JsonKey() final  int seriesOrder;
@override@JsonKey() final  int seriesTotalSteps;
@override@JsonKey() final  int seriesCompletedSteps;
 final  List<SnSeriesStage> _seriesStages;
@override@JsonKey() List<SnSeriesStage> get seriesStages {
  if (_seriesStages is EqualUnmodifiableListView) return _seriesStages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seriesStages);
}


/// Create a copy of SnQuestState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnQuestStateCopyWith<_SnQuestState> get copyWith => __$SnQuestStateCopyWithImpl<_SnQuestState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnQuestStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnQuestState&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.targetCount, targetCount) || other.targetCount == targetCount)&&(identical(other.progressCount, progressCount) || other.progressCount == progressCount)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.nextResetAt, nextResetAt) || other.nextResetAt == nextResetAt)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.seriesIdentifier, seriesIdentifier) || other.seriesIdentifier == seriesIdentifier)&&(identical(other.seriesTitle, seriesTitle) || other.seriesTitle == seriesTitle)&&(identical(other.seriesOrder, seriesOrder) || other.seriesOrder == seriesOrder)&&(identical(other.seriesTotalSteps, seriesTotalSteps) || other.seriesTotalSteps == seriesTotalSteps)&&(identical(other.seriesCompletedSteps, seriesCompletedSteps) || other.seriesCompletedSteps == seriesCompletedSteps)&&const DeepCollectionEquality().equals(other._seriesStages, _seriesStages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,identifier,title,summary,icon,sortOrder,hidden,isEnabled,targetCount,progressCount,isCompleted,completedAt,periodKey,nextResetAt,schedule,reward,seriesIdentifier,seriesTitle,seriesOrder,seriesTotalSteps,seriesCompletedSteps,const DeepCollectionEquality().hash(_seriesStages)]);

@override
String toString() {
  return 'SnQuestState(identifier: $identifier, title: $title, summary: $summary, icon: $icon, sortOrder: $sortOrder, hidden: $hidden, isEnabled: $isEnabled, targetCount: $targetCount, progressCount: $progressCount, isCompleted: $isCompleted, completedAt: $completedAt, periodKey: $periodKey, nextResetAt: $nextResetAt, schedule: $schedule, reward: $reward, seriesIdentifier: $seriesIdentifier, seriesTitle: $seriesTitle, seriesOrder: $seriesOrder, seriesTotalSteps: $seriesTotalSteps, seriesCompletedSteps: $seriesCompletedSteps, seriesStages: $seriesStages)';
}


}

/// @nodoc
abstract mixin class _$SnQuestStateCopyWith<$Res> implements $SnQuestStateCopyWith<$Res> {
  factory _$SnQuestStateCopyWith(_SnQuestState value, $Res Function(_SnQuestState) _then) = __$SnQuestStateCopyWithImpl;
@override @useResult
$Res call({
 String identifier, String title, String summary, String? icon, int sortOrder, bool hidden, bool isEnabled, int targetCount, int progressCount, bool isCompleted, DateTime? completedAt, String periodKey, DateTime? nextResetAt, SnQuestScheduleConfig? schedule, SnProgressRewardDefinition? reward, String? seriesIdentifier, String? seriesTitle, int seriesOrder, int seriesTotalSteps, int seriesCompletedSteps, List<SnSeriesStage> seriesStages
});


@override $SnQuestScheduleConfigCopyWith<$Res>? get schedule;@override $SnProgressRewardDefinitionCopyWith<$Res>? get reward;

}
/// @nodoc
class __$SnQuestStateCopyWithImpl<$Res>
    implements _$SnQuestStateCopyWith<$Res> {
  __$SnQuestStateCopyWithImpl(this._self, this._then);

  final _SnQuestState _self;
  final $Res Function(_SnQuestState) _then;

/// Create a copy of SnQuestState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identifier = null,Object? title = null,Object? summary = null,Object? icon = freezed,Object? sortOrder = null,Object? hidden = null,Object? isEnabled = null,Object? targetCount = null,Object? progressCount = null,Object? isCompleted = null,Object? completedAt = freezed,Object? periodKey = null,Object? nextResetAt = freezed,Object? schedule = freezed,Object? reward = freezed,Object? seriesIdentifier = freezed,Object? seriesTitle = freezed,Object? seriesOrder = null,Object? seriesTotalSteps = null,Object? seriesCompletedSteps = null,Object? seriesStages = null,}) {
  return _then(_SnQuestState(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,targetCount: null == targetCount ? _self.targetCount : targetCount // ignore: cast_nullable_to_non_nullable
as int,progressCount: null == progressCount ? _self.progressCount : progressCount // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,periodKey: null == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String,nextResetAt: freezed == nextResetAt ? _self.nextResetAt : nextResetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,schedule: freezed == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as SnQuestScheduleConfig?,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as SnProgressRewardDefinition?,seriesIdentifier: freezed == seriesIdentifier ? _self.seriesIdentifier : seriesIdentifier // ignore: cast_nullable_to_non_nullable
as String?,seriesTitle: freezed == seriesTitle ? _self.seriesTitle : seriesTitle // ignore: cast_nullable_to_non_nullable
as String?,seriesOrder: null == seriesOrder ? _self.seriesOrder : seriesOrder // ignore: cast_nullable_to_non_nullable
as int,seriesTotalSteps: null == seriesTotalSteps ? _self.seriesTotalSteps : seriesTotalSteps // ignore: cast_nullable_to_non_nullable
as int,seriesCompletedSteps: null == seriesCompletedSteps ? _self.seriesCompletedSteps : seriesCompletedSteps // ignore: cast_nullable_to_non_nullable
as int,seriesStages: null == seriesStages ? _self._seriesStages : seriesStages // ignore: cast_nullable_to_non_nullable
as List<SnSeriesStage>,
  ));
}

/// Create a copy of SnQuestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnQuestScheduleConfigCopyWith<$Res>? get schedule {
    if (_self.schedule == null) {
    return null;
  }

  return $SnQuestScheduleConfigCopyWith<$Res>(_self.schedule!, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}/// Create a copy of SnQuestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<$Res>? get reward {
    if (_self.reward == null) {
    return null;
  }

  return $SnProgressRewardDefinitionCopyWith<$Res>(_self.reward!, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// @nodoc
mixin _$SnProgressRewardGrant {

 String get id; String get accountId; String get definitionType; String get definitionIdentifier; String get definitionTitle; String get rewardToken; String get sourceEventId; SnProgressRewardDefinition? get reward; String? get periodKey; DateTime? get badgeGrantedAt; DateTime? get experienceGrantedAt; DateTime? get sourcePointsGrantedAt; DateTime? get notificationSentAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnProgressRewardGrant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnProgressRewardGrantCopyWith<SnProgressRewardGrant> get copyWith => _$SnProgressRewardGrantCopyWithImpl<SnProgressRewardGrant>(this as SnProgressRewardGrant, _$identity);

  /// Serializes this SnProgressRewardGrant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnProgressRewardGrant&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.definitionType, definitionType) || other.definitionType == definitionType)&&(identical(other.definitionIdentifier, definitionIdentifier) || other.definitionIdentifier == definitionIdentifier)&&(identical(other.definitionTitle, definitionTitle) || other.definitionTitle == definitionTitle)&&(identical(other.rewardToken, rewardToken) || other.rewardToken == rewardToken)&&(identical(other.sourceEventId, sourceEventId) || other.sourceEventId == sourceEventId)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.badgeGrantedAt, badgeGrantedAt) || other.badgeGrantedAt == badgeGrantedAt)&&(identical(other.experienceGrantedAt, experienceGrantedAt) || other.experienceGrantedAt == experienceGrantedAt)&&(identical(other.sourcePointsGrantedAt, sourcePointsGrantedAt) || other.sourcePointsGrantedAt == sourcePointsGrantedAt)&&(identical(other.notificationSentAt, notificationSentAt) || other.notificationSentAt == notificationSentAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,definitionType,definitionIdentifier,definitionTitle,rewardToken,sourceEventId,reward,periodKey,badgeGrantedAt,experienceGrantedAt,sourcePointsGrantedAt,notificationSentAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnProgressRewardGrant(id: $id, accountId: $accountId, definitionType: $definitionType, definitionIdentifier: $definitionIdentifier, definitionTitle: $definitionTitle, rewardToken: $rewardToken, sourceEventId: $sourceEventId, reward: $reward, periodKey: $periodKey, badgeGrantedAt: $badgeGrantedAt, experienceGrantedAt: $experienceGrantedAt, sourcePointsGrantedAt: $sourcePointsGrantedAt, notificationSentAt: $notificationSentAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnProgressRewardGrantCopyWith<$Res>  {
  factory $SnProgressRewardGrantCopyWith(SnProgressRewardGrant value, $Res Function(SnProgressRewardGrant) _then) = _$SnProgressRewardGrantCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String definitionType, String definitionIdentifier, String definitionTitle, String rewardToken, String sourceEventId, SnProgressRewardDefinition? reward, String? periodKey, DateTime? badgeGrantedAt, DateTime? experienceGrantedAt, DateTime? sourcePointsGrantedAt, DateTime? notificationSentAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnProgressRewardDefinitionCopyWith<$Res>? get reward;

}
/// @nodoc
class _$SnProgressRewardGrantCopyWithImpl<$Res>
    implements $SnProgressRewardGrantCopyWith<$Res> {
  _$SnProgressRewardGrantCopyWithImpl(this._self, this._then);

  final SnProgressRewardGrant _self;
  final $Res Function(SnProgressRewardGrant) _then;

/// Create a copy of SnProgressRewardGrant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? definitionType = null,Object? definitionIdentifier = null,Object? definitionTitle = null,Object? rewardToken = null,Object? sourceEventId = null,Object? reward = freezed,Object? periodKey = freezed,Object? badgeGrantedAt = freezed,Object? experienceGrantedAt = freezed,Object? sourcePointsGrantedAt = freezed,Object? notificationSentAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,definitionType: null == definitionType ? _self.definitionType : definitionType // ignore: cast_nullable_to_non_nullable
as String,definitionIdentifier: null == definitionIdentifier ? _self.definitionIdentifier : definitionIdentifier // ignore: cast_nullable_to_non_nullable
as String,definitionTitle: null == definitionTitle ? _self.definitionTitle : definitionTitle // ignore: cast_nullable_to_non_nullable
as String,rewardToken: null == rewardToken ? _self.rewardToken : rewardToken // ignore: cast_nullable_to_non_nullable
as String,sourceEventId: null == sourceEventId ? _self.sourceEventId : sourceEventId // ignore: cast_nullable_to_non_nullable
as String,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as SnProgressRewardDefinition?,periodKey: freezed == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String?,badgeGrantedAt: freezed == badgeGrantedAt ? _self.badgeGrantedAt : badgeGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,experienceGrantedAt: freezed == experienceGrantedAt ? _self.experienceGrantedAt : experienceGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sourcePointsGrantedAt: freezed == sourcePointsGrantedAt ? _self.sourcePointsGrantedAt : sourcePointsGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationSentAt: freezed == notificationSentAt ? _self.notificationSentAt : notificationSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnProgressRewardGrant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<$Res>? get reward {
    if (_self.reward == null) {
    return null;
  }

  return $SnProgressRewardDefinitionCopyWith<$Res>(_self.reward!, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnProgressRewardGrant].
extension SnProgressRewardGrantPatterns on SnProgressRewardGrant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnProgressRewardGrant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnProgressRewardGrant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnProgressRewardGrant value)  $default,){
final _that = this;
switch (_that) {
case _SnProgressRewardGrant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnProgressRewardGrant value)?  $default,){
final _that = this;
switch (_that) {
case _SnProgressRewardGrant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String definitionType,  String definitionIdentifier,  String definitionTitle,  String rewardToken,  String sourceEventId,  SnProgressRewardDefinition? reward,  String? periodKey,  DateTime? badgeGrantedAt,  DateTime? experienceGrantedAt,  DateTime? sourcePointsGrantedAt,  DateTime? notificationSentAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnProgressRewardGrant() when $default != null:
return $default(_that.id,_that.accountId,_that.definitionType,_that.definitionIdentifier,_that.definitionTitle,_that.rewardToken,_that.sourceEventId,_that.reward,_that.periodKey,_that.badgeGrantedAt,_that.experienceGrantedAt,_that.sourcePointsGrantedAt,_that.notificationSentAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String definitionType,  String definitionIdentifier,  String definitionTitle,  String rewardToken,  String sourceEventId,  SnProgressRewardDefinition? reward,  String? periodKey,  DateTime? badgeGrantedAt,  DateTime? experienceGrantedAt,  DateTime? sourcePointsGrantedAt,  DateTime? notificationSentAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnProgressRewardGrant():
return $default(_that.id,_that.accountId,_that.definitionType,_that.definitionIdentifier,_that.definitionTitle,_that.rewardToken,_that.sourceEventId,_that.reward,_that.periodKey,_that.badgeGrantedAt,_that.experienceGrantedAt,_that.sourcePointsGrantedAt,_that.notificationSentAt,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String definitionType,  String definitionIdentifier,  String definitionTitle,  String rewardToken,  String sourceEventId,  SnProgressRewardDefinition? reward,  String? periodKey,  DateTime? badgeGrantedAt,  DateTime? experienceGrantedAt,  DateTime? sourcePointsGrantedAt,  DateTime? notificationSentAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnProgressRewardGrant() when $default != null:
return $default(_that.id,_that.accountId,_that.definitionType,_that.definitionIdentifier,_that.definitionTitle,_that.rewardToken,_that.sourceEventId,_that.reward,_that.periodKey,_that.badgeGrantedAt,_that.experienceGrantedAt,_that.sourcePointsGrantedAt,_that.notificationSentAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnProgressRewardGrant implements SnProgressRewardGrant {
  const _SnProgressRewardGrant({required this.id, required this.accountId, this.definitionType = 'achievement', required this.definitionIdentifier, required this.definitionTitle, required this.rewardToken, required this.sourceEventId, this.reward, this.periodKey, this.badgeGrantedAt, this.experienceGrantedAt, this.sourcePointsGrantedAt, this.notificationSentAt, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory _SnProgressRewardGrant.fromJson(Map<String, dynamic> json) => _$SnProgressRewardGrantFromJson(json);

@override final  String id;
@override final  String accountId;
@override@JsonKey() final  String definitionType;
@override final  String definitionIdentifier;
@override final  String definitionTitle;
@override final  String rewardToken;
@override final  String sourceEventId;
@override final  SnProgressRewardDefinition? reward;
@override final  String? periodKey;
@override final  DateTime? badgeGrantedAt;
@override final  DateTime? experienceGrantedAt;
@override final  DateTime? sourcePointsGrantedAt;
@override final  DateTime? notificationSentAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnProgressRewardGrant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnProgressRewardGrantCopyWith<_SnProgressRewardGrant> get copyWith => __$SnProgressRewardGrantCopyWithImpl<_SnProgressRewardGrant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnProgressRewardGrantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnProgressRewardGrant&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.definitionType, definitionType) || other.definitionType == definitionType)&&(identical(other.definitionIdentifier, definitionIdentifier) || other.definitionIdentifier == definitionIdentifier)&&(identical(other.definitionTitle, definitionTitle) || other.definitionTitle == definitionTitle)&&(identical(other.rewardToken, rewardToken) || other.rewardToken == rewardToken)&&(identical(other.sourceEventId, sourceEventId) || other.sourceEventId == sourceEventId)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.badgeGrantedAt, badgeGrantedAt) || other.badgeGrantedAt == badgeGrantedAt)&&(identical(other.experienceGrantedAt, experienceGrantedAt) || other.experienceGrantedAt == experienceGrantedAt)&&(identical(other.sourcePointsGrantedAt, sourcePointsGrantedAt) || other.sourcePointsGrantedAt == sourcePointsGrantedAt)&&(identical(other.notificationSentAt, notificationSentAt) || other.notificationSentAt == notificationSentAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,definitionType,definitionIdentifier,definitionTitle,rewardToken,sourceEventId,reward,periodKey,badgeGrantedAt,experienceGrantedAt,sourcePointsGrantedAt,notificationSentAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnProgressRewardGrant(id: $id, accountId: $accountId, definitionType: $definitionType, definitionIdentifier: $definitionIdentifier, definitionTitle: $definitionTitle, rewardToken: $rewardToken, sourceEventId: $sourceEventId, reward: $reward, periodKey: $periodKey, badgeGrantedAt: $badgeGrantedAt, experienceGrantedAt: $experienceGrantedAt, sourcePointsGrantedAt: $sourcePointsGrantedAt, notificationSentAt: $notificationSentAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnProgressRewardGrantCopyWith<$Res> implements $SnProgressRewardGrantCopyWith<$Res> {
  factory _$SnProgressRewardGrantCopyWith(_SnProgressRewardGrant value, $Res Function(_SnProgressRewardGrant) _then) = __$SnProgressRewardGrantCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String definitionType, String definitionIdentifier, String definitionTitle, String rewardToken, String sourceEventId, SnProgressRewardDefinition? reward, String? periodKey, DateTime? badgeGrantedAt, DateTime? experienceGrantedAt, DateTime? sourcePointsGrantedAt, DateTime? notificationSentAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnProgressRewardDefinitionCopyWith<$Res>? get reward;

}
/// @nodoc
class __$SnProgressRewardGrantCopyWithImpl<$Res>
    implements _$SnProgressRewardGrantCopyWith<$Res> {
  __$SnProgressRewardGrantCopyWithImpl(this._self, this._then);

  final _SnProgressRewardGrant _self;
  final $Res Function(_SnProgressRewardGrant) _then;

/// Create a copy of SnProgressRewardGrant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? definitionType = null,Object? definitionIdentifier = null,Object? definitionTitle = null,Object? rewardToken = null,Object? sourceEventId = null,Object? reward = freezed,Object? periodKey = freezed,Object? badgeGrantedAt = freezed,Object? experienceGrantedAt = freezed,Object? sourcePointsGrantedAt = freezed,Object? notificationSentAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnProgressRewardGrant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,definitionType: null == definitionType ? _self.definitionType : definitionType // ignore: cast_nullable_to_non_nullable
as String,definitionIdentifier: null == definitionIdentifier ? _self.definitionIdentifier : definitionIdentifier // ignore: cast_nullable_to_non_nullable
as String,definitionTitle: null == definitionTitle ? _self.definitionTitle : definitionTitle // ignore: cast_nullable_to_non_nullable
as String,rewardToken: null == rewardToken ? _self.rewardToken : rewardToken // ignore: cast_nullable_to_non_nullable
as String,sourceEventId: null == sourceEventId ? _self.sourceEventId : sourceEventId // ignore: cast_nullable_to_non_nullable
as String,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as SnProgressRewardDefinition?,periodKey: freezed == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String?,badgeGrantedAt: freezed == badgeGrantedAt ? _self.badgeGrantedAt : badgeGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,experienceGrantedAt: freezed == experienceGrantedAt ? _self.experienceGrantedAt : experienceGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sourcePointsGrantedAt: freezed == sourcePointsGrantedAt ? _self.sourcePointsGrantedAt : sourcePointsGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notificationSentAt: freezed == notificationSentAt ? _self.notificationSentAt : notificationSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnProgressRewardGrant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<$Res>? get reward {
    if (_self.reward == null) {
    return null;
  }

  return $SnProgressRewardDefinitionCopyWith<$Res>(_self.reward!, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// @nodoc
mixin _$SnProgressionCompletedPacket {

 String get kind; String get identifier; String get title; String? get periodKey; SnProgressRewardDefinition? get reward;
/// Create a copy of SnProgressionCompletedPacket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnProgressionCompletedPacketCopyWith<SnProgressionCompletedPacket> get copyWith => _$SnProgressionCompletedPacketCopyWithImpl<SnProgressionCompletedPacket>(this as SnProgressionCompletedPacket, _$identity);

  /// Serializes this SnProgressionCompletedPacket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnProgressionCompletedPacket&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.reward, reward) || other.reward == reward));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,identifier,title,periodKey,reward);

@override
String toString() {
  return 'SnProgressionCompletedPacket(kind: $kind, identifier: $identifier, title: $title, periodKey: $periodKey, reward: $reward)';
}


}

/// @nodoc
abstract mixin class $SnProgressionCompletedPacketCopyWith<$Res>  {
  factory $SnProgressionCompletedPacketCopyWith(SnProgressionCompletedPacket value, $Res Function(SnProgressionCompletedPacket) _then) = _$SnProgressionCompletedPacketCopyWithImpl;
@useResult
$Res call({
 String kind, String identifier, String title, String? periodKey, SnProgressRewardDefinition? reward
});


$SnProgressRewardDefinitionCopyWith<$Res>? get reward;

}
/// @nodoc
class _$SnProgressionCompletedPacketCopyWithImpl<$Res>
    implements $SnProgressionCompletedPacketCopyWith<$Res> {
  _$SnProgressionCompletedPacketCopyWithImpl(this._self, this._then);

  final SnProgressionCompletedPacket _self;
  final $Res Function(SnProgressionCompletedPacket) _then;

/// Create a copy of SnProgressionCompletedPacket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? identifier = null,Object? title = null,Object? periodKey = freezed,Object? reward = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,periodKey: freezed == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String?,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as SnProgressRewardDefinition?,
  ));
}
/// Create a copy of SnProgressionCompletedPacket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<$Res>? get reward {
    if (_self.reward == null) {
    return null;
  }

  return $SnProgressRewardDefinitionCopyWith<$Res>(_self.reward!, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnProgressionCompletedPacket].
extension SnProgressionCompletedPacketPatterns on SnProgressionCompletedPacket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnProgressionCompletedPacket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnProgressionCompletedPacket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnProgressionCompletedPacket value)  $default,){
final _that = this;
switch (_that) {
case _SnProgressionCompletedPacket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnProgressionCompletedPacket value)?  $default,){
final _that = this;
switch (_that) {
case _SnProgressionCompletedPacket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String identifier,  String title,  String? periodKey,  SnProgressRewardDefinition? reward)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnProgressionCompletedPacket() when $default != null:
return $default(_that.kind,_that.identifier,_that.title,_that.periodKey,_that.reward);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String identifier,  String title,  String? periodKey,  SnProgressRewardDefinition? reward)  $default,) {final _that = this;
switch (_that) {
case _SnProgressionCompletedPacket():
return $default(_that.kind,_that.identifier,_that.title,_that.periodKey,_that.reward);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String identifier,  String title,  String? periodKey,  SnProgressRewardDefinition? reward)?  $default,) {final _that = this;
switch (_that) {
case _SnProgressionCompletedPacket() when $default != null:
return $default(_that.kind,_that.identifier,_that.title,_that.periodKey,_that.reward);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnProgressionCompletedPacket implements SnProgressionCompletedPacket {
  const _SnProgressionCompletedPacket({required this.kind, required this.identifier, required this.title, this.periodKey, this.reward});
  factory _SnProgressionCompletedPacket.fromJson(Map<String, dynamic> json) => _$SnProgressionCompletedPacketFromJson(json);

@override final  String kind;
@override final  String identifier;
@override final  String title;
@override final  String? periodKey;
@override final  SnProgressRewardDefinition? reward;

/// Create a copy of SnProgressionCompletedPacket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnProgressionCompletedPacketCopyWith<_SnProgressionCompletedPacket> get copyWith => __$SnProgressionCompletedPacketCopyWithImpl<_SnProgressionCompletedPacket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnProgressionCompletedPacketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnProgressionCompletedPacket&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.periodKey, periodKey) || other.periodKey == periodKey)&&(identical(other.reward, reward) || other.reward == reward));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,identifier,title,periodKey,reward);

@override
String toString() {
  return 'SnProgressionCompletedPacket(kind: $kind, identifier: $identifier, title: $title, periodKey: $periodKey, reward: $reward)';
}


}

/// @nodoc
abstract mixin class _$SnProgressionCompletedPacketCopyWith<$Res> implements $SnProgressionCompletedPacketCopyWith<$Res> {
  factory _$SnProgressionCompletedPacketCopyWith(_SnProgressionCompletedPacket value, $Res Function(_SnProgressionCompletedPacket) _then) = __$SnProgressionCompletedPacketCopyWithImpl;
@override @useResult
$Res call({
 String kind, String identifier, String title, String? periodKey, SnProgressRewardDefinition? reward
});


@override $SnProgressRewardDefinitionCopyWith<$Res>? get reward;

}
/// @nodoc
class __$SnProgressionCompletedPacketCopyWithImpl<$Res>
    implements _$SnProgressionCompletedPacketCopyWith<$Res> {
  __$SnProgressionCompletedPacketCopyWithImpl(this._self, this._then);

  final _SnProgressionCompletedPacket _self;
  final $Res Function(_SnProgressionCompletedPacket) _then;

/// Create a copy of SnProgressionCompletedPacket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? identifier = null,Object? title = null,Object? periodKey = freezed,Object? reward = freezed,}) {
  return _then(_SnProgressionCompletedPacket(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,periodKey: freezed == periodKey ? _self.periodKey : periodKey // ignore: cast_nullable_to_non_nullable
as String?,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as SnProgressRewardDefinition?,
  ));
}

/// Create a copy of SnProgressionCompletedPacket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnProgressRewardDefinitionCopyWith<$Res>? get reward {
    if (_self.reward == null) {
    return null;
  }

  return $SnProgressRewardDefinitionCopyWith<$Res>(_self.reward!, (value) {
    return _then(_self.copyWith(reward: value));
  });
}
}

// dart format on
