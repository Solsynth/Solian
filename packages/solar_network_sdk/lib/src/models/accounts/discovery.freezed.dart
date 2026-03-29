// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discovery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnDiscoveryProfile {

 DateTime get generatedAt; List<SnDiscoveryInterest> get interests; List<SnSuggestedData> get suggestedPublishers; List<SnSuggestedData> get suggestedAccounts; List<SnSuggestedData> get suggestedRealms; List<dynamic> get suppressed;
/// Create a copy of SnDiscoveryProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnDiscoveryProfileCopyWith<SnDiscoveryProfile> get copyWith => _$SnDiscoveryProfileCopyWithImpl<SnDiscoveryProfile>(this as SnDiscoveryProfile, _$identity);

  /// Serializes this SnDiscoveryProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnDiscoveryProfile&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.interests, interests)&&const DeepCollectionEquality().equals(other.suggestedPublishers, suggestedPublishers)&&const DeepCollectionEquality().equals(other.suggestedAccounts, suggestedAccounts)&&const DeepCollectionEquality().equals(other.suggestedRealms, suggestedRealms)&&const DeepCollectionEquality().equals(other.suppressed, suppressed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,generatedAt,const DeepCollectionEquality().hash(interests),const DeepCollectionEquality().hash(suggestedPublishers),const DeepCollectionEquality().hash(suggestedAccounts),const DeepCollectionEquality().hash(suggestedRealms),const DeepCollectionEquality().hash(suppressed));

@override
String toString() {
  return 'SnDiscoveryProfile(generatedAt: $generatedAt, interests: $interests, suggestedPublishers: $suggestedPublishers, suggestedAccounts: $suggestedAccounts, suggestedRealms: $suggestedRealms, suppressed: $suppressed)';
}


}

/// @nodoc
abstract mixin class $SnDiscoveryProfileCopyWith<$Res>  {
  factory $SnDiscoveryProfileCopyWith(SnDiscoveryProfile value, $Res Function(SnDiscoveryProfile) _then) = _$SnDiscoveryProfileCopyWithImpl;
@useResult
$Res call({
 DateTime generatedAt, List<SnDiscoveryInterest> interests, List<SnSuggestedData> suggestedPublishers, List<SnSuggestedData> suggestedAccounts, List<SnSuggestedData> suggestedRealms, List<dynamic> suppressed
});




}
/// @nodoc
class _$SnDiscoveryProfileCopyWithImpl<$Res>
    implements $SnDiscoveryProfileCopyWith<$Res> {
  _$SnDiscoveryProfileCopyWithImpl(this._self, this._then);

  final SnDiscoveryProfile _self;
  final $Res Function(SnDiscoveryProfile) _then;

/// Create a copy of SnDiscoveryProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? generatedAt = null,Object? interests = null,Object? suggestedPublishers = null,Object? suggestedAccounts = null,Object? suggestedRealms = null,Object? suppressed = null,}) {
  return _then(_self.copyWith(
generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<SnDiscoveryInterest>,suggestedPublishers: null == suggestedPublishers ? _self.suggestedPublishers : suggestedPublishers // ignore: cast_nullable_to_non_nullable
as List<SnSuggestedData>,suggestedAccounts: null == suggestedAccounts ? _self.suggestedAccounts : suggestedAccounts // ignore: cast_nullable_to_non_nullable
as List<SnSuggestedData>,suggestedRealms: null == suggestedRealms ? _self.suggestedRealms : suggestedRealms // ignore: cast_nullable_to_non_nullable
as List<SnSuggestedData>,suppressed: null == suppressed ? _self.suppressed : suppressed // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnDiscoveryProfile].
extension SnDiscoveryProfilePatterns on SnDiscoveryProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnDiscoveryProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnDiscoveryProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnDiscoveryProfile value)  $default,){
final _that = this;
switch (_that) {
case _SnDiscoveryProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnDiscoveryProfile value)?  $default,){
final _that = this;
switch (_that) {
case _SnDiscoveryProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime generatedAt,  List<SnDiscoveryInterest> interests,  List<SnSuggestedData> suggestedPublishers,  List<SnSuggestedData> suggestedAccounts,  List<SnSuggestedData> suggestedRealms,  List<dynamic> suppressed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnDiscoveryProfile() when $default != null:
return $default(_that.generatedAt,_that.interests,_that.suggestedPublishers,_that.suggestedAccounts,_that.suggestedRealms,_that.suppressed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime generatedAt,  List<SnDiscoveryInterest> interests,  List<SnSuggestedData> suggestedPublishers,  List<SnSuggestedData> suggestedAccounts,  List<SnSuggestedData> suggestedRealms,  List<dynamic> suppressed)  $default,) {final _that = this;
switch (_that) {
case _SnDiscoveryProfile():
return $default(_that.generatedAt,_that.interests,_that.suggestedPublishers,_that.suggestedAccounts,_that.suggestedRealms,_that.suppressed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime generatedAt,  List<SnDiscoveryInterest> interests,  List<SnSuggestedData> suggestedPublishers,  List<SnSuggestedData> suggestedAccounts,  List<SnSuggestedData> suggestedRealms,  List<dynamic> suppressed)?  $default,) {final _that = this;
switch (_that) {
case _SnDiscoveryProfile() when $default != null:
return $default(_that.generatedAt,_that.interests,_that.suggestedPublishers,_that.suggestedAccounts,_that.suggestedRealms,_that.suppressed);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _SnDiscoveryProfile implements SnDiscoveryProfile {
  const _SnDiscoveryProfile({required this.generatedAt, required final  List<SnDiscoveryInterest> interests, required final  List<SnSuggestedData> suggestedPublishers, required final  List<SnSuggestedData> suggestedAccounts, required final  List<SnSuggestedData> suggestedRealms, required final  List<dynamic> suppressed}): _interests = interests,_suggestedPublishers = suggestedPublishers,_suggestedAccounts = suggestedAccounts,_suggestedRealms = suggestedRealms,_suppressed = suppressed;
  factory _SnDiscoveryProfile.fromJson(Map<String, dynamic> json) => _$SnDiscoveryProfileFromJson(json);

@override final  DateTime generatedAt;
 final  List<SnDiscoveryInterest> _interests;
@override List<SnDiscoveryInterest> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

 final  List<SnSuggestedData> _suggestedPublishers;
@override List<SnSuggestedData> get suggestedPublishers {
  if (_suggestedPublishers is EqualUnmodifiableListView) return _suggestedPublishers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestedPublishers);
}

 final  List<SnSuggestedData> _suggestedAccounts;
@override List<SnSuggestedData> get suggestedAccounts {
  if (_suggestedAccounts is EqualUnmodifiableListView) return _suggestedAccounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestedAccounts);
}

 final  List<SnSuggestedData> _suggestedRealms;
@override List<SnSuggestedData> get suggestedRealms {
  if (_suggestedRealms is EqualUnmodifiableListView) return _suggestedRealms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestedRealms);
}

 final  List<dynamic> _suppressed;
@override List<dynamic> get suppressed {
  if (_suppressed is EqualUnmodifiableListView) return _suppressed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suppressed);
}


/// Create a copy of SnDiscoveryProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnDiscoveryProfileCopyWith<_SnDiscoveryProfile> get copyWith => __$SnDiscoveryProfileCopyWithImpl<_SnDiscoveryProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnDiscoveryProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnDiscoveryProfile&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other._interests, _interests)&&const DeepCollectionEquality().equals(other._suggestedPublishers, _suggestedPublishers)&&const DeepCollectionEquality().equals(other._suggestedAccounts, _suggestedAccounts)&&const DeepCollectionEquality().equals(other._suggestedRealms, _suggestedRealms)&&const DeepCollectionEquality().equals(other._suppressed, _suppressed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,generatedAt,const DeepCollectionEquality().hash(_interests),const DeepCollectionEquality().hash(_suggestedPublishers),const DeepCollectionEquality().hash(_suggestedAccounts),const DeepCollectionEquality().hash(_suggestedRealms),const DeepCollectionEquality().hash(_suppressed));

@override
String toString() {
  return 'SnDiscoveryProfile(generatedAt: $generatedAt, interests: $interests, suggestedPublishers: $suggestedPublishers, suggestedAccounts: $suggestedAccounts, suggestedRealms: $suggestedRealms, suppressed: $suppressed)';
}


}

/// @nodoc
abstract mixin class _$SnDiscoveryProfileCopyWith<$Res> implements $SnDiscoveryProfileCopyWith<$Res> {
  factory _$SnDiscoveryProfileCopyWith(_SnDiscoveryProfile value, $Res Function(_SnDiscoveryProfile) _then) = __$SnDiscoveryProfileCopyWithImpl;
@override @useResult
$Res call({
 DateTime generatedAt, List<SnDiscoveryInterest> interests, List<SnSuggestedData> suggestedPublishers, List<SnSuggestedData> suggestedAccounts, List<SnSuggestedData> suggestedRealms, List<dynamic> suppressed
});




}
/// @nodoc
class __$SnDiscoveryProfileCopyWithImpl<$Res>
    implements _$SnDiscoveryProfileCopyWith<$Res> {
  __$SnDiscoveryProfileCopyWithImpl(this._self, this._then);

  final _SnDiscoveryProfile _self;
  final $Res Function(_SnDiscoveryProfile) _then;

/// Create a copy of SnDiscoveryProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? generatedAt = null,Object? interests = null,Object? suggestedPublishers = null,Object? suggestedAccounts = null,Object? suggestedRealms = null,Object? suppressed = null,}) {
  return _then(_SnDiscoveryProfile(
generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<SnDiscoveryInterest>,suggestedPublishers: null == suggestedPublishers ? _self._suggestedPublishers : suggestedPublishers // ignore: cast_nullable_to_non_nullable
as List<SnSuggestedData>,suggestedAccounts: null == suggestedAccounts ? _self._suggestedAccounts : suggestedAccounts // ignore: cast_nullable_to_non_nullable
as List<SnSuggestedData>,suggestedRealms: null == suggestedRealms ? _self._suggestedRealms : suggestedRealms // ignore: cast_nullable_to_non_nullable
as List<SnSuggestedData>,suppressed: null == suppressed ? _self._suppressed : suppressed // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}


/// @nodoc
mixin _$SnDiscoveryInterest {

 String get kind; String get referenceId; String get label; double get score; int get interactionCount; DateTime get lastInteractedAt; String get lastSignalType;
/// Create a copy of SnDiscoveryInterest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnDiscoveryInterestCopyWith<SnDiscoveryInterest> get copyWith => _$SnDiscoveryInterestCopyWithImpl<SnDiscoveryInterest>(this as SnDiscoveryInterest, _$identity);

  /// Serializes this SnDiscoveryInterest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnDiscoveryInterest&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.label, label) || other.label == label)&&(identical(other.score, score) || other.score == score)&&(identical(other.interactionCount, interactionCount) || other.interactionCount == interactionCount)&&(identical(other.lastInteractedAt, lastInteractedAt) || other.lastInteractedAt == lastInteractedAt)&&(identical(other.lastSignalType, lastSignalType) || other.lastSignalType == lastSignalType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,referenceId,label,score,interactionCount,lastInteractedAt,lastSignalType);

@override
String toString() {
  return 'SnDiscoveryInterest(kind: $kind, referenceId: $referenceId, label: $label, score: $score, interactionCount: $interactionCount, lastInteractedAt: $lastInteractedAt, lastSignalType: $lastSignalType)';
}


}

/// @nodoc
abstract mixin class $SnDiscoveryInterestCopyWith<$Res>  {
  factory $SnDiscoveryInterestCopyWith(SnDiscoveryInterest value, $Res Function(SnDiscoveryInterest) _then) = _$SnDiscoveryInterestCopyWithImpl;
@useResult
$Res call({
 String kind, String referenceId, String label, double score, int interactionCount, DateTime lastInteractedAt, String lastSignalType
});




}
/// @nodoc
class _$SnDiscoveryInterestCopyWithImpl<$Res>
    implements $SnDiscoveryInterestCopyWith<$Res> {
  _$SnDiscoveryInterestCopyWithImpl(this._self, this._then);

  final SnDiscoveryInterest _self;
  final $Res Function(SnDiscoveryInterest) _then;

/// Create a copy of SnDiscoveryInterest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? referenceId = null,Object? label = null,Object? score = null,Object? interactionCount = null,Object? lastInteractedAt = null,Object? lastSignalType = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,interactionCount: null == interactionCount ? _self.interactionCount : interactionCount // ignore: cast_nullable_to_non_nullable
as int,lastInteractedAt: null == lastInteractedAt ? _self.lastInteractedAt : lastInteractedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSignalType: null == lastSignalType ? _self.lastSignalType : lastSignalType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnDiscoveryInterest].
extension SnDiscoveryInterestPatterns on SnDiscoveryInterest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnDiscoveryInterest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnDiscoveryInterest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnDiscoveryInterest value)  $default,){
final _that = this;
switch (_that) {
case _SnDiscoveryInterest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnDiscoveryInterest value)?  $default,){
final _that = this;
switch (_that) {
case _SnDiscoveryInterest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String referenceId,  String label,  double score,  int interactionCount,  DateTime lastInteractedAt,  String lastSignalType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnDiscoveryInterest() when $default != null:
return $default(_that.kind,_that.referenceId,_that.label,_that.score,_that.interactionCount,_that.lastInteractedAt,_that.lastSignalType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String referenceId,  String label,  double score,  int interactionCount,  DateTime lastInteractedAt,  String lastSignalType)  $default,) {final _that = this;
switch (_that) {
case _SnDiscoveryInterest():
return $default(_that.kind,_that.referenceId,_that.label,_that.score,_that.interactionCount,_that.lastInteractedAt,_that.lastSignalType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String referenceId,  String label,  double score,  int interactionCount,  DateTime lastInteractedAt,  String lastSignalType)?  $default,) {final _that = this;
switch (_that) {
case _SnDiscoveryInterest() when $default != null:
return $default(_that.kind,_that.referenceId,_that.label,_that.score,_that.interactionCount,_that.lastInteractedAt,_that.lastSignalType);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _SnDiscoveryInterest implements SnDiscoveryInterest {
  const _SnDiscoveryInterest({required this.kind, required this.referenceId, required this.label, required this.score, required this.interactionCount, required this.lastInteractedAt, required this.lastSignalType});
  factory _SnDiscoveryInterest.fromJson(Map<String, dynamic> json) => _$SnDiscoveryInterestFromJson(json);

@override final  String kind;
@override final  String referenceId;
@override final  String label;
@override final  double score;
@override final  int interactionCount;
@override final  DateTime lastInteractedAt;
@override final  String lastSignalType;

/// Create a copy of SnDiscoveryInterest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnDiscoveryInterestCopyWith<_SnDiscoveryInterest> get copyWith => __$SnDiscoveryInterestCopyWithImpl<_SnDiscoveryInterest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnDiscoveryInterestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnDiscoveryInterest&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.label, label) || other.label == label)&&(identical(other.score, score) || other.score == score)&&(identical(other.interactionCount, interactionCount) || other.interactionCount == interactionCount)&&(identical(other.lastInteractedAt, lastInteractedAt) || other.lastInteractedAt == lastInteractedAt)&&(identical(other.lastSignalType, lastSignalType) || other.lastSignalType == lastSignalType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,referenceId,label,score,interactionCount,lastInteractedAt,lastSignalType);

@override
String toString() {
  return 'SnDiscoveryInterest(kind: $kind, referenceId: $referenceId, label: $label, score: $score, interactionCount: $interactionCount, lastInteractedAt: $lastInteractedAt, lastSignalType: $lastSignalType)';
}


}

/// @nodoc
abstract mixin class _$SnDiscoveryInterestCopyWith<$Res> implements $SnDiscoveryInterestCopyWith<$Res> {
  factory _$SnDiscoveryInterestCopyWith(_SnDiscoveryInterest value, $Res Function(_SnDiscoveryInterest) _then) = __$SnDiscoveryInterestCopyWithImpl;
@override @useResult
$Res call({
 String kind, String referenceId, String label, double score, int interactionCount, DateTime lastInteractedAt, String lastSignalType
});




}
/// @nodoc
class __$SnDiscoveryInterestCopyWithImpl<$Res>
    implements _$SnDiscoveryInterestCopyWith<$Res> {
  __$SnDiscoveryInterestCopyWithImpl(this._self, this._then);

  final _SnDiscoveryInterest _self;
  final $Res Function(_SnDiscoveryInterest) _then;

/// Create a copy of SnDiscoveryInterest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? referenceId = null,Object? label = null,Object? score = null,Object? interactionCount = null,Object? lastInteractedAt = null,Object? lastSignalType = null,}) {
  return _then(_SnDiscoveryInterest(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,interactionCount: null == interactionCount ? _self.interactionCount : interactionCount // ignore: cast_nullable_to_non_nullable
as int,lastInteractedAt: null == lastInteractedAt ? _self.lastInteractedAt : lastInteractedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastSignalType: null == lastSignalType ? _self.lastSignalType : lastSignalType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnSuggestedData {

 int get kind; String get referenceId; String get label; double get score; List<String> get reasons; dynamic get data;
/// Create a copy of SnSuggestedData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSuggestedDataCopyWith<SnSuggestedData> get copyWith => _$SnSuggestedDataCopyWithImpl<SnSuggestedData>(this as SnSuggestedData, _$identity);

  /// Serializes this SnSuggestedData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSuggestedData&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.label, label) || other.label == label)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.reasons, reasons)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,referenceId,label,score,const DeepCollectionEquality().hash(reasons),const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SnSuggestedData(kind: $kind, referenceId: $referenceId, label: $label, score: $score, reasons: $reasons, data: $data)';
}


}

/// @nodoc
abstract mixin class $SnSuggestedDataCopyWith<$Res>  {
  factory $SnSuggestedDataCopyWith(SnSuggestedData value, $Res Function(SnSuggestedData) _then) = _$SnSuggestedDataCopyWithImpl;
@useResult
$Res call({
 int kind, String referenceId, String label, double score, List<String> reasons, dynamic data
});




}
/// @nodoc
class _$SnSuggestedDataCopyWithImpl<$Res>
    implements $SnSuggestedDataCopyWith<$Res> {
  _$SnSuggestedDataCopyWithImpl(this._self, this._then);

  final SnSuggestedData _self;
  final $Res Function(SnSuggestedData) _then;

/// Create a copy of SnSuggestedData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? referenceId = null,Object? label = null,Object? score = null,Object? reasons = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [SnSuggestedData].
extension SnSuggestedDataPatterns on SnSuggestedData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSuggestedData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSuggestedData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSuggestedData value)  $default,){
final _that = this;
switch (_that) {
case _SnSuggestedData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSuggestedData value)?  $default,){
final _that = this;
switch (_that) {
case _SnSuggestedData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int kind,  String referenceId,  String label,  double score,  List<String> reasons,  dynamic data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSuggestedData() when $default != null:
return $default(_that.kind,_that.referenceId,_that.label,_that.score,_that.reasons,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int kind,  String referenceId,  String label,  double score,  List<String> reasons,  dynamic data)  $default,) {final _that = this;
switch (_that) {
case _SnSuggestedData():
return $default(_that.kind,_that.referenceId,_that.label,_that.score,_that.reasons,_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int kind,  String referenceId,  String label,  double score,  List<String> reasons,  dynamic data)?  $default,) {final _that = this;
switch (_that) {
case _SnSuggestedData() when $default != null:
return $default(_that.kind,_that.referenceId,_that.label,_that.score,_that.reasons,_that.data);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable()
class _SnSuggestedData implements SnSuggestedData {
  const _SnSuggestedData({required this.kind, required this.referenceId, required this.label, required this.score, required final  List<String> reasons, required this.data}): _reasons = reasons;
  factory _SnSuggestedData.fromJson(Map<String, dynamic> json) => _$SnSuggestedDataFromJson(json);

@override final  int kind;
@override final  String referenceId;
@override final  String label;
@override final  double score;
 final  List<String> _reasons;
@override List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

@override final  dynamic data;

/// Create a copy of SnSuggestedData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSuggestedDataCopyWith<_SnSuggestedData> get copyWith => __$SnSuggestedDataCopyWithImpl<_SnSuggestedData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSuggestedDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSuggestedData&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.label, label) || other.label == label)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._reasons, _reasons)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,referenceId,label,score,const DeepCollectionEquality().hash(_reasons),const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SnSuggestedData(kind: $kind, referenceId: $referenceId, label: $label, score: $score, reasons: $reasons, data: $data)';
}


}

/// @nodoc
abstract mixin class _$SnSuggestedDataCopyWith<$Res> implements $SnSuggestedDataCopyWith<$Res> {
  factory _$SnSuggestedDataCopyWith(_SnSuggestedData value, $Res Function(_SnSuggestedData) _then) = __$SnSuggestedDataCopyWithImpl;
@override @useResult
$Res call({
 int kind, String referenceId, String label, double score, List<String> reasons, dynamic data
});




}
/// @nodoc
class __$SnSuggestedDataCopyWithImpl<$Res>
    implements _$SnSuggestedDataCopyWith<$Res> {
  __$SnSuggestedDataCopyWithImpl(this._self, this._then);

  final _SnSuggestedData _self;
  final $Res Function(_SnSuggestedData) _then;

/// Create a copy of SnSuggestedData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? referenceId = null,Object? label = null,Object? score = null,Object? reasons = null,Object? data = freezed,}) {
  return _then(_SnSuggestedData(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as int,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
