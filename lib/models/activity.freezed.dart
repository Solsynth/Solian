// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnNotableDay {

 DateTime get date; String get localName; String get globalName; String get countryCode; List<int> get holidays;
/// Create a copy of SnNotableDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotableDayCopyWith<SnNotableDay> get copyWith => _$SnNotableDayCopyWithImpl<SnNotableDay>(this as SnNotableDay, _$identity);

  /// Serializes this SnNotableDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotableDay&&(identical(other.date, date) || other.date == date)&&(identical(other.localName, localName) || other.localName == localName)&&(identical(other.globalName, globalName) || other.globalName == globalName)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&const DeepCollectionEquality().equals(other.holidays, holidays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,localName,globalName,countryCode,const DeepCollectionEquality().hash(holidays));

@override
String toString() {
  return 'SnNotableDay(date: $date, localName: $localName, globalName: $globalName, countryCode: $countryCode, holidays: $holidays)';
}


}

/// @nodoc
abstract mixin class $SnNotableDayCopyWith<$Res>  {
  factory $SnNotableDayCopyWith(SnNotableDay value, $Res Function(SnNotableDay) _then) = _$SnNotableDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, String localName, String globalName, String countryCode, List<int> holidays
});




}
/// @nodoc
class _$SnNotableDayCopyWithImpl<$Res>
    implements $SnNotableDayCopyWith<$Res> {
  _$SnNotableDayCopyWithImpl(this._self, this._then);

  final SnNotableDay _self;
  final $Res Function(SnNotableDay) _then;

/// Create a copy of SnNotableDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? localName = null,Object? globalName = null,Object? countryCode = null,Object? holidays = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,localName: null == localName ? _self.localName : localName // ignore: cast_nullable_to_non_nullable
as String,globalName: null == globalName ? _self.globalName : globalName // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,holidays: null == holidays ? _self.holidays : holidays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnNotableDay].
extension SnNotableDayPatterns on SnNotableDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnNotableDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnNotableDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnNotableDay value)  $default,){
final _that = this;
switch (_that) {
case _SnNotableDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnNotableDay value)?  $default,){
final _that = this;
switch (_that) {
case _SnNotableDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  String localName,  String globalName,  String countryCode,  List<int> holidays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNotableDay() when $default != null:
return $default(_that.date,_that.localName,_that.globalName,_that.countryCode,_that.holidays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  String localName,  String globalName,  String countryCode,  List<int> holidays)  $default,) {final _that = this;
switch (_that) {
case _SnNotableDay():
return $default(_that.date,_that.localName,_that.globalName,_that.countryCode,_that.holidays);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  String localName,  String globalName,  String countryCode,  List<int> holidays)?  $default,) {final _that = this;
switch (_that) {
case _SnNotableDay() when $default != null:
return $default(_that.date,_that.localName,_that.globalName,_that.countryCode,_that.holidays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNotableDay implements SnNotableDay {
  const _SnNotableDay({required this.date, required this.localName, required this.globalName, required this.countryCode, required final  List<int> holidays}): _holidays = holidays;
  factory _SnNotableDay.fromJson(Map<String, dynamic> json) => _$SnNotableDayFromJson(json);

@override final  DateTime date;
@override final  String localName;
@override final  String globalName;
@override final  String countryCode;
 final  List<int> _holidays;
@override List<int> get holidays {
  if (_holidays is EqualUnmodifiableListView) return _holidays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holidays);
}


/// Create a copy of SnNotableDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnNotableDayCopyWith<_SnNotableDay> get copyWith => __$SnNotableDayCopyWithImpl<_SnNotableDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnNotableDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotableDay&&(identical(other.date, date) || other.date == date)&&(identical(other.localName, localName) || other.localName == localName)&&(identical(other.globalName, globalName) || other.globalName == globalName)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&const DeepCollectionEquality().equals(other._holidays, _holidays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,localName,globalName,countryCode,const DeepCollectionEquality().hash(_holidays));

@override
String toString() {
  return 'SnNotableDay(date: $date, localName: $localName, globalName: $globalName, countryCode: $countryCode, holidays: $holidays)';
}


}

/// @nodoc
abstract mixin class _$SnNotableDayCopyWith<$Res> implements $SnNotableDayCopyWith<$Res> {
  factory _$SnNotableDayCopyWith(_SnNotableDay value, $Res Function(_SnNotableDay) _then) = __$SnNotableDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, String localName, String globalName, String countryCode, List<int> holidays
});




}
/// @nodoc
class __$SnNotableDayCopyWithImpl<$Res>
    implements _$SnNotableDayCopyWith<$Res> {
  __$SnNotableDayCopyWithImpl(this._self, this._then);

  final _SnNotableDay _self;
  final $Res Function(_SnNotableDay) _then;

/// Create a copy of SnNotableDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? localName = null,Object? globalName = null,Object? countryCode = null,Object? holidays = null,}) {
  return _then(_SnNotableDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,localName: null == localName ? _self.localName : localName // ignore: cast_nullable_to_non_nullable
as String,globalName: null == globalName ? _self.globalName : globalName // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,holidays: null == holidays ? _self._holidays : holidays // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$SnTimelineEvent {

 String get id; String get type; String get resourceIdentifier; dynamic get data; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnTimelineEventCopyWith<SnTimelineEvent> get copyWith => _$SnTimelineEventCopyWithImpl<SnTimelineEvent>(this as SnTimelineEvent, _$identity);

  /// Serializes this SnTimelineEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnTimelineEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,resourceIdentifier,const DeepCollectionEquality().hash(data),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnTimelineEvent(id: $id, type: $type, resourceIdentifier: $resourceIdentifier, data: $data, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnTimelineEventCopyWith<$Res>  {
  factory $SnTimelineEventCopyWith(SnTimelineEvent value, $Res Function(SnTimelineEvent) _then) = _$SnTimelineEventCopyWithImpl;
@useResult
$Res call({
 String id, String type, String resourceIdentifier, dynamic data, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnTimelineEventCopyWithImpl<$Res>
    implements $SnTimelineEventCopyWith<$Res> {
  _$SnTimelineEventCopyWithImpl(this._self, this._then);

  final SnTimelineEvent _self;
  final $Res Function(SnTimelineEvent) _then;

/// Create a copy of SnTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? resourceIdentifier = null,Object? data = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,resourceIdentifier: null == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnTimelineEvent].
extension SnTimelineEventPatterns on SnTimelineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnTimelineEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnTimelineEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnTimelineEvent value)  $default,){
final _that = this;
switch (_that) {
case _SnTimelineEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnTimelineEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SnTimelineEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String resourceIdentifier,  dynamic data,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnTimelineEvent() when $default != null:
return $default(_that.id,_that.type,_that.resourceIdentifier,_that.data,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String resourceIdentifier,  dynamic data,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnTimelineEvent():
return $default(_that.id,_that.type,_that.resourceIdentifier,_that.data,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String resourceIdentifier,  dynamic data,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnTimelineEvent() when $default != null:
return $default(_that.id,_that.type,_that.resourceIdentifier,_that.data,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnTimelineEvent implements SnTimelineEvent {
  const _SnTimelineEvent({required this.id, required this.type, required this.resourceIdentifier, required this.data, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnTimelineEvent.fromJson(Map<String, dynamic> json) => _$SnTimelineEventFromJson(json);

@override final  String id;
@override final  String type;
@override final  String resourceIdentifier;
@override final  dynamic data;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnTimelineEventCopyWith<_SnTimelineEvent> get copyWith => __$SnTimelineEventCopyWithImpl<_SnTimelineEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnTimelineEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnTimelineEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,resourceIdentifier,const DeepCollectionEquality().hash(data),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnTimelineEvent(id: $id, type: $type, resourceIdentifier: $resourceIdentifier, data: $data, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnTimelineEventCopyWith<$Res> implements $SnTimelineEventCopyWith<$Res> {
  factory _$SnTimelineEventCopyWith(_SnTimelineEvent value, $Res Function(_SnTimelineEvent) _then) = __$SnTimelineEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String resourceIdentifier, dynamic data, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnTimelineEventCopyWithImpl<$Res>
    implements _$SnTimelineEventCopyWith<$Res> {
  __$SnTimelineEventCopyWithImpl(this._self, this._then);

  final _SnTimelineEvent _self;
  final $Res Function(_SnTimelineEvent) _then;

/// Create a copy of SnTimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? resourceIdentifier = null,Object? data = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnTimelineEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,resourceIdentifier: null == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnCheckInResult {

 String get id; int get level; List<SnFortuneTip> get tips; String get accountId; SnAccount? get account; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnCheckInResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCheckInResultCopyWith<SnCheckInResult> get copyWith => _$SnCheckInResultCopyWithImpl<SnCheckInResult>(this as SnCheckInResult, _$identity);

  /// Serializes this SnCheckInResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCheckInResult&&(identical(other.id, id) || other.id == id)&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other.tips, tips)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,level,const DeepCollectionEquality().hash(tips),accountId,account,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCheckInResult(id: $id, level: $level, tips: $tips, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnCheckInResultCopyWith<$Res>  {
  factory $SnCheckInResultCopyWith(SnCheckInResult value, $Res Function(SnCheckInResult) _then) = _$SnCheckInResultCopyWithImpl;
@useResult
$Res call({
 String id, int level, List<SnFortuneTip> tips, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnCheckInResultCopyWithImpl<$Res>
    implements $SnCheckInResultCopyWith<$Res> {
  _$SnCheckInResultCopyWithImpl(this._self, this._then);

  final SnCheckInResult _self;
  final $Res Function(SnCheckInResult) _then;

/// Create a copy of SnCheckInResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? level = null,Object? tips = null,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as List<SnFortuneTip>,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnCheckInResult
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


/// Adds pattern-matching-related methods to [SnCheckInResult].
extension SnCheckInResultPatterns on SnCheckInResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnCheckInResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnCheckInResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnCheckInResult value)  $default,){
final _that = this;
switch (_that) {
case _SnCheckInResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnCheckInResult value)?  $default,){
final _that = this;
switch (_that) {
case _SnCheckInResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int level,  List<SnFortuneTip> tips,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCheckInResult() when $default != null:
return $default(_that.id,_that.level,_that.tips,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int level,  List<SnFortuneTip> tips,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnCheckInResult():
return $default(_that.id,_that.level,_that.tips,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int level,  List<SnFortuneTip> tips,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnCheckInResult() when $default != null:
return $default(_that.id,_that.level,_that.tips,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCheckInResult implements SnCheckInResult {
  const _SnCheckInResult({required this.id, required this.level, required final  List<SnFortuneTip> tips, required this.accountId, required this.account, required this.createdAt, required this.updatedAt, required this.deletedAt}): _tips = tips;
  factory _SnCheckInResult.fromJson(Map<String, dynamic> json) => _$SnCheckInResultFromJson(json);

@override final  String id;
@override final  int level;
 final  List<SnFortuneTip> _tips;
@override List<SnFortuneTip> get tips {
  if (_tips is EqualUnmodifiableListView) return _tips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tips);
}

@override final  String accountId;
@override final  SnAccount? account;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnCheckInResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnCheckInResultCopyWith<_SnCheckInResult> get copyWith => __$SnCheckInResultCopyWithImpl<_SnCheckInResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnCheckInResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCheckInResult&&(identical(other.id, id) || other.id == id)&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other._tips, _tips)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,level,const DeepCollectionEquality().hash(_tips),accountId,account,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCheckInResult(id: $id, level: $level, tips: $tips, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnCheckInResultCopyWith<$Res> implements $SnCheckInResultCopyWith<$Res> {
  factory _$SnCheckInResultCopyWith(_SnCheckInResult value, $Res Function(_SnCheckInResult) _then) = __$SnCheckInResultCopyWithImpl;
@override @useResult
$Res call({
 String id, int level, List<SnFortuneTip> tips, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnCheckInResultCopyWithImpl<$Res>
    implements _$SnCheckInResultCopyWith<$Res> {
  __$SnCheckInResultCopyWithImpl(this._self, this._then);

  final _SnCheckInResult _self;
  final $Res Function(_SnCheckInResult) _then;

/// Create a copy of SnCheckInResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? level = null,Object? tips = null,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnCheckInResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,tips: null == tips ? _self._tips : tips // ignore: cast_nullable_to_non_nullable
as List<SnFortuneTip>,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnCheckInResult
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
mixin _$SnFortuneTip {

 bool get isPositive; String get title; String get content;
/// Create a copy of SnFortuneTip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFortuneTipCopyWith<SnFortuneTip> get copyWith => _$SnFortuneTipCopyWithImpl<SnFortuneTip>(this as SnFortuneTip, _$identity);

  /// Serializes this SnFortuneTip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFortuneTip&&(identical(other.isPositive, isPositive) || other.isPositive == isPositive)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPositive,title,content);

@override
String toString() {
  return 'SnFortuneTip(isPositive: $isPositive, title: $title, content: $content)';
}


}

/// @nodoc
abstract mixin class $SnFortuneTipCopyWith<$Res>  {
  factory $SnFortuneTipCopyWith(SnFortuneTip value, $Res Function(SnFortuneTip) _then) = _$SnFortuneTipCopyWithImpl;
@useResult
$Res call({
 bool isPositive, String title, String content
});




}
/// @nodoc
class _$SnFortuneTipCopyWithImpl<$Res>
    implements $SnFortuneTipCopyWith<$Res> {
  _$SnFortuneTipCopyWithImpl(this._self, this._then);

  final SnFortuneTip _self;
  final $Res Function(SnFortuneTip) _then;

/// Create a copy of SnFortuneTip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPositive = null,Object? title = null,Object? content = null,}) {
  return _then(_self.copyWith(
isPositive: null == isPositive ? _self.isPositive : isPositive // ignore: cast_nullable_to_non_nullable
as bool,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFortuneTip].
extension SnFortuneTipPatterns on SnFortuneTip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFortuneTip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFortuneTip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFortuneTip value)  $default,){
final _that = this;
switch (_that) {
case _SnFortuneTip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFortuneTip value)?  $default,){
final _that = this;
switch (_that) {
case _SnFortuneTip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPositive,  String title,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFortuneTip() when $default != null:
return $default(_that.isPositive,_that.title,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPositive,  String title,  String content)  $default,) {final _that = this;
switch (_that) {
case _SnFortuneTip():
return $default(_that.isPositive,_that.title,_that.content);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPositive,  String title,  String content)?  $default,) {final _that = this;
switch (_that) {
case _SnFortuneTip() when $default != null:
return $default(_that.isPositive,_that.title,_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFortuneTip implements SnFortuneTip {
  const _SnFortuneTip({required this.isPositive, required this.title, required this.content});
  factory _SnFortuneTip.fromJson(Map<String, dynamic> json) => _$SnFortuneTipFromJson(json);

@override final  bool isPositive;
@override final  String title;
@override final  String content;

/// Create a copy of SnFortuneTip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFortuneTipCopyWith<_SnFortuneTip> get copyWith => __$SnFortuneTipCopyWithImpl<_SnFortuneTip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFortuneTipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFortuneTip&&(identical(other.isPositive, isPositive) || other.isPositive == isPositive)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPositive,title,content);

@override
String toString() {
  return 'SnFortuneTip(isPositive: $isPositive, title: $title, content: $content)';
}


}

/// @nodoc
abstract mixin class _$SnFortuneTipCopyWith<$Res> implements $SnFortuneTipCopyWith<$Res> {
  factory _$SnFortuneTipCopyWith(_SnFortuneTip value, $Res Function(_SnFortuneTip) _then) = __$SnFortuneTipCopyWithImpl;
@override @useResult
$Res call({
 bool isPositive, String title, String content
});




}
/// @nodoc
class __$SnFortuneTipCopyWithImpl<$Res>
    implements _$SnFortuneTipCopyWith<$Res> {
  __$SnFortuneTipCopyWithImpl(this._self, this._then);

  final _SnFortuneTip _self;
  final $Res Function(_SnFortuneTip) _then;

/// Create a copy of SnFortuneTip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPositive = null,Object? title = null,Object? content = null,}) {
  return _then(_SnFortuneTip(
isPositive: null == isPositive ? _self.isPositive : isPositive // ignore: cast_nullable_to_non_nullable
as bool,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnEventCalendarEntry {

 DateTime get date; SnCheckInResult? get checkInResult; List<SnAccountStatus> get statuses;
/// Create a copy of SnEventCalendarEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnEventCalendarEntryCopyWith<SnEventCalendarEntry> get copyWith => _$SnEventCalendarEntryCopyWithImpl<SnEventCalendarEntry>(this as SnEventCalendarEntry, _$identity);

  /// Serializes this SnEventCalendarEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnEventCalendarEntry&&(identical(other.date, date) || other.date == date)&&(identical(other.checkInResult, checkInResult) || other.checkInResult == checkInResult)&&const DeepCollectionEquality().equals(other.statuses, statuses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,checkInResult,const DeepCollectionEquality().hash(statuses));

@override
String toString() {
  return 'SnEventCalendarEntry(date: $date, checkInResult: $checkInResult, statuses: $statuses)';
}


}

/// @nodoc
abstract mixin class $SnEventCalendarEntryCopyWith<$Res>  {
  factory $SnEventCalendarEntryCopyWith(SnEventCalendarEntry value, $Res Function(SnEventCalendarEntry) _then) = _$SnEventCalendarEntryCopyWithImpl;
@useResult
$Res call({
 DateTime date, SnCheckInResult? checkInResult, List<SnAccountStatus> statuses
});


$SnCheckInResultCopyWith<$Res>? get checkInResult;

}
/// @nodoc
class _$SnEventCalendarEntryCopyWithImpl<$Res>
    implements $SnEventCalendarEntryCopyWith<$Res> {
  _$SnEventCalendarEntryCopyWithImpl(this._self, this._then);

  final SnEventCalendarEntry _self;
  final $Res Function(SnEventCalendarEntry) _then;

/// Create a copy of SnEventCalendarEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? checkInResult = freezed,Object? statuses = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,checkInResult: freezed == checkInResult ? _self.checkInResult : checkInResult // ignore: cast_nullable_to_non_nullable
as SnCheckInResult?,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<SnAccountStatus>,
  ));
}
/// Create a copy of SnEventCalendarEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCheckInResultCopyWith<$Res>? get checkInResult {
    if (_self.checkInResult == null) {
    return null;
  }

  return $SnCheckInResultCopyWith<$Res>(_self.checkInResult!, (value) {
    return _then(_self.copyWith(checkInResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnEventCalendarEntry].
extension SnEventCalendarEntryPatterns on SnEventCalendarEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnEventCalendarEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnEventCalendarEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnEventCalendarEntry value)  $default,){
final _that = this;
switch (_that) {
case _SnEventCalendarEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnEventCalendarEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SnEventCalendarEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  SnCheckInResult? checkInResult,  List<SnAccountStatus> statuses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnEventCalendarEntry() when $default != null:
return $default(_that.date,_that.checkInResult,_that.statuses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  SnCheckInResult? checkInResult,  List<SnAccountStatus> statuses)  $default,) {final _that = this;
switch (_that) {
case _SnEventCalendarEntry():
return $default(_that.date,_that.checkInResult,_that.statuses);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  SnCheckInResult? checkInResult,  List<SnAccountStatus> statuses)?  $default,) {final _that = this;
switch (_that) {
case _SnEventCalendarEntry() when $default != null:
return $default(_that.date,_that.checkInResult,_that.statuses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnEventCalendarEntry implements SnEventCalendarEntry {
  const _SnEventCalendarEntry({required this.date, required this.checkInResult, required final  List<SnAccountStatus> statuses}): _statuses = statuses;
  factory _SnEventCalendarEntry.fromJson(Map<String, dynamic> json) => _$SnEventCalendarEntryFromJson(json);

@override final  DateTime date;
@override final  SnCheckInResult? checkInResult;
 final  List<SnAccountStatus> _statuses;
@override List<SnAccountStatus> get statuses {
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statuses);
}


/// Create a copy of SnEventCalendarEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnEventCalendarEntryCopyWith<_SnEventCalendarEntry> get copyWith => __$SnEventCalendarEntryCopyWithImpl<_SnEventCalendarEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnEventCalendarEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnEventCalendarEntry&&(identical(other.date, date) || other.date == date)&&(identical(other.checkInResult, checkInResult) || other.checkInResult == checkInResult)&&const DeepCollectionEquality().equals(other._statuses, _statuses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,checkInResult,const DeepCollectionEquality().hash(_statuses));

@override
String toString() {
  return 'SnEventCalendarEntry(date: $date, checkInResult: $checkInResult, statuses: $statuses)';
}


}

/// @nodoc
abstract mixin class _$SnEventCalendarEntryCopyWith<$Res> implements $SnEventCalendarEntryCopyWith<$Res> {
  factory _$SnEventCalendarEntryCopyWith(_SnEventCalendarEntry value, $Res Function(_SnEventCalendarEntry) _then) = __$SnEventCalendarEntryCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, SnCheckInResult? checkInResult, List<SnAccountStatus> statuses
});


@override $SnCheckInResultCopyWith<$Res>? get checkInResult;

}
/// @nodoc
class __$SnEventCalendarEntryCopyWithImpl<$Res>
    implements _$SnEventCalendarEntryCopyWith<$Res> {
  __$SnEventCalendarEntryCopyWithImpl(this._self, this._then);

  final _SnEventCalendarEntry _self;
  final $Res Function(_SnEventCalendarEntry) _then;

/// Create a copy of SnEventCalendarEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? checkInResult = freezed,Object? statuses = null,}) {
  return _then(_SnEventCalendarEntry(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,checkInResult: freezed == checkInResult ? _self.checkInResult : checkInResult // ignore: cast_nullable_to_non_nullable
as SnCheckInResult?,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<SnAccountStatus>,
  ));
}

/// Create a copy of SnEventCalendarEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCheckInResultCopyWith<$Res>? get checkInResult {
    if (_self.checkInResult == null) {
    return null;
  }

  return $SnCheckInResultCopyWith<$Res>(_self.checkInResult!, (value) {
    return _then(_self.copyWith(checkInResult: value));
  });
}
}


/// @nodoc
mixin _$SnPresenceActivity {

 String get id; int get type; String? get manualId; String? get title; String? get subtitle; String? get caption; String? get titleUrl; String? get subtitleUrl; String? get smallImage; String? get largeImage; Map<String, dynamic>? get meta; int get leaseMinutes; DateTime get leaseExpiresAt; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPresenceActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPresenceActivityCopyWith<SnPresenceActivity> get copyWith => _$SnPresenceActivityCopyWithImpl<SnPresenceActivity>(this as SnPresenceActivity, _$identity);

  /// Serializes this SnPresenceActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPresenceActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.manualId, manualId) || other.manualId == manualId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.titleUrl, titleUrl) || other.titleUrl == titleUrl)&&(identical(other.subtitleUrl, subtitleUrl) || other.subtitleUrl == subtitleUrl)&&(identical(other.smallImage, smallImage) || other.smallImage == smallImage)&&(identical(other.largeImage, largeImage) || other.largeImage == largeImage)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.leaseMinutes, leaseMinutes) || other.leaseMinutes == leaseMinutes)&&(identical(other.leaseExpiresAt, leaseExpiresAt) || other.leaseExpiresAt == leaseExpiresAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,manualId,title,subtitle,caption,titleUrl,subtitleUrl,smallImage,largeImage,const DeepCollectionEquality().hash(meta),leaseMinutes,leaseExpiresAt,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPresenceActivity(id: $id, type: $type, manualId: $manualId, title: $title, subtitle: $subtitle, caption: $caption, titleUrl: $titleUrl, subtitleUrl: $subtitleUrl, smallImage: $smallImage, largeImage: $largeImage, meta: $meta, leaseMinutes: $leaseMinutes, leaseExpiresAt: $leaseExpiresAt, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPresenceActivityCopyWith<$Res>  {
  factory $SnPresenceActivityCopyWith(SnPresenceActivity value, $Res Function(SnPresenceActivity) _then) = _$SnPresenceActivityCopyWithImpl;
@useResult
$Res call({
 String id, int type, String? manualId, String? title, String? subtitle, String? caption, String? titleUrl, String? subtitleUrl, String? smallImage, String? largeImage, Map<String, dynamic>? meta, int leaseMinutes, DateTime leaseExpiresAt, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnPresenceActivityCopyWithImpl<$Res>
    implements $SnPresenceActivityCopyWith<$Res> {
  _$SnPresenceActivityCopyWithImpl(this._self, this._then);

  final SnPresenceActivity _self;
  final $Res Function(SnPresenceActivity) _then;

/// Create a copy of SnPresenceActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? manualId = freezed,Object? title = freezed,Object? subtitle = freezed,Object? caption = freezed,Object? titleUrl = freezed,Object? subtitleUrl = freezed,Object? smallImage = freezed,Object? largeImage = freezed,Object? meta = freezed,Object? leaseMinutes = null,Object? leaseExpiresAt = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,manualId: freezed == manualId ? _self.manualId : manualId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,titleUrl: freezed == titleUrl ? _self.titleUrl : titleUrl // ignore: cast_nullable_to_non_nullable
as String?,subtitleUrl: freezed == subtitleUrl ? _self.subtitleUrl : subtitleUrl // ignore: cast_nullable_to_non_nullable
as String?,smallImage: freezed == smallImage ? _self.smallImage : smallImage // ignore: cast_nullable_to_non_nullable
as String?,largeImage: freezed == largeImage ? _self.largeImage : largeImage // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,leaseMinutes: null == leaseMinutes ? _self.leaseMinutes : leaseMinutes // ignore: cast_nullable_to_non_nullable
as int,leaseExpiresAt: null == leaseExpiresAt ? _self.leaseExpiresAt : leaseExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPresenceActivity].
extension SnPresenceActivityPatterns on SnPresenceActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPresenceActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPresenceActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPresenceActivity value)  $default,){
final _that = this;
switch (_that) {
case _SnPresenceActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPresenceActivity value)?  $default,){
final _that = this;
switch (_that) {
case _SnPresenceActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int type,  String? manualId,  String? title,  String? subtitle,  String? caption,  String? titleUrl,  String? subtitleUrl,  String? smallImage,  String? largeImage,  Map<String, dynamic>? meta,  int leaseMinutes,  DateTime leaseExpiresAt,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPresenceActivity() when $default != null:
return $default(_that.id,_that.type,_that.manualId,_that.title,_that.subtitle,_that.caption,_that.titleUrl,_that.subtitleUrl,_that.smallImage,_that.largeImage,_that.meta,_that.leaseMinutes,_that.leaseExpiresAt,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int type,  String? manualId,  String? title,  String? subtitle,  String? caption,  String? titleUrl,  String? subtitleUrl,  String? smallImage,  String? largeImage,  Map<String, dynamic>? meta,  int leaseMinutes,  DateTime leaseExpiresAt,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPresenceActivity():
return $default(_that.id,_that.type,_that.manualId,_that.title,_that.subtitle,_that.caption,_that.titleUrl,_that.subtitleUrl,_that.smallImage,_that.largeImage,_that.meta,_that.leaseMinutes,_that.leaseExpiresAt,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int type,  String? manualId,  String? title,  String? subtitle,  String? caption,  String? titleUrl,  String? subtitleUrl,  String? smallImage,  String? largeImage,  Map<String, dynamic>? meta,  int leaseMinutes,  DateTime leaseExpiresAt,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPresenceActivity() when $default != null:
return $default(_that.id,_that.type,_that.manualId,_that.title,_that.subtitle,_that.caption,_that.titleUrl,_that.subtitleUrl,_that.smallImage,_that.largeImage,_that.meta,_that.leaseMinutes,_that.leaseExpiresAt,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPresenceActivity implements SnPresenceActivity {
  const _SnPresenceActivity({required this.id, required this.type, required this.manualId, required this.title, required this.subtitle, required this.caption, required this.titleUrl, required this.subtitleUrl, required this.smallImage, required this.largeImage, required final  Map<String, dynamic>? meta, required this.leaseMinutes, required this.leaseExpiresAt, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt}): _meta = meta;
  factory _SnPresenceActivity.fromJson(Map<String, dynamic> json) => _$SnPresenceActivityFromJson(json);

@override final  String id;
@override final  int type;
@override final  String? manualId;
@override final  String? title;
@override final  String? subtitle;
@override final  String? caption;
@override final  String? titleUrl;
@override final  String? subtitleUrl;
@override final  String? smallImage;
@override final  String? largeImage;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int leaseMinutes;
@override final  DateTime leaseExpiresAt;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPresenceActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPresenceActivityCopyWith<_SnPresenceActivity> get copyWith => __$SnPresenceActivityCopyWithImpl<_SnPresenceActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPresenceActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPresenceActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.manualId, manualId) || other.manualId == manualId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.titleUrl, titleUrl) || other.titleUrl == titleUrl)&&(identical(other.subtitleUrl, subtitleUrl) || other.subtitleUrl == subtitleUrl)&&(identical(other.smallImage, smallImage) || other.smallImage == smallImage)&&(identical(other.largeImage, largeImage) || other.largeImage == largeImage)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.leaseMinutes, leaseMinutes) || other.leaseMinutes == leaseMinutes)&&(identical(other.leaseExpiresAt, leaseExpiresAt) || other.leaseExpiresAt == leaseExpiresAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,manualId,title,subtitle,caption,titleUrl,subtitleUrl,smallImage,largeImage,const DeepCollectionEquality().hash(_meta),leaseMinutes,leaseExpiresAt,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPresenceActivity(id: $id, type: $type, manualId: $manualId, title: $title, subtitle: $subtitle, caption: $caption, titleUrl: $titleUrl, subtitleUrl: $subtitleUrl, smallImage: $smallImage, largeImage: $largeImage, meta: $meta, leaseMinutes: $leaseMinutes, leaseExpiresAt: $leaseExpiresAt, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPresenceActivityCopyWith<$Res> implements $SnPresenceActivityCopyWith<$Res> {
  factory _$SnPresenceActivityCopyWith(_SnPresenceActivity value, $Res Function(_SnPresenceActivity) _then) = __$SnPresenceActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, String? manualId, String? title, String? subtitle, String? caption, String? titleUrl, String? subtitleUrl, String? smallImage, String? largeImage, Map<String, dynamic>? meta, int leaseMinutes, DateTime leaseExpiresAt, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnPresenceActivityCopyWithImpl<$Res>
    implements _$SnPresenceActivityCopyWith<$Res> {
  __$SnPresenceActivityCopyWithImpl(this._self, this._then);

  final _SnPresenceActivity _self;
  final $Res Function(_SnPresenceActivity) _then;

/// Create a copy of SnPresenceActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? manualId = freezed,Object? title = freezed,Object? subtitle = freezed,Object? caption = freezed,Object? titleUrl = freezed,Object? subtitleUrl = freezed,Object? smallImage = freezed,Object? largeImage = freezed,Object? meta = freezed,Object? leaseMinutes = null,Object? leaseExpiresAt = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPresenceActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,manualId: freezed == manualId ? _self.manualId : manualId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,titleUrl: freezed == titleUrl ? _self.titleUrl : titleUrl // ignore: cast_nullable_to_non_nullable
as String?,subtitleUrl: freezed == subtitleUrl ? _self.subtitleUrl : subtitleUrl // ignore: cast_nullable_to_non_nullable
as String?,smallImage: freezed == smallImage ? _self.smallImage : smallImage // ignore: cast_nullable_to_non_nullable
as String?,largeImage: freezed == largeImage ? _self.largeImage : largeImage // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,leaseMinutes: null == leaseMinutes ? _self.leaseMinutes : leaseMinutes // ignore: cast_nullable_to_non_nullable
as int,leaseExpiresAt: null == leaseExpiresAt ? _self.leaseExpiresAt : leaseExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
