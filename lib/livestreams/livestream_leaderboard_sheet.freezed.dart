// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestream_leaderboard_sheet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LivestreamAwardLeaderboardEntry {

 int get rank;@JsonKey(name: 'account_id') String get accountId;@JsonKey(name: 'sender_name') String get senderName;@JsonKey(name: 'total_amount') double get totalAmount;@JsonKey(name: 'award_count') int get awardCount; SnAccount? get account;
/// Create a copy of LivestreamAwardLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestreamAwardLeaderboardEntryCopyWith<LivestreamAwardLeaderboardEntry> get copyWith => _$LivestreamAwardLeaderboardEntryCopyWithImpl<LivestreamAwardLeaderboardEntry>(this as LivestreamAwardLeaderboardEntry, _$identity);

  /// Serializes this LivestreamAwardLeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestreamAwardLeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.awardCount, awardCount) || other.awardCount == awardCount)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,accountId,senderName,totalAmount,awardCount,account);

@override
String toString() {
  return 'LivestreamAwardLeaderboardEntry(rank: $rank, accountId: $accountId, senderName: $senderName, totalAmount: $totalAmount, awardCount: $awardCount, account: $account)';
}


}

/// @nodoc
abstract mixin class $LivestreamAwardLeaderboardEntryCopyWith<$Res>  {
  factory $LivestreamAwardLeaderboardEntryCopyWith(LivestreamAwardLeaderboardEntry value, $Res Function(LivestreamAwardLeaderboardEntry) _then) = _$LivestreamAwardLeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 int rank,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'sender_name') String senderName,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'award_count') int awardCount, SnAccount? account
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$LivestreamAwardLeaderboardEntryCopyWithImpl<$Res>
    implements $LivestreamAwardLeaderboardEntryCopyWith<$Res> {
  _$LivestreamAwardLeaderboardEntryCopyWithImpl(this._self, this._then);

  final LivestreamAwardLeaderboardEntry _self;
  final $Res Function(LivestreamAwardLeaderboardEntry) _then;

/// Create a copy of LivestreamAwardLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? accountId = null,Object? senderName = null,Object? totalAmount = null,Object? awardCount = null,Object? account = freezed,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,awardCount: null == awardCount ? _self.awardCount : awardCount // ignore: cast_nullable_to_non_nullable
as int,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}
/// Create a copy of LivestreamAwardLeaderboardEntry
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


/// Adds pattern-matching-related methods to [LivestreamAwardLeaderboardEntry].
extension LivestreamAwardLeaderboardEntryPatterns on LivestreamAwardLeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LivestreamAwardLeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LivestreamAwardLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LivestreamAwardLeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _LivestreamAwardLeaderboardEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LivestreamAwardLeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LivestreamAwardLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'sender_name')  String senderName, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'award_count')  int awardCount,  SnAccount? account)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LivestreamAwardLeaderboardEntry() when $default != null:
return $default(_that.rank,_that.accountId,_that.senderName,_that.totalAmount,_that.awardCount,_that.account);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'sender_name')  String senderName, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'award_count')  int awardCount,  SnAccount? account)  $default,) {final _that = this;
switch (_that) {
case _LivestreamAwardLeaderboardEntry():
return $default(_that.rank,_that.accountId,_that.senderName,_that.totalAmount,_that.awardCount,_that.account);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank, @JsonKey(name: 'account_id')  String accountId, @JsonKey(name: 'sender_name')  String senderName, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'award_count')  int awardCount,  SnAccount? account)?  $default,) {final _that = this;
switch (_that) {
case _LivestreamAwardLeaderboardEntry() when $default != null:
return $default(_that.rank,_that.accountId,_that.senderName,_that.totalAmount,_that.awardCount,_that.account);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LivestreamAwardLeaderboardEntry implements LivestreamAwardLeaderboardEntry {
  const _LivestreamAwardLeaderboardEntry({this.rank = 0, @JsonKey(name: 'account_id') this.accountId = '', @JsonKey(name: 'sender_name') this.senderName = 'Unknown', @JsonKey(name: 'total_amount') this.totalAmount = 0.0, @JsonKey(name: 'award_count') this.awardCount = 0, this.account});
  factory _LivestreamAwardLeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LivestreamAwardLeaderboardEntryFromJson(json);

@override@JsonKey() final  int rank;
@override@JsonKey(name: 'account_id') final  String accountId;
@override@JsonKey(name: 'sender_name') final  String senderName;
@override@JsonKey(name: 'total_amount') final  double totalAmount;
@override@JsonKey(name: 'award_count') final  int awardCount;
@override final  SnAccount? account;

/// Create a copy of LivestreamAwardLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LivestreamAwardLeaderboardEntryCopyWith<_LivestreamAwardLeaderboardEntry> get copyWith => __$LivestreamAwardLeaderboardEntryCopyWithImpl<_LivestreamAwardLeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LivestreamAwardLeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LivestreamAwardLeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.awardCount, awardCount) || other.awardCount == awardCount)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,accountId,senderName,totalAmount,awardCount,account);

@override
String toString() {
  return 'LivestreamAwardLeaderboardEntry(rank: $rank, accountId: $accountId, senderName: $senderName, totalAmount: $totalAmount, awardCount: $awardCount, account: $account)';
}


}

/// @nodoc
abstract mixin class _$LivestreamAwardLeaderboardEntryCopyWith<$Res> implements $LivestreamAwardLeaderboardEntryCopyWith<$Res> {
  factory _$LivestreamAwardLeaderboardEntryCopyWith(_LivestreamAwardLeaderboardEntry value, $Res Function(_LivestreamAwardLeaderboardEntry) _then) = __$LivestreamAwardLeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 int rank,@JsonKey(name: 'account_id') String accountId,@JsonKey(name: 'sender_name') String senderName,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'award_count') int awardCount, SnAccount? account
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$LivestreamAwardLeaderboardEntryCopyWithImpl<$Res>
    implements _$LivestreamAwardLeaderboardEntryCopyWith<$Res> {
  __$LivestreamAwardLeaderboardEntryCopyWithImpl(this._self, this._then);

  final _LivestreamAwardLeaderboardEntry _self;
  final $Res Function(_LivestreamAwardLeaderboardEntry) _then;

/// Create a copy of LivestreamAwardLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? accountId = null,Object? senderName = null,Object? totalAmount = null,Object? awardCount = null,Object? account = freezed,}) {
  return _then(_LivestreamAwardLeaderboardEntry(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,awardCount: null == awardCount ? _self.awardCount : awardCount // ignore: cast_nullable_to_non_nullable
as int,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}

/// Create a copy of LivestreamAwardLeaderboardEntry
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

// dart format on
