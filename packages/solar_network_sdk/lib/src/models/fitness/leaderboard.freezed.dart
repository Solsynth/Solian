// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaderboardEntry {

 int get rank; String get accountId; double get value; SnAccount? get account;
/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith => _$LeaderboardEntryCopyWithImpl<LeaderboardEntry>(this as LeaderboardEntry, _$identity);

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.value, value) || other.value == value)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,accountId,value,account);

@override
String toString() {
  return 'LeaderboardEntry(rank: $rank, accountId: $accountId, value: $value, account: $account)';
}


}

/// @nodoc
abstract mixin class $LeaderboardEntryCopyWith<$Res>  {
  factory $LeaderboardEntryCopyWith(LeaderboardEntry value, $Res Function(LeaderboardEntry) _then) = _$LeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 int rank, String accountId, double value, SnAccount? account
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final LeaderboardEntry _self;
  final $Res Function(LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? accountId = null,Object? value = null,Object? account = freezed,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}
/// Create a copy of LeaderboardEntry
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


/// Adds pattern-matching-related methods to [LeaderboardEntry].
extension LeaderboardEntryPatterns on LeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank,  String accountId,  double value,  SnAccount? account)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.rank,_that.accountId,_that.value,_that.account);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank,  String accountId,  double value,  SnAccount? account)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry():
return $default(_that.rank,_that.accountId,_that.value,_that.account);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank,  String accountId,  double value,  SnAccount? account)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.rank,_that.accountId,_that.value,_that.account);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardEntry implements LeaderboardEntry {
  const _LeaderboardEntry({required this.rank, required this.accountId, required this.value, this.account});
  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);

@override final  int rank;
@override final  String accountId;
@override final  double value;
@override final  SnAccount? account;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardEntryCopyWith<_LeaderboardEntry> get copyWith => __$LeaderboardEntryCopyWithImpl<_LeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.value, value) || other.value == value)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,accountId,value,account);

@override
String toString() {
  return 'LeaderboardEntry(rank: $rank, accountId: $accountId, value: $value, account: $account)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardEntryCopyWith<$Res> implements $LeaderboardEntryCopyWith<$Res> {
  factory _$LeaderboardEntryCopyWith(_LeaderboardEntry value, $Res Function(_LeaderboardEntry) _then) = __$LeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 int rank, String accountId, double value, SnAccount? account
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$LeaderboardEntryCopyWithImpl<$Res>
    implements _$LeaderboardEntryCopyWith<$Res> {
  __$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final _LeaderboardEntry _self;
  final $Res Function(_LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? accountId = null,Object? value = null,Object? account = freezed,}) {
  return _then(_LeaderboardEntry(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}

/// Create a copy of LeaderboardEntry
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
mixin _$LeaderboardResponse {

 List<LeaderboardEntry> get entries; LeaderboardEntry? get userEntry; int get totalCount;
/// Create a copy of LeaderboardResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardResponseCopyWith<LeaderboardResponse> get copyWith => _$LeaderboardResponseCopyWithImpl<LeaderboardResponse>(this as LeaderboardResponse, _$identity);

  /// Serializes this LeaderboardResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardResponse&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.userEntry, userEntry) || other.userEntry == userEntry)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries),userEntry,totalCount);

@override
String toString() {
  return 'LeaderboardResponse(entries: $entries, userEntry: $userEntry, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class $LeaderboardResponseCopyWith<$Res>  {
  factory $LeaderboardResponseCopyWith(LeaderboardResponse value, $Res Function(LeaderboardResponse) _then) = _$LeaderboardResponseCopyWithImpl;
@useResult
$Res call({
 List<LeaderboardEntry> entries, LeaderboardEntry? userEntry, int totalCount
});


$LeaderboardEntryCopyWith<$Res>? get userEntry;

}
/// @nodoc
class _$LeaderboardResponseCopyWithImpl<$Res>
    implements $LeaderboardResponseCopyWith<$Res> {
  _$LeaderboardResponseCopyWithImpl(this._self, this._then);

  final LeaderboardResponse _self;
  final $Res Function(LeaderboardResponse) _then;

/// Create a copy of LeaderboardResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? userEntry = freezed,Object? totalCount = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<LeaderboardEntry>,userEntry: freezed == userEntry ? _self.userEntry : userEntry // ignore: cast_nullable_to_non_nullable
as LeaderboardEntry?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of LeaderboardResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<$Res>? get userEntry {
    if (_self.userEntry == null) {
    return null;
  }

  return $LeaderboardEntryCopyWith<$Res>(_self.userEntry!, (value) {
    return _then(_self.copyWith(userEntry: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeaderboardResponse].
extension LeaderboardResponsePatterns on LeaderboardResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardResponse value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LeaderboardEntry> entries,  LeaderboardEntry? userEntry,  int totalCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardResponse() when $default != null:
return $default(_that.entries,_that.userEntry,_that.totalCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LeaderboardEntry> entries,  LeaderboardEntry? userEntry,  int totalCount)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardResponse():
return $default(_that.entries,_that.userEntry,_that.totalCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LeaderboardEntry> entries,  LeaderboardEntry? userEntry,  int totalCount)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardResponse() when $default != null:
return $default(_that.entries,_that.userEntry,_that.totalCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardResponse implements LeaderboardResponse {
  const _LeaderboardResponse({required final  List<LeaderboardEntry> entries, this.userEntry, required this.totalCount}): _entries = entries;
  factory _LeaderboardResponse.fromJson(Map<String, dynamic> json) => _$LeaderboardResponseFromJson(json);

 final  List<LeaderboardEntry> _entries;
@override List<LeaderboardEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  LeaderboardEntry? userEntry;
@override final  int totalCount;

/// Create a copy of LeaderboardResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardResponseCopyWith<_LeaderboardResponse> get copyWith => __$LeaderboardResponseCopyWithImpl<_LeaderboardResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardResponse&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.userEntry, userEntry) || other.userEntry == userEntry)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),userEntry,totalCount);

@override
String toString() {
  return 'LeaderboardResponse(entries: $entries, userEntry: $userEntry, totalCount: $totalCount)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardResponseCopyWith<$Res> implements $LeaderboardResponseCopyWith<$Res> {
  factory _$LeaderboardResponseCopyWith(_LeaderboardResponse value, $Res Function(_LeaderboardResponse) _then) = __$LeaderboardResponseCopyWithImpl;
@override @useResult
$Res call({
 List<LeaderboardEntry> entries, LeaderboardEntry? userEntry, int totalCount
});


@override $LeaderboardEntryCopyWith<$Res>? get userEntry;

}
/// @nodoc
class __$LeaderboardResponseCopyWithImpl<$Res>
    implements _$LeaderboardResponseCopyWith<$Res> {
  __$LeaderboardResponseCopyWithImpl(this._self, this._then);

  final _LeaderboardResponse _self;
  final $Res Function(_LeaderboardResponse) _then;

/// Create a copy of LeaderboardResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? userEntry = freezed,Object? totalCount = null,}) {
  return _then(_LeaderboardResponse(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<LeaderboardEntry>,userEntry: freezed == userEntry ? _self.userEntry : userEntry // ignore: cast_nullable_to_non_nullable
as LeaderboardEntry?,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of LeaderboardResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<$Res>? get userEntry {
    if (_self.userEntry == null) {
    return null;
  }

  return $LeaderboardEntryCopyWith<$Res>(_self.userEntry!, (value) {
    return _then(_self.copyWith(userEntry: value));
  });
}
}

// dart format on
