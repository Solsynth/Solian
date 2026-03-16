// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'realm_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RealmBoostStatus {

 int get boostPoints; int get boostLevel; int get labelCap; int get expiresAfterDays; List<String> get supportedCurrencies; String get defaultCurrency;
/// Create a copy of RealmBoostStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RealmBoostStatusCopyWith<RealmBoostStatus> get copyWith => _$RealmBoostStatusCopyWithImpl<RealmBoostStatus>(this as RealmBoostStatus, _$identity);

  /// Serializes this RealmBoostStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RealmBoostStatus&&(identical(other.boostPoints, boostPoints) || other.boostPoints == boostPoints)&&(identical(other.boostLevel, boostLevel) || other.boostLevel == boostLevel)&&(identical(other.labelCap, labelCap) || other.labelCap == labelCap)&&(identical(other.expiresAfterDays, expiresAfterDays) || other.expiresAfterDays == expiresAfterDays)&&const DeepCollectionEquality().equals(other.supportedCurrencies, supportedCurrencies)&&(identical(other.defaultCurrency, defaultCurrency) || other.defaultCurrency == defaultCurrency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,boostPoints,boostLevel,labelCap,expiresAfterDays,const DeepCollectionEquality().hash(supportedCurrencies),defaultCurrency);

@override
String toString() {
  return 'RealmBoostStatus(boostPoints: $boostPoints, boostLevel: $boostLevel, labelCap: $labelCap, expiresAfterDays: $expiresAfterDays, supportedCurrencies: $supportedCurrencies, defaultCurrency: $defaultCurrency)';
}


}

/// @nodoc
abstract mixin class $RealmBoostStatusCopyWith<$Res>  {
  factory $RealmBoostStatusCopyWith(RealmBoostStatus value, $Res Function(RealmBoostStatus) _then) = _$RealmBoostStatusCopyWithImpl;
@useResult
$Res call({
 int boostPoints, int boostLevel, int labelCap, int expiresAfterDays, List<String> supportedCurrencies, String defaultCurrency
});




}
/// @nodoc
class _$RealmBoostStatusCopyWithImpl<$Res>
    implements $RealmBoostStatusCopyWith<$Res> {
  _$RealmBoostStatusCopyWithImpl(this._self, this._then);

  final RealmBoostStatus _self;
  final $Res Function(RealmBoostStatus) _then;

/// Create a copy of RealmBoostStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? boostPoints = null,Object? boostLevel = null,Object? labelCap = null,Object? expiresAfterDays = null,Object? supportedCurrencies = null,Object? defaultCurrency = null,}) {
  return _then(_self.copyWith(
boostPoints: null == boostPoints ? _self.boostPoints : boostPoints // ignore: cast_nullable_to_non_nullable
as int,boostLevel: null == boostLevel ? _self.boostLevel : boostLevel // ignore: cast_nullable_to_non_nullable
as int,labelCap: null == labelCap ? _self.labelCap : labelCap // ignore: cast_nullable_to_non_nullable
as int,expiresAfterDays: null == expiresAfterDays ? _self.expiresAfterDays : expiresAfterDays // ignore: cast_nullable_to_non_nullable
as int,supportedCurrencies: null == supportedCurrencies ? _self.supportedCurrencies : supportedCurrencies // ignore: cast_nullable_to_non_nullable
as List<String>,defaultCurrency: null == defaultCurrency ? _self.defaultCurrency : defaultCurrency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RealmBoostStatus].
extension RealmBoostStatusPatterns on RealmBoostStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RealmBoostStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RealmBoostStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RealmBoostStatus value)  $default,){
final _that = this;
switch (_that) {
case _RealmBoostStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RealmBoostStatus value)?  $default,){
final _that = this;
switch (_that) {
case _RealmBoostStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int boostPoints,  int boostLevel,  int labelCap,  int expiresAfterDays,  List<String> supportedCurrencies,  String defaultCurrency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RealmBoostStatus() when $default != null:
return $default(_that.boostPoints,_that.boostLevel,_that.labelCap,_that.expiresAfterDays,_that.supportedCurrencies,_that.defaultCurrency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int boostPoints,  int boostLevel,  int labelCap,  int expiresAfterDays,  List<String> supportedCurrencies,  String defaultCurrency)  $default,) {final _that = this;
switch (_that) {
case _RealmBoostStatus():
return $default(_that.boostPoints,_that.boostLevel,_that.labelCap,_that.expiresAfterDays,_that.supportedCurrencies,_that.defaultCurrency);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int boostPoints,  int boostLevel,  int labelCap,  int expiresAfterDays,  List<String> supportedCurrencies,  String defaultCurrency)?  $default,) {final _that = this;
switch (_that) {
case _RealmBoostStatus() when $default != null:
return $default(_that.boostPoints,_that.boostLevel,_that.labelCap,_that.expiresAfterDays,_that.supportedCurrencies,_that.defaultCurrency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RealmBoostStatus implements RealmBoostStatus {
  const _RealmBoostStatus({required this.boostPoints, required this.boostLevel, required this.labelCap, required this.expiresAfterDays, required final  List<String> supportedCurrencies, required this.defaultCurrency}): _supportedCurrencies = supportedCurrencies;
  factory _RealmBoostStatus.fromJson(Map<String, dynamic> json) => _$RealmBoostStatusFromJson(json);

@override final  int boostPoints;
@override final  int boostLevel;
@override final  int labelCap;
@override final  int expiresAfterDays;
 final  List<String> _supportedCurrencies;
@override List<String> get supportedCurrencies {
  if (_supportedCurrencies is EqualUnmodifiableListView) return _supportedCurrencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_supportedCurrencies);
}

@override final  String defaultCurrency;

/// Create a copy of RealmBoostStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RealmBoostStatusCopyWith<_RealmBoostStatus> get copyWith => __$RealmBoostStatusCopyWithImpl<_RealmBoostStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RealmBoostStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RealmBoostStatus&&(identical(other.boostPoints, boostPoints) || other.boostPoints == boostPoints)&&(identical(other.boostLevel, boostLevel) || other.boostLevel == boostLevel)&&(identical(other.labelCap, labelCap) || other.labelCap == labelCap)&&(identical(other.expiresAfterDays, expiresAfterDays) || other.expiresAfterDays == expiresAfterDays)&&const DeepCollectionEquality().equals(other._supportedCurrencies, _supportedCurrencies)&&(identical(other.defaultCurrency, defaultCurrency) || other.defaultCurrency == defaultCurrency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,boostPoints,boostLevel,labelCap,expiresAfterDays,const DeepCollectionEquality().hash(_supportedCurrencies),defaultCurrency);

@override
String toString() {
  return 'RealmBoostStatus(boostPoints: $boostPoints, boostLevel: $boostLevel, labelCap: $labelCap, expiresAfterDays: $expiresAfterDays, supportedCurrencies: $supportedCurrencies, defaultCurrency: $defaultCurrency)';
}


}

/// @nodoc
abstract mixin class _$RealmBoostStatusCopyWith<$Res> implements $RealmBoostStatusCopyWith<$Res> {
  factory _$RealmBoostStatusCopyWith(_RealmBoostStatus value, $Res Function(_RealmBoostStatus) _then) = __$RealmBoostStatusCopyWithImpl;
@override @useResult
$Res call({
 int boostPoints, int boostLevel, int labelCap, int expiresAfterDays, List<String> supportedCurrencies, String defaultCurrency
});




}
/// @nodoc
class __$RealmBoostStatusCopyWithImpl<$Res>
    implements _$RealmBoostStatusCopyWith<$Res> {
  __$RealmBoostStatusCopyWithImpl(this._self, this._then);

  final _RealmBoostStatus _self;
  final $Res Function(_RealmBoostStatus) _then;

/// Create a copy of RealmBoostStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? boostPoints = null,Object? boostLevel = null,Object? labelCap = null,Object? expiresAfterDays = null,Object? supportedCurrencies = null,Object? defaultCurrency = null,}) {
  return _then(_RealmBoostStatus(
boostPoints: null == boostPoints ? _self.boostPoints : boostPoints // ignore: cast_nullable_to_non_nullable
as int,boostLevel: null == boostLevel ? _self.boostLevel : boostLevel // ignore: cast_nullable_to_non_nullable
as int,labelCap: null == labelCap ? _self.labelCap : labelCap // ignore: cast_nullable_to_non_nullable
as int,expiresAfterDays: null == expiresAfterDays ? _self.expiresAfterDays : expiresAfterDays // ignore: cast_nullable_to_non_nullable
as int,supportedCurrencies: null == supportedCurrencies ? _self._supportedCurrencies : supportedCurrencies // ignore: cast_nullable_to_non_nullable
as List<String>,defaultCurrency: null == defaultCurrency ? _self.defaultCurrency : defaultCurrency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RealmBoostLeaderboardEntry {

 String get accountId; SnAccount? get account; double get amountGolds; double get amountPoints; double get shares; int get boosts; DateTime? get lastBoostedAt;
/// Create a copy of RealmBoostLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RealmBoostLeaderboardEntryCopyWith<RealmBoostLeaderboardEntry> get copyWith => _$RealmBoostLeaderboardEntryCopyWithImpl<RealmBoostLeaderboardEntry>(this as RealmBoostLeaderboardEntry, _$identity);

  /// Serializes this RealmBoostLeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RealmBoostLeaderboardEntry&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.amountGolds, amountGolds) || other.amountGolds == amountGolds)&&(identical(other.amountPoints, amountPoints) || other.amountPoints == amountPoints)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.boosts, boosts) || other.boosts == boosts)&&(identical(other.lastBoostedAt, lastBoostedAt) || other.lastBoostedAt == lastBoostedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,account,amountGolds,amountPoints,shares,boosts,lastBoostedAt);

@override
String toString() {
  return 'RealmBoostLeaderboardEntry(accountId: $accountId, account: $account, amountGolds: $amountGolds, amountPoints: $amountPoints, shares: $shares, boosts: $boosts, lastBoostedAt: $lastBoostedAt)';
}


}

/// @nodoc
abstract mixin class $RealmBoostLeaderboardEntryCopyWith<$Res>  {
  factory $RealmBoostLeaderboardEntryCopyWith(RealmBoostLeaderboardEntry value, $Res Function(RealmBoostLeaderboardEntry) _then) = _$RealmBoostLeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 String accountId, SnAccount? account, double amountGolds, double amountPoints, double shares, int boosts, DateTime? lastBoostedAt
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$RealmBoostLeaderboardEntryCopyWithImpl<$Res>
    implements $RealmBoostLeaderboardEntryCopyWith<$Res> {
  _$RealmBoostLeaderboardEntryCopyWithImpl(this._self, this._then);

  final RealmBoostLeaderboardEntry _self;
  final $Res Function(RealmBoostLeaderboardEntry) _then;

/// Create a copy of RealmBoostLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? account = freezed,Object? amountGolds = null,Object? amountPoints = null,Object? shares = null,Object? boosts = null,Object? lastBoostedAt = freezed,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,amountGolds: null == amountGolds ? _self.amountGolds : amountGolds // ignore: cast_nullable_to_non_nullable
as double,amountPoints: null == amountPoints ? _self.amountPoints : amountPoints // ignore: cast_nullable_to_non_nullable
as double,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as double,boosts: null == boosts ? _self.boosts : boosts // ignore: cast_nullable_to_non_nullable
as int,lastBoostedAt: freezed == lastBoostedAt ? _self.lastBoostedAt : lastBoostedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RealmBoostLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [RealmBoostLeaderboardEntry].
extension RealmBoostLeaderboardEntryPatterns on RealmBoostLeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RealmBoostLeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RealmBoostLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RealmBoostLeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _RealmBoostLeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RealmBoostLeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _RealmBoostLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  SnAccount? account,  double amountGolds,  double amountPoints,  double shares,  int boosts,  DateTime? lastBoostedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RealmBoostLeaderboardEntry() when $default != null:
return $default(_that.accountId,_that.account,_that.amountGolds,_that.amountPoints,_that.shares,_that.boosts,_that.lastBoostedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  SnAccount? account,  double amountGolds,  double amountPoints,  double shares,  int boosts,  DateTime? lastBoostedAt)  $default,) {final _that = this;
switch (_that) {
case _RealmBoostLeaderboardEntry():
return $default(_that.accountId,_that.account,_that.amountGolds,_that.amountPoints,_that.shares,_that.boosts,_that.lastBoostedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  SnAccount? account,  double amountGolds,  double amountPoints,  double shares,  int boosts,  DateTime? lastBoostedAt)?  $default,) {final _that = this;
switch (_that) {
case _RealmBoostLeaderboardEntry() when $default != null:
return $default(_that.accountId,_that.account,_that.amountGolds,_that.amountPoints,_that.shares,_that.boosts,_that.lastBoostedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RealmBoostLeaderboardEntry implements RealmBoostLeaderboardEntry {
  const _RealmBoostLeaderboardEntry({required this.accountId, required this.account, required this.amountGolds, required this.amountPoints, required this.shares, required this.boosts, required this.lastBoostedAt});
  factory _RealmBoostLeaderboardEntry.fromJson(Map<String, dynamic> json) => _$RealmBoostLeaderboardEntryFromJson(json);

@override final  String accountId;
@override final  SnAccount? account;
@override final  double amountGolds;
@override final  double amountPoints;
@override final  double shares;
@override final  int boosts;
@override final  DateTime? lastBoostedAt;

/// Create a copy of RealmBoostLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RealmBoostLeaderboardEntryCopyWith<_RealmBoostLeaderboardEntry> get copyWith => __$RealmBoostLeaderboardEntryCopyWithImpl<_RealmBoostLeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RealmBoostLeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RealmBoostLeaderboardEntry&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.amountGolds, amountGolds) || other.amountGolds == amountGolds)&&(identical(other.amountPoints, amountPoints) || other.amountPoints == amountPoints)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.boosts, boosts) || other.boosts == boosts)&&(identical(other.lastBoostedAt, lastBoostedAt) || other.lastBoostedAt == lastBoostedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,account,amountGolds,amountPoints,shares,boosts,lastBoostedAt);

@override
String toString() {
  return 'RealmBoostLeaderboardEntry(accountId: $accountId, account: $account, amountGolds: $amountGolds, amountPoints: $amountPoints, shares: $shares, boosts: $boosts, lastBoostedAt: $lastBoostedAt)';
}


}

/// @nodoc
abstract mixin class _$RealmBoostLeaderboardEntryCopyWith<$Res> implements $RealmBoostLeaderboardEntryCopyWith<$Res> {
  factory _$RealmBoostLeaderboardEntryCopyWith(_RealmBoostLeaderboardEntry value, $Res Function(_RealmBoostLeaderboardEntry) _then) = __$RealmBoostLeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 String accountId, SnAccount? account, double amountGolds, double amountPoints, double shares, int boosts, DateTime? lastBoostedAt
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$RealmBoostLeaderboardEntryCopyWithImpl<$Res>
    implements _$RealmBoostLeaderboardEntryCopyWith<$Res> {
  __$RealmBoostLeaderboardEntryCopyWithImpl(this._self, this._then);

  final _RealmBoostLeaderboardEntry _self;
  final $Res Function(_RealmBoostLeaderboardEntry) _then;

/// Create a copy of RealmBoostLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? account = freezed,Object? amountGolds = null,Object? amountPoints = null,Object? shares = null,Object? boosts = null,Object? lastBoostedAt = freezed,}) {
  return _then(_RealmBoostLeaderboardEntry(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,amountGolds: null == amountGolds ? _self.amountGolds : amountGolds // ignore: cast_nullable_to_non_nullable
as double,amountPoints: null == amountPoints ? _self.amountPoints : amountPoints // ignore: cast_nullable_to_non_nullable
as double,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as double,boosts: null == boosts ? _self.boosts : boosts // ignore: cast_nullable_to_non_nullable
as int,lastBoostedAt: freezed == lastBoostedAt ? _self.lastBoostedAt : lastBoostedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RealmBoostLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// @nodoc
mixin _$RealmLabel {

 String get id; String get realmId; String get name; String? get description; String? get color; String? get icon; String get createdByAccountId;
/// Create a copy of RealmLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RealmLabelCopyWith<RealmLabel> get copyWith => _$RealmLabelCopyWithImpl<RealmLabel>(this as RealmLabel, _$identity);

  /// Serializes this RealmLabel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RealmLabel&&(identical(other.id, id) || other.id == id)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdByAccountId, createdByAccountId) || other.createdByAccountId == createdByAccountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,realmId,name,description,color,icon,createdByAccountId);

@override
String toString() {
  return 'RealmLabel(id: $id, realmId: $realmId, name: $name, description: $description, color: $color, icon: $icon, createdByAccountId: $createdByAccountId)';
}


}

/// @nodoc
abstract mixin class $RealmLabelCopyWith<$Res>  {
  factory $RealmLabelCopyWith(RealmLabel value, $Res Function(RealmLabel) _then) = _$RealmLabelCopyWithImpl;
@useResult
$Res call({
 String id, String realmId, String name, String? description, String? color, String? icon, String createdByAccountId
});




}
/// @nodoc
class _$RealmLabelCopyWithImpl<$Res>
    implements $RealmLabelCopyWith<$Res> {
  _$RealmLabelCopyWithImpl(this._self, this._then);

  final RealmLabel _self;
  final $Res Function(RealmLabel) _then;

/// Create a copy of RealmLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? realmId = null,Object? name = null,Object? description = freezed,Object? color = freezed,Object? icon = freezed,Object? createdByAccountId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,realmId: null == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,createdByAccountId: null == createdByAccountId ? _self.createdByAccountId : createdByAccountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RealmLabel].
extension RealmLabelPatterns on RealmLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RealmLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RealmLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RealmLabel value)  $default,){
final _that = this;
switch (_that) {
case _RealmLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RealmLabel value)?  $default,){
final _that = this;
switch (_that) {
case _RealmLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String realmId,  String name,  String? description,  String? color,  String? icon,  String createdByAccountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RealmLabel() when $default != null:
return $default(_that.id,_that.realmId,_that.name,_that.description,_that.color,_that.icon,_that.createdByAccountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String realmId,  String name,  String? description,  String? color,  String? icon,  String createdByAccountId)  $default,) {final _that = this;
switch (_that) {
case _RealmLabel():
return $default(_that.id,_that.realmId,_that.name,_that.description,_that.color,_that.icon,_that.createdByAccountId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String realmId,  String name,  String? description,  String? color,  String? icon,  String createdByAccountId)?  $default,) {final _that = this;
switch (_that) {
case _RealmLabel() when $default != null:
return $default(_that.id,_that.realmId,_that.name,_that.description,_that.color,_that.icon,_that.createdByAccountId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RealmLabel implements RealmLabel {
  const _RealmLabel({required this.id, required this.realmId, required this.name, required this.description, required this.color, required this.icon, required this.createdByAccountId});
  factory _RealmLabel.fromJson(Map<String, dynamic> json) => _$RealmLabelFromJson(json);

@override final  String id;
@override final  String realmId;
@override final  String name;
@override final  String? description;
@override final  String? color;
@override final  String? icon;
@override final  String createdByAccountId;

/// Create a copy of RealmLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RealmLabelCopyWith<_RealmLabel> get copyWith => __$RealmLabelCopyWithImpl<_RealmLabel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RealmLabelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RealmLabel&&(identical(other.id, id) || other.id == id)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdByAccountId, createdByAccountId) || other.createdByAccountId == createdByAccountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,realmId,name,description,color,icon,createdByAccountId);

@override
String toString() {
  return 'RealmLabel(id: $id, realmId: $realmId, name: $name, description: $description, color: $color, icon: $icon, createdByAccountId: $createdByAccountId)';
}


}

/// @nodoc
abstract mixin class _$RealmLabelCopyWith<$Res> implements $RealmLabelCopyWith<$Res> {
  factory _$RealmLabelCopyWith(_RealmLabel value, $Res Function(_RealmLabel) _then) = __$RealmLabelCopyWithImpl;
@override @useResult
$Res call({
 String id, String realmId, String name, String? description, String? color, String? icon, String createdByAccountId
});




}
/// @nodoc
class __$RealmLabelCopyWithImpl<$Res>
    implements _$RealmLabelCopyWith<$Res> {
  __$RealmLabelCopyWithImpl(this._self, this._then);

  final _RealmLabel _self;
  final $Res Function(_RealmLabel) _then;

/// Create a copy of RealmLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? realmId = null,Object? name = null,Object? description = freezed,Object? color = freezed,Object? icon = freezed,Object? createdByAccountId = null,}) {
  return _then(_RealmLabel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,realmId: null == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,createdByAccountId: null == createdByAccountId ? _self.createdByAccountId : createdByAccountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
