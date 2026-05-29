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

 DateTime get date; String get localName; String get globalName; String? get countryCode; String? get localizableKey; List<int> get holidays;
/// Create a copy of SnNotableDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotableDayCopyWith<SnNotableDay> get copyWith => _$SnNotableDayCopyWithImpl<SnNotableDay>(this as SnNotableDay, _$identity);

  /// Serializes this SnNotableDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotableDay&&(identical(other.date, date) || other.date == date)&&(identical(other.localName, localName) || other.localName == localName)&&(identical(other.globalName, globalName) || other.globalName == globalName)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.localizableKey, localizableKey) || other.localizableKey == localizableKey)&&const DeepCollectionEquality().equals(other.holidays, holidays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,localName,globalName,countryCode,localizableKey,const DeepCollectionEquality().hash(holidays));

@override
String toString() {
  return 'SnNotableDay(date: $date, localName: $localName, globalName: $globalName, countryCode: $countryCode, localizableKey: $localizableKey, holidays: $holidays)';
}


}

/// @nodoc
abstract mixin class $SnNotableDayCopyWith<$Res>  {
  factory $SnNotableDayCopyWith(SnNotableDay value, $Res Function(SnNotableDay) _then) = _$SnNotableDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, String localName, String globalName, String? countryCode, String? localizableKey, List<int> holidays
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
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? localName = null,Object? globalName = null,Object? countryCode = freezed,Object? localizableKey = freezed,Object? holidays = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,localName: null == localName ? _self.localName : localName // ignore: cast_nullable_to_non_nullable
as String,globalName: null == globalName ? _self.globalName : globalName // ignore: cast_nullable_to_non_nullable
as String,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,localizableKey: freezed == localizableKey ? _self.localizableKey : localizableKey // ignore: cast_nullable_to_non_nullable
as String?,holidays: null == holidays ? _self.holidays : holidays // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  String localName,  String globalName,  String? countryCode,  String? localizableKey,  List<int> holidays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNotableDay() when $default != null:
return $default(_that.date,_that.localName,_that.globalName,_that.countryCode,_that.localizableKey,_that.holidays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  String localName,  String globalName,  String? countryCode,  String? localizableKey,  List<int> holidays)  $default,) {final _that = this;
switch (_that) {
case _SnNotableDay():
return $default(_that.date,_that.localName,_that.globalName,_that.countryCode,_that.localizableKey,_that.holidays);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  String localName,  String globalName,  String? countryCode,  String? localizableKey,  List<int> holidays)?  $default,) {final _that = this;
switch (_that) {
case _SnNotableDay() when $default != null:
return $default(_that.date,_that.localName,_that.globalName,_that.countryCode,_that.localizableKey,_that.holidays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNotableDay implements SnNotableDay {
  const _SnNotableDay({required this.date, required this.localName, required this.globalName, required this.countryCode, required this.localizableKey, required final  List<int> holidays}): _holidays = holidays;
  factory _SnNotableDay.fromJson(Map<String, dynamic> json) => _$SnNotableDayFromJson(json);

@override final  DateTime date;
@override final  String localName;
@override final  String globalName;
@override final  String? countryCode;
@override final  String? localizableKey;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotableDay&&(identical(other.date, date) || other.date == date)&&(identical(other.localName, localName) || other.localName == localName)&&(identical(other.globalName, globalName) || other.globalName == globalName)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.localizableKey, localizableKey) || other.localizableKey == localizableKey)&&const DeepCollectionEquality().equals(other._holidays, _holidays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,localName,globalName,countryCode,localizableKey,const DeepCollectionEquality().hash(_holidays));

@override
String toString() {
  return 'SnNotableDay(date: $date, localName: $localName, globalName: $globalName, countryCode: $countryCode, localizableKey: $localizableKey, holidays: $holidays)';
}


}

/// @nodoc
abstract mixin class _$SnNotableDayCopyWith<$Res> implements $SnNotableDayCopyWith<$Res> {
  factory _$SnNotableDayCopyWith(_SnNotableDay value, $Res Function(_SnNotableDay) _then) = __$SnNotableDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, String localName, String globalName, String? countryCode, String? localizableKey, List<int> holidays
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
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? localName = null,Object? globalName = null,Object? countryCode = freezed,Object? localizableKey = freezed,Object? holidays = null,}) {
  return _then(_SnNotableDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,localName: null == localName ? _self.localName : localName // ignore: cast_nullable_to_non_nullable
as String,globalName: null == globalName ? _self.globalName : globalName // ignore: cast_nullable_to_non_nullable
as String,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,localizableKey: freezed == localizableKey ? _self.localizableKey : localizableKey // ignore: cast_nullable_to_non_nullable
as String?,holidays: null == holidays ? _self._holidays : holidays // ignore: cast_nullable_to_non_nullable
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

 String get id; int get level; List<SnFortuneTip> get tips; SnCheckInFortuneReport? get fortuneReport; String get accountId; SnAccount? get account; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnCheckInResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCheckInResultCopyWith<SnCheckInResult> get copyWith => _$SnCheckInResultCopyWithImpl<SnCheckInResult>(this as SnCheckInResult, _$identity);

  /// Serializes this SnCheckInResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCheckInResult&&(identical(other.id, id) || other.id == id)&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other.tips, tips)&&(identical(other.fortuneReport, fortuneReport) || other.fortuneReport == fortuneReport)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,level,const DeepCollectionEquality().hash(tips),fortuneReport,accountId,account,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCheckInResult(id: $id, level: $level, tips: $tips, fortuneReport: $fortuneReport, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnCheckInResultCopyWith<$Res>  {
  factory $SnCheckInResultCopyWith(SnCheckInResult value, $Res Function(SnCheckInResult) _then) = _$SnCheckInResultCopyWithImpl;
@useResult
$Res call({
 String id, int level, List<SnFortuneTip> tips, SnCheckInFortuneReport? fortuneReport, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnCheckInFortuneReportCopyWith<$Res>? get fortuneReport;$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnCheckInResultCopyWithImpl<$Res>
    implements $SnCheckInResultCopyWith<$Res> {
  _$SnCheckInResultCopyWithImpl(this._self, this._then);

  final SnCheckInResult _self;
  final $Res Function(SnCheckInResult) _then;

/// Create a copy of SnCheckInResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? level = null,Object? tips = null,Object? fortuneReport = freezed,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as List<SnFortuneTip>,fortuneReport: freezed == fortuneReport ? _self.fortuneReport : fortuneReport // ignore: cast_nullable_to_non_nullable
as SnCheckInFortuneReport?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
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
$SnCheckInFortuneReportCopyWith<$Res>? get fortuneReport {
    if (_self.fortuneReport == null) {
    return null;
  }

  return $SnCheckInFortuneReportCopyWith<$Res>(_self.fortuneReport!, (value) {
    return _then(_self.copyWith(fortuneReport: value));
  });
}/// Create a copy of SnCheckInResult
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int level,  List<SnFortuneTip> tips,  SnCheckInFortuneReport? fortuneReport,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCheckInResult() when $default != null:
return $default(_that.id,_that.level,_that.tips,_that.fortuneReport,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int level,  List<SnFortuneTip> tips,  SnCheckInFortuneReport? fortuneReport,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnCheckInResult():
return $default(_that.id,_that.level,_that.tips,_that.fortuneReport,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int level,  List<SnFortuneTip> tips,  SnCheckInFortuneReport? fortuneReport,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnCheckInResult() when $default != null:
return $default(_that.id,_that.level,_that.tips,_that.fortuneReport,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCheckInResult implements SnCheckInResult {
  const _SnCheckInResult({required this.id, required this.level, required final  List<SnFortuneTip> tips, this.fortuneReport, required this.accountId, required this.account, required this.createdAt, required this.updatedAt, required this.deletedAt}): _tips = tips;
  factory _SnCheckInResult.fromJson(Map<String, dynamic> json) => _$SnCheckInResultFromJson(json);

@override final  String id;
@override final  int level;
 final  List<SnFortuneTip> _tips;
@override List<SnFortuneTip> get tips {
  if (_tips is EqualUnmodifiableListView) return _tips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tips);
}

@override final  SnCheckInFortuneReport? fortuneReport;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCheckInResult&&(identical(other.id, id) || other.id == id)&&(identical(other.level, level) || other.level == level)&&const DeepCollectionEquality().equals(other._tips, _tips)&&(identical(other.fortuneReport, fortuneReport) || other.fortuneReport == fortuneReport)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,level,const DeepCollectionEquality().hash(_tips),fortuneReport,accountId,account,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCheckInResult(id: $id, level: $level, tips: $tips, fortuneReport: $fortuneReport, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnCheckInResultCopyWith<$Res> implements $SnCheckInResultCopyWith<$Res> {
  factory _$SnCheckInResultCopyWith(_SnCheckInResult value, $Res Function(_SnCheckInResult) _then) = __$SnCheckInResultCopyWithImpl;
@override @useResult
$Res call({
 String id, int level, List<SnFortuneTip> tips, SnCheckInFortuneReport? fortuneReport, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnCheckInFortuneReportCopyWith<$Res>? get fortuneReport;@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnCheckInResultCopyWithImpl<$Res>
    implements _$SnCheckInResultCopyWith<$Res> {
  __$SnCheckInResultCopyWithImpl(this._self, this._then);

  final _SnCheckInResult _self;
  final $Res Function(_SnCheckInResult) _then;

/// Create a copy of SnCheckInResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? level = null,Object? tips = null,Object? fortuneReport = freezed,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnCheckInResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,tips: null == tips ? _self._tips : tips // ignore: cast_nullable_to_non_nullable
as List<SnFortuneTip>,fortuneReport: freezed == fortuneReport ? _self.fortuneReport : fortuneReport // ignore: cast_nullable_to_non_nullable
as SnCheckInFortuneReport?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
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
$SnCheckInFortuneReportCopyWith<$Res>? get fortuneReport {
    if (_self.fortuneReport == null) {
    return null;
  }

  return $SnCheckInFortuneReportCopyWith<$Res>(_self.fortuneReport!, (value) {
    return _then(_self.copyWith(fortuneReport: value));
  });
}/// Create a copy of SnCheckInResult
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
mixin _$SnCheckInFortuneReport {

 int get version; String get poem; String get summary; String? get summaryDetail; String get wish; String get love; String get study; String get career; String get health; String get lostItem; String get luckyColor; String get luckyDirection; String get luckyTime; String get luckyItem; String get luckyAction; String get avoidAction; String get ritual;
/// Create a copy of SnCheckInFortuneReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCheckInFortuneReportCopyWith<SnCheckInFortuneReport> get copyWith => _$SnCheckInFortuneReportCopyWithImpl<SnCheckInFortuneReport>(this as SnCheckInFortuneReport, _$identity);

  /// Serializes this SnCheckInFortuneReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCheckInFortuneReport&&(identical(other.version, version) || other.version == version)&&(identical(other.poem, poem) || other.poem == poem)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.summaryDetail, summaryDetail) || other.summaryDetail == summaryDetail)&&(identical(other.wish, wish) || other.wish == wish)&&(identical(other.love, love) || other.love == love)&&(identical(other.study, study) || other.study == study)&&(identical(other.career, career) || other.career == career)&&(identical(other.health, health) || other.health == health)&&(identical(other.lostItem, lostItem) || other.lostItem == lostItem)&&(identical(other.luckyColor, luckyColor) || other.luckyColor == luckyColor)&&(identical(other.luckyDirection, luckyDirection) || other.luckyDirection == luckyDirection)&&(identical(other.luckyTime, luckyTime) || other.luckyTime == luckyTime)&&(identical(other.luckyItem, luckyItem) || other.luckyItem == luckyItem)&&(identical(other.luckyAction, luckyAction) || other.luckyAction == luckyAction)&&(identical(other.avoidAction, avoidAction) || other.avoidAction == avoidAction)&&(identical(other.ritual, ritual) || other.ritual == ritual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,poem,summary,summaryDetail,wish,love,study,career,health,lostItem,luckyColor,luckyDirection,luckyTime,luckyItem,luckyAction,avoidAction,ritual);

@override
String toString() {
  return 'SnCheckInFortuneReport(version: $version, poem: $poem, summary: $summary, summaryDetail: $summaryDetail, wish: $wish, love: $love, study: $study, career: $career, health: $health, lostItem: $lostItem, luckyColor: $luckyColor, luckyDirection: $luckyDirection, luckyTime: $luckyTime, luckyItem: $luckyItem, luckyAction: $luckyAction, avoidAction: $avoidAction, ritual: $ritual)';
}


}

/// @nodoc
abstract mixin class $SnCheckInFortuneReportCopyWith<$Res>  {
  factory $SnCheckInFortuneReportCopyWith(SnCheckInFortuneReport value, $Res Function(SnCheckInFortuneReport) _then) = _$SnCheckInFortuneReportCopyWithImpl;
@useResult
$Res call({
 int version, String poem, String summary, String? summaryDetail, String wish, String love, String study, String career, String health, String lostItem, String luckyColor, String luckyDirection, String luckyTime, String luckyItem, String luckyAction, String avoidAction, String ritual
});




}
/// @nodoc
class _$SnCheckInFortuneReportCopyWithImpl<$Res>
    implements $SnCheckInFortuneReportCopyWith<$Res> {
  _$SnCheckInFortuneReportCopyWithImpl(this._self, this._then);

  final SnCheckInFortuneReport _self;
  final $Res Function(SnCheckInFortuneReport) _then;

/// Create a copy of SnCheckInFortuneReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? poem = null,Object? summary = null,Object? summaryDetail = freezed,Object? wish = null,Object? love = null,Object? study = null,Object? career = null,Object? health = null,Object? lostItem = null,Object? luckyColor = null,Object? luckyDirection = null,Object? luckyTime = null,Object? luckyItem = null,Object? luckyAction = null,Object? avoidAction = null,Object? ritual = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,poem: null == poem ? _self.poem : poem // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,summaryDetail: freezed == summaryDetail ? _self.summaryDetail : summaryDetail // ignore: cast_nullable_to_non_nullable
as String?,wish: null == wish ? _self.wish : wish // ignore: cast_nullable_to_non_nullable
as String,love: null == love ? _self.love : love // ignore: cast_nullable_to_non_nullable
as String,study: null == study ? _self.study : study // ignore: cast_nullable_to_non_nullable
as String,career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as String,lostItem: null == lostItem ? _self.lostItem : lostItem // ignore: cast_nullable_to_non_nullable
as String,luckyColor: null == luckyColor ? _self.luckyColor : luckyColor // ignore: cast_nullable_to_non_nullable
as String,luckyDirection: null == luckyDirection ? _self.luckyDirection : luckyDirection // ignore: cast_nullable_to_non_nullable
as String,luckyTime: null == luckyTime ? _self.luckyTime : luckyTime // ignore: cast_nullable_to_non_nullable
as String,luckyItem: null == luckyItem ? _self.luckyItem : luckyItem // ignore: cast_nullable_to_non_nullable
as String,luckyAction: null == luckyAction ? _self.luckyAction : luckyAction // ignore: cast_nullable_to_non_nullable
as String,avoidAction: null == avoidAction ? _self.avoidAction : avoidAction // ignore: cast_nullable_to_non_nullable
as String,ritual: null == ritual ? _self.ritual : ritual // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnCheckInFortuneReport].
extension SnCheckInFortuneReportPatterns on SnCheckInFortuneReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnCheckInFortuneReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnCheckInFortuneReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnCheckInFortuneReport value)  $default,){
final _that = this;
switch (_that) {
case _SnCheckInFortuneReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnCheckInFortuneReport value)?  $default,){
final _that = this;
switch (_that) {
case _SnCheckInFortuneReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  String poem,  String summary,  String? summaryDetail,  String wish,  String love,  String study,  String career,  String health,  String lostItem,  String luckyColor,  String luckyDirection,  String luckyTime,  String luckyItem,  String luckyAction,  String avoidAction,  String ritual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCheckInFortuneReport() when $default != null:
return $default(_that.version,_that.poem,_that.summary,_that.summaryDetail,_that.wish,_that.love,_that.study,_that.career,_that.health,_that.lostItem,_that.luckyColor,_that.luckyDirection,_that.luckyTime,_that.luckyItem,_that.luckyAction,_that.avoidAction,_that.ritual);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  String poem,  String summary,  String? summaryDetail,  String wish,  String love,  String study,  String career,  String health,  String lostItem,  String luckyColor,  String luckyDirection,  String luckyTime,  String luckyItem,  String luckyAction,  String avoidAction,  String ritual)  $default,) {final _that = this;
switch (_that) {
case _SnCheckInFortuneReport():
return $default(_that.version,_that.poem,_that.summary,_that.summaryDetail,_that.wish,_that.love,_that.study,_that.career,_that.health,_that.lostItem,_that.luckyColor,_that.luckyDirection,_that.luckyTime,_that.luckyItem,_that.luckyAction,_that.avoidAction,_that.ritual);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  String poem,  String summary,  String? summaryDetail,  String wish,  String love,  String study,  String career,  String health,  String lostItem,  String luckyColor,  String luckyDirection,  String luckyTime,  String luckyItem,  String luckyAction,  String avoidAction,  String ritual)?  $default,) {final _that = this;
switch (_that) {
case _SnCheckInFortuneReport() when $default != null:
return $default(_that.version,_that.poem,_that.summary,_that.summaryDetail,_that.wish,_that.love,_that.study,_that.career,_that.health,_that.lostItem,_that.luckyColor,_that.luckyDirection,_that.luckyTime,_that.luckyItem,_that.luckyAction,_that.avoidAction,_that.ritual);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCheckInFortuneReport implements SnCheckInFortuneReport {
  const _SnCheckInFortuneReport({required this.version, required this.poem, required this.summary, required this.summaryDetail, required this.wish, required this.love, required this.study, required this.career, required this.health, required this.lostItem, required this.luckyColor, required this.luckyDirection, required this.luckyTime, required this.luckyItem, required this.luckyAction, required this.avoidAction, required this.ritual});
  factory _SnCheckInFortuneReport.fromJson(Map<String, dynamic> json) => _$SnCheckInFortuneReportFromJson(json);

@override final  int version;
@override final  String poem;
@override final  String summary;
@override final  String? summaryDetail;
@override final  String wish;
@override final  String love;
@override final  String study;
@override final  String career;
@override final  String health;
@override final  String lostItem;
@override final  String luckyColor;
@override final  String luckyDirection;
@override final  String luckyTime;
@override final  String luckyItem;
@override final  String luckyAction;
@override final  String avoidAction;
@override final  String ritual;

/// Create a copy of SnCheckInFortuneReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnCheckInFortuneReportCopyWith<_SnCheckInFortuneReport> get copyWith => __$SnCheckInFortuneReportCopyWithImpl<_SnCheckInFortuneReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnCheckInFortuneReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCheckInFortuneReport&&(identical(other.version, version) || other.version == version)&&(identical(other.poem, poem) || other.poem == poem)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.summaryDetail, summaryDetail) || other.summaryDetail == summaryDetail)&&(identical(other.wish, wish) || other.wish == wish)&&(identical(other.love, love) || other.love == love)&&(identical(other.study, study) || other.study == study)&&(identical(other.career, career) || other.career == career)&&(identical(other.health, health) || other.health == health)&&(identical(other.lostItem, lostItem) || other.lostItem == lostItem)&&(identical(other.luckyColor, luckyColor) || other.luckyColor == luckyColor)&&(identical(other.luckyDirection, luckyDirection) || other.luckyDirection == luckyDirection)&&(identical(other.luckyTime, luckyTime) || other.luckyTime == luckyTime)&&(identical(other.luckyItem, luckyItem) || other.luckyItem == luckyItem)&&(identical(other.luckyAction, luckyAction) || other.luckyAction == luckyAction)&&(identical(other.avoidAction, avoidAction) || other.avoidAction == avoidAction)&&(identical(other.ritual, ritual) || other.ritual == ritual));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,poem,summary,summaryDetail,wish,love,study,career,health,lostItem,luckyColor,luckyDirection,luckyTime,luckyItem,luckyAction,avoidAction,ritual);

@override
String toString() {
  return 'SnCheckInFortuneReport(version: $version, poem: $poem, summary: $summary, summaryDetail: $summaryDetail, wish: $wish, love: $love, study: $study, career: $career, health: $health, lostItem: $lostItem, luckyColor: $luckyColor, luckyDirection: $luckyDirection, luckyTime: $luckyTime, luckyItem: $luckyItem, luckyAction: $luckyAction, avoidAction: $avoidAction, ritual: $ritual)';
}


}

/// @nodoc
abstract mixin class _$SnCheckInFortuneReportCopyWith<$Res> implements $SnCheckInFortuneReportCopyWith<$Res> {
  factory _$SnCheckInFortuneReportCopyWith(_SnCheckInFortuneReport value, $Res Function(_SnCheckInFortuneReport) _then) = __$SnCheckInFortuneReportCopyWithImpl;
@override @useResult
$Res call({
 int version, String poem, String summary, String? summaryDetail, String wish, String love, String study, String career, String health, String lostItem, String luckyColor, String luckyDirection, String luckyTime, String luckyItem, String luckyAction, String avoidAction, String ritual
});




}
/// @nodoc
class __$SnCheckInFortuneReportCopyWithImpl<$Res>
    implements _$SnCheckInFortuneReportCopyWith<$Res> {
  __$SnCheckInFortuneReportCopyWithImpl(this._self, this._then);

  final _SnCheckInFortuneReport _self;
  final $Res Function(_SnCheckInFortuneReport) _then;

/// Create a copy of SnCheckInFortuneReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? poem = null,Object? summary = null,Object? summaryDetail = freezed,Object? wish = null,Object? love = null,Object? study = null,Object? career = null,Object? health = null,Object? lostItem = null,Object? luckyColor = null,Object? luckyDirection = null,Object? luckyTime = null,Object? luckyItem = null,Object? luckyAction = null,Object? avoidAction = null,Object? ritual = null,}) {
  return _then(_SnCheckInFortuneReport(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,poem: null == poem ? _self.poem : poem // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,summaryDetail: freezed == summaryDetail ? _self.summaryDetail : summaryDetail // ignore: cast_nullable_to_non_nullable
as String?,wish: null == wish ? _self.wish : wish // ignore: cast_nullable_to_non_nullable
as String,love: null == love ? _self.love : love // ignore: cast_nullable_to_non_nullable
as String,study: null == study ? _self.study : study // ignore: cast_nullable_to_non_nullable
as String,career: null == career ? _self.career : career // ignore: cast_nullable_to_non_nullable
as String,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as String,lostItem: null == lostItem ? _self.lostItem : lostItem // ignore: cast_nullable_to_non_nullable
as String,luckyColor: null == luckyColor ? _self.luckyColor : luckyColor // ignore: cast_nullable_to_non_nullable
as String,luckyDirection: null == luckyDirection ? _self.luckyDirection : luckyDirection // ignore: cast_nullable_to_non_nullable
as String,luckyTime: null == luckyTime ? _self.luckyTime : luckyTime // ignore: cast_nullable_to_non_nullable
as String,luckyItem: null == luckyItem ? _self.luckyItem : luckyItem // ignore: cast_nullable_to_non_nullable
as String,luckyAction: null == luckyAction ? _self.luckyAction : luckyAction // ignore: cast_nullable_to_non_nullable
as String,avoidAction: null == avoidAction ? _self.avoidAction : avoidAction // ignore: cast_nullable_to_non_nullable
as String,ritual: null == ritual ? _self.ritual : ritual // ignore: cast_nullable_to_non_nullable
as String,
  ));
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
mixin _$SnRecurrencePattern {

 int get frequency; int get interval; DateTime? get endDate; int? get occurrences; List<String>? get daysOfWeek; int? get dayOfMonth; int? get monthOfYear;
/// Create a copy of SnRecurrencePattern
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRecurrencePatternCopyWith<SnRecurrencePattern> get copyWith => _$SnRecurrencePatternCopyWithImpl<SnRecurrencePattern>(this as SnRecurrencePattern, _$identity);

  /// Serializes this SnRecurrencePattern to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRecurrencePattern&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.occurrences, occurrences) || other.occurrences == occurrences)&&const DeepCollectionEquality().equals(other.daysOfWeek, daysOfWeek)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.monthOfYear, monthOfYear) || other.monthOfYear == monthOfYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,frequency,interval,endDate,occurrences,const DeepCollectionEquality().hash(daysOfWeek),dayOfMonth,monthOfYear);

@override
String toString() {
  return 'SnRecurrencePattern(frequency: $frequency, interval: $interval, endDate: $endDate, occurrences: $occurrences, daysOfWeek: $daysOfWeek, dayOfMonth: $dayOfMonth, monthOfYear: $monthOfYear)';
}


}

/// @nodoc
abstract mixin class $SnRecurrencePatternCopyWith<$Res>  {
  factory $SnRecurrencePatternCopyWith(SnRecurrencePattern value, $Res Function(SnRecurrencePattern) _then) = _$SnRecurrencePatternCopyWithImpl;
@useResult
$Res call({
 int frequency, int interval, DateTime? endDate, int? occurrences, List<String>? daysOfWeek, int? dayOfMonth, int? monthOfYear
});




}
/// @nodoc
class _$SnRecurrencePatternCopyWithImpl<$Res>
    implements $SnRecurrencePatternCopyWith<$Res> {
  _$SnRecurrencePatternCopyWithImpl(this._self, this._then);

  final SnRecurrencePattern _self;
  final $Res Function(SnRecurrencePattern) _then;

/// Create a copy of SnRecurrencePattern
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? frequency = null,Object? interval = null,Object? endDate = freezed,Object? occurrences = freezed,Object? daysOfWeek = freezed,Object? dayOfMonth = freezed,Object? monthOfYear = freezed,}) {
  return _then(_self.copyWith(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,occurrences: freezed == occurrences ? _self.occurrences : occurrences // ignore: cast_nullable_to_non_nullable
as int?,daysOfWeek: freezed == daysOfWeek ? _self.daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<String>?,dayOfMonth: freezed == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int?,monthOfYear: freezed == monthOfYear ? _self.monthOfYear : monthOfYear // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnRecurrencePattern].
extension SnRecurrencePatternPatterns on SnRecurrencePattern {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnRecurrencePattern value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnRecurrencePattern() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnRecurrencePattern value)  $default,){
final _that = this;
switch (_that) {
case _SnRecurrencePattern():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnRecurrencePattern value)?  $default,){
final _that = this;
switch (_that) {
case _SnRecurrencePattern() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int frequency,  int interval,  DateTime? endDate,  int? occurrences,  List<String>? daysOfWeek,  int? dayOfMonth,  int? monthOfYear)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnRecurrencePattern() when $default != null:
return $default(_that.frequency,_that.interval,_that.endDate,_that.occurrences,_that.daysOfWeek,_that.dayOfMonth,_that.monthOfYear);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int frequency,  int interval,  DateTime? endDate,  int? occurrences,  List<String>? daysOfWeek,  int? dayOfMonth,  int? monthOfYear)  $default,) {final _that = this;
switch (_that) {
case _SnRecurrencePattern():
return $default(_that.frequency,_that.interval,_that.endDate,_that.occurrences,_that.daysOfWeek,_that.dayOfMonth,_that.monthOfYear);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int frequency,  int interval,  DateTime? endDate,  int? occurrences,  List<String>? daysOfWeek,  int? dayOfMonth,  int? monthOfYear)?  $default,) {final _that = this;
switch (_that) {
case _SnRecurrencePattern() when $default != null:
return $default(_that.frequency,_that.interval,_that.endDate,_that.occurrences,_that.daysOfWeek,_that.dayOfMonth,_that.monthOfYear);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnRecurrencePattern implements SnRecurrencePattern {
  const _SnRecurrencePattern({required this.frequency, this.interval = 1, this.endDate, this.occurrences, final  List<String>? daysOfWeek, this.dayOfMonth, this.monthOfYear}): _daysOfWeek = daysOfWeek;
  factory _SnRecurrencePattern.fromJson(Map<String, dynamic> json) => _$SnRecurrencePatternFromJson(json);

@override final  int frequency;
@override@JsonKey() final  int interval;
@override final  DateTime? endDate;
@override final  int? occurrences;
 final  List<String>? _daysOfWeek;
@override List<String>? get daysOfWeek {
  final value = _daysOfWeek;
  if (value == null) return null;
  if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? dayOfMonth;
@override final  int? monthOfYear;

/// Create a copy of SnRecurrencePattern
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnRecurrencePatternCopyWith<_SnRecurrencePattern> get copyWith => __$SnRecurrencePatternCopyWithImpl<_SnRecurrencePattern>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnRecurrencePatternToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRecurrencePattern&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.occurrences, occurrences) || other.occurrences == occurrences)&&const DeepCollectionEquality().equals(other._daysOfWeek, _daysOfWeek)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.monthOfYear, monthOfYear) || other.monthOfYear == monthOfYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,frequency,interval,endDate,occurrences,const DeepCollectionEquality().hash(_daysOfWeek),dayOfMonth,monthOfYear);

@override
String toString() {
  return 'SnRecurrencePattern(frequency: $frequency, interval: $interval, endDate: $endDate, occurrences: $occurrences, daysOfWeek: $daysOfWeek, dayOfMonth: $dayOfMonth, monthOfYear: $monthOfYear)';
}


}

/// @nodoc
abstract mixin class _$SnRecurrencePatternCopyWith<$Res> implements $SnRecurrencePatternCopyWith<$Res> {
  factory _$SnRecurrencePatternCopyWith(_SnRecurrencePattern value, $Res Function(_SnRecurrencePattern) _then) = __$SnRecurrencePatternCopyWithImpl;
@override @useResult
$Res call({
 int frequency, int interval, DateTime? endDate, int? occurrences, List<String>? daysOfWeek, int? dayOfMonth, int? monthOfYear
});




}
/// @nodoc
class __$SnRecurrencePatternCopyWithImpl<$Res>
    implements _$SnRecurrencePatternCopyWith<$Res> {
  __$SnRecurrencePatternCopyWithImpl(this._self, this._then);

  final _SnRecurrencePattern _self;
  final $Res Function(_SnRecurrencePattern) _then;

/// Create a copy of SnRecurrencePattern
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? frequency = null,Object? interval = null,Object? endDate = freezed,Object? occurrences = freezed,Object? daysOfWeek = freezed,Object? dayOfMonth = freezed,Object? monthOfYear = freezed,}) {
  return _then(_SnRecurrencePattern(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,occurrences: freezed == occurrences ? _self.occurrences : occurrences // ignore: cast_nullable_to_non_nullable
as int?,daysOfWeek: freezed == daysOfWeek ? _self._daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<String>?,dayOfMonth: freezed == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int?,monthOfYear: freezed == monthOfYear ? _self.monthOfYear : monthOfYear // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SnUserCalendarEvent {

 String get id; String get title; String? get description; String? get location; DateTime get startTime; DateTime get endTime; bool get isAllDay; int get visibility; SnRecurrencePattern? get recurrence; Map<String, dynamic>? get meta; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnUserCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnUserCalendarEventCopyWith<SnUserCalendarEvent> get copyWith => _$SnUserCalendarEventCopyWithImpl<SnUserCalendarEvent>(this as SnUserCalendarEvent, _$identity);

  /// Serializes this SnUserCalendarEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnUserCalendarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,location,startTime,endTime,isAllDay,visibility,recurrence,const DeepCollectionEquality().hash(meta),accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnUserCalendarEvent(id: $id, title: $title, description: $description, location: $location, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, visibility: $visibility, recurrence: $recurrence, meta: $meta, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnUserCalendarEventCopyWith<$Res>  {
  factory $SnUserCalendarEventCopyWith(SnUserCalendarEvent value, $Res Function(SnUserCalendarEvent) _then) = _$SnUserCalendarEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String? location, DateTime startTime, DateTime endTime, bool isAllDay, int visibility, SnRecurrencePattern? recurrence, Map<String, dynamic>? meta, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnRecurrencePatternCopyWith<$Res>? get recurrence;

}
/// @nodoc
class _$SnUserCalendarEventCopyWithImpl<$Res>
    implements $SnUserCalendarEventCopyWith<$Res> {
  _$SnUserCalendarEventCopyWithImpl(this._self, this._then);

  final SnUserCalendarEvent _self;
  final $Res Function(SnUserCalendarEvent) _then;

/// Create a copy of SnUserCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? location = freezed,Object? startTime = null,Object? endTime = null,Object? isAllDay = null,Object? visibility = null,Object? recurrence = freezed,Object? meta = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as SnRecurrencePattern?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnUserCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRecurrencePatternCopyWith<$Res>? get recurrence {
    if (_self.recurrence == null) {
    return null;
  }

  return $SnRecurrencePatternCopyWith<$Res>(_self.recurrence!, (value) {
    return _then(_self.copyWith(recurrence: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnUserCalendarEvent].
extension SnUserCalendarEventPatterns on SnUserCalendarEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnUserCalendarEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnUserCalendarEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnUserCalendarEvent value)  $default,){
final _that = this;
switch (_that) {
case _SnUserCalendarEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnUserCalendarEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SnUserCalendarEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  int visibility,  SnRecurrencePattern? recurrence,  Map<String, dynamic>? meta,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnUserCalendarEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.visibility,_that.recurrence,_that.meta,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  int visibility,  SnRecurrencePattern? recurrence,  Map<String, dynamic>? meta,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnUserCalendarEvent():
return $default(_that.id,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.visibility,_that.recurrence,_that.meta,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  int visibility,  SnRecurrencePattern? recurrence,  Map<String, dynamic>? meta,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnUserCalendarEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.visibility,_that.recurrence,_that.meta,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnUserCalendarEvent implements SnUserCalendarEvent {
  const _SnUserCalendarEvent({required this.id, required this.title, this.description, this.location, required this.startTime, required this.endTime, this.isAllDay = false, this.visibility = SnEventVisibility.private, this.recurrence, final  Map<String, dynamic>? meta, required this.accountId, required this.createdAt, required this.updatedAt, this.deletedAt}): _meta = meta;
  factory _SnUserCalendarEvent.fromJson(Map<String, dynamic> json) => _$SnUserCalendarEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String? location;
@override final  DateTime startTime;
@override final  DateTime endTime;
@override@JsonKey() final  bool isAllDay;
@override@JsonKey() final  int visibility;
@override final  SnRecurrencePattern? recurrence;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnUserCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnUserCalendarEventCopyWith<_SnUserCalendarEvent> get copyWith => __$SnUserCalendarEventCopyWithImpl<_SnUserCalendarEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnUserCalendarEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnUserCalendarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,location,startTime,endTime,isAllDay,visibility,recurrence,const DeepCollectionEquality().hash(_meta),accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnUserCalendarEvent(id: $id, title: $title, description: $description, location: $location, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, visibility: $visibility, recurrence: $recurrence, meta: $meta, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnUserCalendarEventCopyWith<$Res> implements $SnUserCalendarEventCopyWith<$Res> {
  factory _$SnUserCalendarEventCopyWith(_SnUserCalendarEvent value, $Res Function(_SnUserCalendarEvent) _then) = __$SnUserCalendarEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String? location, DateTime startTime, DateTime endTime, bool isAllDay, int visibility, SnRecurrencePattern? recurrence, Map<String, dynamic>? meta, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnRecurrencePatternCopyWith<$Res>? get recurrence;

}
/// @nodoc
class __$SnUserCalendarEventCopyWithImpl<$Res>
    implements _$SnUserCalendarEventCopyWith<$Res> {
  __$SnUserCalendarEventCopyWithImpl(this._self, this._then);

  final _SnUserCalendarEvent _self;
  final $Res Function(_SnUserCalendarEvent) _then;

/// Create a copy of SnUserCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? location = freezed,Object? startTime = null,Object? endTime = null,Object? isAllDay = null,Object? visibility = null,Object? recurrence = freezed,Object? meta = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnUserCalendarEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as SnRecurrencePattern?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnUserCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRecurrencePatternCopyWith<$Res>? get recurrence {
    if (_self.recurrence == null) {
    return null;
  }

  return $SnRecurrencePatternCopyWith<$Res>(_self.recurrence!, (value) {
    return _then(_self.copyWith(recurrence: value));
  });
}
}


/// @nodoc
mixin _$SnMergedCalendarEvent {

 String? get id; String get type; String get title; String? get description; String? get location; DateTime get startTime; DateTime get endTime; bool get isAllDay; Map<String, dynamic>? get meta;
/// Create a copy of SnMergedCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnMergedCalendarEventCopyWith<SnMergedCalendarEvent> get copyWith => _$SnMergedCalendarEventCopyWithImpl<SnMergedCalendarEvent>(this as SnMergedCalendarEvent, _$identity);

  /// Serializes this SnMergedCalendarEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnMergedCalendarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&const DeepCollectionEquality().equals(other.meta, meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,description,location,startTime,endTime,isAllDay,const DeepCollectionEquality().hash(meta));

@override
String toString() {
  return 'SnMergedCalendarEvent(id: $id, type: $type, title: $title, description: $description, location: $location, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $SnMergedCalendarEventCopyWith<$Res>  {
  factory $SnMergedCalendarEventCopyWith(SnMergedCalendarEvent value, $Res Function(SnMergedCalendarEvent) _then) = _$SnMergedCalendarEventCopyWithImpl;
@useResult
$Res call({
 String? id, String type, String title, String? description, String? location, DateTime startTime, DateTime endTime, bool isAllDay, Map<String, dynamic>? meta
});




}
/// @nodoc
class _$SnMergedCalendarEventCopyWithImpl<$Res>
    implements $SnMergedCalendarEventCopyWith<$Res> {
  _$SnMergedCalendarEventCopyWithImpl(this._self, this._then);

  final SnMergedCalendarEvent _self;
  final $Res Function(SnMergedCalendarEvent) _then;

/// Create a copy of SnMergedCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? type = null,Object? title = null,Object? description = freezed,Object? location = freezed,Object? startTime = null,Object? endTime = null,Object? isAllDay = null,Object? meta = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnMergedCalendarEvent].
extension SnMergedCalendarEventPatterns on SnMergedCalendarEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnMergedCalendarEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnMergedCalendarEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnMergedCalendarEvent value)  $default,){
final _that = this;
switch (_that) {
case _SnMergedCalendarEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnMergedCalendarEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SnMergedCalendarEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String type,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  Map<String, dynamic>? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnMergedCalendarEvent() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String type,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  Map<String, dynamic>? meta)  $default,) {final _that = this;
switch (_that) {
case _SnMergedCalendarEvent():
return $default(_that.id,_that.type,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.meta);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String type,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  Map<String, dynamic>? meta)?  $default,) {final _that = this;
switch (_that) {
case _SnMergedCalendarEvent() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnMergedCalendarEvent implements SnMergedCalendarEvent {
  const _SnMergedCalendarEvent({this.id, required this.type, required this.title, this.description, this.location, required this.startTime, required this.endTime, this.isAllDay = false, final  Map<String, dynamic>? meta}): _meta = meta;
  factory _SnMergedCalendarEvent.fromJson(Map<String, dynamic> json) => _$SnMergedCalendarEventFromJson(json);

@override final  String? id;
@override final  String type;
@override final  String title;
@override final  String? description;
@override final  String? location;
@override final  DateTime startTime;
@override final  DateTime endTime;
@override@JsonKey() final  bool isAllDay;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SnMergedCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnMergedCalendarEventCopyWith<_SnMergedCalendarEvent> get copyWith => __$SnMergedCalendarEventCopyWithImpl<_SnMergedCalendarEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnMergedCalendarEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnMergedCalendarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&const DeepCollectionEquality().equals(other._meta, _meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,description,location,startTime,endTime,isAllDay,const DeepCollectionEquality().hash(_meta));

@override
String toString() {
  return 'SnMergedCalendarEvent(id: $id, type: $type, title: $title, description: $description, location: $location, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$SnMergedCalendarEventCopyWith<$Res> implements $SnMergedCalendarEventCopyWith<$Res> {
  factory _$SnMergedCalendarEventCopyWith(_SnMergedCalendarEvent value, $Res Function(_SnMergedCalendarEvent) _then) = __$SnMergedCalendarEventCopyWithImpl;
@override @useResult
$Res call({
 String? id, String type, String title, String? description, String? location, DateTime startTime, DateTime endTime, bool isAllDay, Map<String, dynamic>? meta
});




}
/// @nodoc
class __$SnMergedCalendarEventCopyWithImpl<$Res>
    implements _$SnMergedCalendarEventCopyWith<$Res> {
  __$SnMergedCalendarEventCopyWithImpl(this._self, this._then);

  final _SnMergedCalendarEvent _self;
  final $Res Function(_SnMergedCalendarEvent) _then;

/// Create a copy of SnMergedCalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? type = null,Object? title = null,Object? description = freezed,Object? location = freezed,Object? startTime = null,Object? endTime = null,Object? isAllDay = null,Object? meta = freezed,}) {
  return _then(_SnMergedCalendarEvent(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$SnEventCalendarEntry {

 DateTime get date; SnCheckInResult? get checkInResult; List<SnAccountStatus> get statuses; List<SnUserCalendarEvent> get userEvents; List<SnNotableDay> get notableDays; List<SnMergedCalendarEvent>? get mergedEvents;
/// Create a copy of SnEventCalendarEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnEventCalendarEntryCopyWith<SnEventCalendarEntry> get copyWith => _$SnEventCalendarEntryCopyWithImpl<SnEventCalendarEntry>(this as SnEventCalendarEntry, _$identity);

  /// Serializes this SnEventCalendarEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnEventCalendarEntry&&(identical(other.date, date) || other.date == date)&&(identical(other.checkInResult, checkInResult) || other.checkInResult == checkInResult)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.userEvents, userEvents)&&const DeepCollectionEquality().equals(other.notableDays, notableDays)&&const DeepCollectionEquality().equals(other.mergedEvents, mergedEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,checkInResult,const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(userEvents),const DeepCollectionEquality().hash(notableDays),const DeepCollectionEquality().hash(mergedEvents));

@override
String toString() {
  return 'SnEventCalendarEntry(date: $date, checkInResult: $checkInResult, statuses: $statuses, userEvents: $userEvents, notableDays: $notableDays, mergedEvents: $mergedEvents)';
}


}

/// @nodoc
abstract mixin class $SnEventCalendarEntryCopyWith<$Res>  {
  factory $SnEventCalendarEntryCopyWith(SnEventCalendarEntry value, $Res Function(SnEventCalendarEntry) _then) = _$SnEventCalendarEntryCopyWithImpl;
@useResult
$Res call({
 DateTime date, SnCheckInResult? checkInResult, List<SnAccountStatus> statuses, List<SnUserCalendarEvent> userEvents, List<SnNotableDay> notableDays, List<SnMergedCalendarEvent>? mergedEvents
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
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? checkInResult = freezed,Object? statuses = null,Object? userEvents = null,Object? notableDays = null,Object? mergedEvents = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,checkInResult: freezed == checkInResult ? _self.checkInResult : checkInResult // ignore: cast_nullable_to_non_nullable
as SnCheckInResult?,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<SnAccountStatus>,userEvents: null == userEvents ? _self.userEvents : userEvents // ignore: cast_nullable_to_non_nullable
as List<SnUserCalendarEvent>,notableDays: null == notableDays ? _self.notableDays : notableDays // ignore: cast_nullable_to_non_nullable
as List<SnNotableDay>,mergedEvents: freezed == mergedEvents ? _self.mergedEvents : mergedEvents // ignore: cast_nullable_to_non_nullable
as List<SnMergedCalendarEvent>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  SnCheckInResult? checkInResult,  List<SnAccountStatus> statuses,  List<SnUserCalendarEvent> userEvents,  List<SnNotableDay> notableDays,  List<SnMergedCalendarEvent>? mergedEvents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnEventCalendarEntry() when $default != null:
return $default(_that.date,_that.checkInResult,_that.statuses,_that.userEvents,_that.notableDays,_that.mergedEvents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  SnCheckInResult? checkInResult,  List<SnAccountStatus> statuses,  List<SnUserCalendarEvent> userEvents,  List<SnNotableDay> notableDays,  List<SnMergedCalendarEvent>? mergedEvents)  $default,) {final _that = this;
switch (_that) {
case _SnEventCalendarEntry():
return $default(_that.date,_that.checkInResult,_that.statuses,_that.userEvents,_that.notableDays,_that.mergedEvents);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  SnCheckInResult? checkInResult,  List<SnAccountStatus> statuses,  List<SnUserCalendarEvent> userEvents,  List<SnNotableDay> notableDays,  List<SnMergedCalendarEvent>? mergedEvents)?  $default,) {final _that = this;
switch (_that) {
case _SnEventCalendarEntry() when $default != null:
return $default(_that.date,_that.checkInResult,_that.statuses,_that.userEvents,_that.notableDays,_that.mergedEvents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnEventCalendarEntry implements SnEventCalendarEntry {
  const _SnEventCalendarEntry({required this.date, this.checkInResult, final  List<SnAccountStatus> statuses = const [], final  List<SnUserCalendarEvent> userEvents = const [], final  List<SnNotableDay> notableDays = const [], final  List<SnMergedCalendarEvent>? mergedEvents}): _statuses = statuses,_userEvents = userEvents,_notableDays = notableDays,_mergedEvents = mergedEvents;
  factory _SnEventCalendarEntry.fromJson(Map<String, dynamic> json) => _$SnEventCalendarEntryFromJson(json);

@override final  DateTime date;
@override final  SnCheckInResult? checkInResult;
 final  List<SnAccountStatus> _statuses;
@override@JsonKey() List<SnAccountStatus> get statuses {
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statuses);
}

 final  List<SnUserCalendarEvent> _userEvents;
@override@JsonKey() List<SnUserCalendarEvent> get userEvents {
  if (_userEvents is EqualUnmodifiableListView) return _userEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userEvents);
}

 final  List<SnNotableDay> _notableDays;
@override@JsonKey() List<SnNotableDay> get notableDays {
  if (_notableDays is EqualUnmodifiableListView) return _notableDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notableDays);
}

 final  List<SnMergedCalendarEvent>? _mergedEvents;
@override List<SnMergedCalendarEvent>? get mergedEvents {
  final value = _mergedEvents;
  if (value == null) return null;
  if (_mergedEvents is EqualUnmodifiableListView) return _mergedEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnEventCalendarEntry&&(identical(other.date, date) || other.date == date)&&(identical(other.checkInResult, checkInResult) || other.checkInResult == checkInResult)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._userEvents, _userEvents)&&const DeepCollectionEquality().equals(other._notableDays, _notableDays)&&const DeepCollectionEquality().equals(other._mergedEvents, _mergedEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,checkInResult,const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_userEvents),const DeepCollectionEquality().hash(_notableDays),const DeepCollectionEquality().hash(_mergedEvents));

@override
String toString() {
  return 'SnEventCalendarEntry(date: $date, checkInResult: $checkInResult, statuses: $statuses, userEvents: $userEvents, notableDays: $notableDays, mergedEvents: $mergedEvents)';
}


}

/// @nodoc
abstract mixin class _$SnEventCalendarEntryCopyWith<$Res> implements $SnEventCalendarEntryCopyWith<$Res> {
  factory _$SnEventCalendarEntryCopyWith(_SnEventCalendarEntry value, $Res Function(_SnEventCalendarEntry) _then) = __$SnEventCalendarEntryCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, SnCheckInResult? checkInResult, List<SnAccountStatus> statuses, List<SnUserCalendarEvent> userEvents, List<SnNotableDay> notableDays, List<SnMergedCalendarEvent>? mergedEvents
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
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? checkInResult = freezed,Object? statuses = null,Object? userEvents = null,Object? notableDays = null,Object? mergedEvents = freezed,}) {
  return _then(_SnEventCalendarEntry(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,checkInResult: freezed == checkInResult ? _self.checkInResult : checkInResult // ignore: cast_nullable_to_non_nullable
as SnCheckInResult?,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<SnAccountStatus>,userEvents: null == userEvents ? _self._userEvents : userEvents // ignore: cast_nullable_to_non_nullable
as List<SnUserCalendarEvent>,notableDays: null == notableDays ? _self._notableDays : notableDays // ignore: cast_nullable_to_non_nullable
as List<SnNotableDay>,mergedEvents: freezed == mergedEvents ? _self._mergedEvents : mergedEvents // ignore: cast_nullable_to_non_nullable
as List<SnMergedCalendarEvent>?,
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

 String get id; int get type; String? get manualId; String? get title; String? get subtitle; String? get caption; String? get titleUrl; String? get subtitleUrl; String? get smallImage; String? get largeImage; Map<String, dynamic>? get meta; int get leaseMinutes; DateTime get leaseExpiresAt; String get accountId; SnAccount? get account; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPresenceActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPresenceActivityCopyWith<SnPresenceActivity> get copyWith => _$SnPresenceActivityCopyWithImpl<SnPresenceActivity>(this as SnPresenceActivity, _$identity);

  /// Serializes this SnPresenceActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPresenceActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.manualId, manualId) || other.manualId == manualId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.titleUrl, titleUrl) || other.titleUrl == titleUrl)&&(identical(other.subtitleUrl, subtitleUrl) || other.subtitleUrl == subtitleUrl)&&(identical(other.smallImage, smallImage) || other.smallImage == smallImage)&&(identical(other.largeImage, largeImage) || other.largeImage == largeImage)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.leaseMinutes, leaseMinutes) || other.leaseMinutes == leaseMinutes)&&(identical(other.leaseExpiresAt, leaseExpiresAt) || other.leaseExpiresAt == leaseExpiresAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,manualId,title,subtitle,caption,titleUrl,subtitleUrl,smallImage,largeImage,const DeepCollectionEquality().hash(meta),leaseMinutes,leaseExpiresAt,accountId,account,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPresenceActivity(id: $id, type: $type, manualId: $manualId, title: $title, subtitle: $subtitle, caption: $caption, titleUrl: $titleUrl, subtitleUrl: $subtitleUrl, smallImage: $smallImage, largeImage: $largeImage, meta: $meta, leaseMinutes: $leaseMinutes, leaseExpiresAt: $leaseExpiresAt, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPresenceActivityCopyWith<$Res>  {
  factory $SnPresenceActivityCopyWith(SnPresenceActivity value, $Res Function(SnPresenceActivity) _then) = _$SnPresenceActivityCopyWithImpl;
@useResult
$Res call({
 String id, int type, String? manualId, String? title, String? subtitle, String? caption, String? titleUrl, String? subtitleUrl, String? smallImage, String? largeImage, Map<String, dynamic>? meta, int leaseMinutes, DateTime leaseExpiresAt, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnPresenceActivityCopyWithImpl<$Res>
    implements $SnPresenceActivityCopyWith<$Res> {
  _$SnPresenceActivityCopyWithImpl(this._self, this._then);

  final SnPresenceActivity _self;
  final $Res Function(SnPresenceActivity) _then;

/// Create a copy of SnPresenceActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? manualId = freezed,Object? title = freezed,Object? subtitle = freezed,Object? caption = freezed,Object? titleUrl = freezed,Object? subtitleUrl = freezed,Object? smallImage = freezed,Object? largeImage = freezed,Object? meta = freezed,Object? leaseMinutes = null,Object? leaseExpiresAt = null,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
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
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPresenceActivity
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int type,  String? manualId,  String? title,  String? subtitle,  String? caption,  String? titleUrl,  String? subtitleUrl,  String? smallImage,  String? largeImage,  Map<String, dynamic>? meta,  int leaseMinutes,  DateTime leaseExpiresAt,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPresenceActivity() when $default != null:
return $default(_that.id,_that.type,_that.manualId,_that.title,_that.subtitle,_that.caption,_that.titleUrl,_that.subtitleUrl,_that.smallImage,_that.largeImage,_that.meta,_that.leaseMinutes,_that.leaseExpiresAt,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int type,  String? manualId,  String? title,  String? subtitle,  String? caption,  String? titleUrl,  String? subtitleUrl,  String? smallImage,  String? largeImage,  Map<String, dynamic>? meta,  int leaseMinutes,  DateTime leaseExpiresAt,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPresenceActivity():
return $default(_that.id,_that.type,_that.manualId,_that.title,_that.subtitle,_that.caption,_that.titleUrl,_that.subtitleUrl,_that.smallImage,_that.largeImage,_that.meta,_that.leaseMinutes,_that.leaseExpiresAt,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int type,  String? manualId,  String? title,  String? subtitle,  String? caption,  String? titleUrl,  String? subtitleUrl,  String? smallImage,  String? largeImage,  Map<String, dynamic>? meta,  int leaseMinutes,  DateTime leaseExpiresAt,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPresenceActivity() when $default != null:
return $default(_that.id,_that.type,_that.manualId,_that.title,_that.subtitle,_that.caption,_that.titleUrl,_that.subtitleUrl,_that.smallImage,_that.largeImage,_that.meta,_that.leaseMinutes,_that.leaseExpiresAt,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPresenceActivity implements SnPresenceActivity {
  const _SnPresenceActivity({required this.id, required this.type, required this.manualId, required this.title, required this.subtitle, required this.caption, required this.titleUrl, required this.subtitleUrl, required this.smallImage, required this.largeImage, required final  Map<String, dynamic>? meta, required this.leaseMinutes, required this.leaseExpiresAt, required this.accountId, this.account, required this.createdAt, required this.updatedAt, required this.deletedAt}): _meta = meta;
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
@override final  SnAccount? account;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPresenceActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.manualId, manualId) || other.manualId == manualId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.titleUrl, titleUrl) || other.titleUrl == titleUrl)&&(identical(other.subtitleUrl, subtitleUrl) || other.subtitleUrl == subtitleUrl)&&(identical(other.smallImage, smallImage) || other.smallImage == smallImage)&&(identical(other.largeImage, largeImage) || other.largeImage == largeImage)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.leaseMinutes, leaseMinutes) || other.leaseMinutes == leaseMinutes)&&(identical(other.leaseExpiresAt, leaseExpiresAt) || other.leaseExpiresAt == leaseExpiresAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,manualId,title,subtitle,caption,titleUrl,subtitleUrl,smallImage,largeImage,const DeepCollectionEquality().hash(_meta),leaseMinutes,leaseExpiresAt,accountId,account,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPresenceActivity(id: $id, type: $type, manualId: $manualId, title: $title, subtitle: $subtitle, caption: $caption, titleUrl: $titleUrl, subtitleUrl: $subtitleUrl, smallImage: $smallImage, largeImage: $largeImage, meta: $meta, leaseMinutes: $leaseMinutes, leaseExpiresAt: $leaseExpiresAt, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPresenceActivityCopyWith<$Res> implements $SnPresenceActivityCopyWith<$Res> {
  factory _$SnPresenceActivityCopyWith(_SnPresenceActivity value, $Res Function(_SnPresenceActivity) _then) = __$SnPresenceActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, String? manualId, String? title, String? subtitle, String? caption, String? titleUrl, String? subtitleUrl, String? smallImage, String? largeImage, Map<String, dynamic>? meta, int leaseMinutes, DateTime leaseExpiresAt, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnPresenceActivityCopyWithImpl<$Res>
    implements _$SnPresenceActivityCopyWith<$Res> {
  __$SnPresenceActivityCopyWithImpl(this._self, this._then);

  final _SnPresenceActivity _self;
  final $Res Function(_SnPresenceActivity) _then;

/// Create a copy of SnPresenceActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? manualId = freezed,Object? title = freezed,Object? subtitle = freezed,Object? caption = freezed,Object? titleUrl = freezed,Object? subtitleUrl = freezed,Object? smallImage = freezed,Object? largeImage = freezed,Object? meta = freezed,Object? leaseMinutes = null,Object? leaseExpiresAt = null,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
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
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPresenceActivity
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
mixin _$SnAccountTimelineItem {

 String get id; DateTime get createdAt; int get eventType; SnPresenceActivity? get activity; SnAccountStatus? get status;
/// Create a copy of SnAccountTimelineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountTimelineItemCopyWith<SnAccountTimelineItem> get copyWith => _$SnAccountTimelineItemCopyWithImpl<SnAccountTimelineItem>(this as SnAccountTimelineItem, _$identity);

  /// Serializes this SnAccountTimelineItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountTimelineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,eventType,activity,status);

@override
String toString() {
  return 'SnAccountTimelineItem(id: $id, createdAt: $createdAt, eventType: $eventType, activity: $activity, status: $status)';
}


}

/// @nodoc
abstract mixin class $SnAccountTimelineItemCopyWith<$Res>  {
  factory $SnAccountTimelineItemCopyWith(SnAccountTimelineItem value, $Res Function(SnAccountTimelineItem) _then) = _$SnAccountTimelineItemCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, int eventType, SnPresenceActivity? activity, SnAccountStatus? status
});


$SnPresenceActivityCopyWith<$Res>? get activity;$SnAccountStatusCopyWith<$Res>? get status;

}
/// @nodoc
class _$SnAccountTimelineItemCopyWithImpl<$Res>
    implements $SnAccountTimelineItemCopyWith<$Res> {
  _$SnAccountTimelineItemCopyWithImpl(this._self, this._then);

  final SnAccountTimelineItem _self;
  final $Res Function(SnAccountTimelineItem) _then;

/// Create a copy of SnAccountTimelineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? eventType = null,Object? activity = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as int,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as SnPresenceActivity?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnAccountStatus?,
  ));
}
/// Create a copy of SnAccountTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPresenceActivityCopyWith<$Res>? get activity {
    if (_self.activity == null) {
    return null;
  }

  return $SnPresenceActivityCopyWith<$Res>(_self.activity!, (value) {
    return _then(_self.copyWith(activity: value));
  });
}/// Create a copy of SnAccountTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $SnAccountStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnAccountTimelineItem].
extension SnAccountTimelineItemPatterns on SnAccountTimelineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountTimelineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountTimelineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountTimelineItem value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountTimelineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountTimelineItem value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountTimelineItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  int eventType,  SnPresenceActivity? activity,  SnAccountStatus? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountTimelineItem() when $default != null:
return $default(_that.id,_that.createdAt,_that.eventType,_that.activity,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  int eventType,  SnPresenceActivity? activity,  SnAccountStatus? status)  $default,) {final _that = this;
switch (_that) {
case _SnAccountTimelineItem():
return $default(_that.id,_that.createdAt,_that.eventType,_that.activity,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  int eventType,  SnPresenceActivity? activity,  SnAccountStatus? status)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountTimelineItem() when $default != null:
return $default(_that.id,_that.createdAt,_that.eventType,_that.activity,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountTimelineItem implements SnAccountTimelineItem {
  const _SnAccountTimelineItem({required this.id, required this.createdAt, required this.eventType, this.activity, this.status});
  factory _SnAccountTimelineItem.fromJson(Map<String, dynamic> json) => _$SnAccountTimelineItemFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  int eventType;
@override final  SnPresenceActivity? activity;
@override final  SnAccountStatus? status;

/// Create a copy of SnAccountTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountTimelineItemCopyWith<_SnAccountTimelineItem> get copyWith => __$SnAccountTimelineItemCopyWithImpl<_SnAccountTimelineItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountTimelineItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountTimelineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.activity, activity) || other.activity == activity)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,eventType,activity,status);

@override
String toString() {
  return 'SnAccountTimelineItem(id: $id, createdAt: $createdAt, eventType: $eventType, activity: $activity, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SnAccountTimelineItemCopyWith<$Res> implements $SnAccountTimelineItemCopyWith<$Res> {
  factory _$SnAccountTimelineItemCopyWith(_SnAccountTimelineItem value, $Res Function(_SnAccountTimelineItem) _then) = __$SnAccountTimelineItemCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, int eventType, SnPresenceActivity? activity, SnAccountStatus? status
});


@override $SnPresenceActivityCopyWith<$Res>? get activity;@override $SnAccountStatusCopyWith<$Res>? get status;

}
/// @nodoc
class __$SnAccountTimelineItemCopyWithImpl<$Res>
    implements _$SnAccountTimelineItemCopyWith<$Res> {
  __$SnAccountTimelineItemCopyWithImpl(this._self, this._then);

  final _SnAccountTimelineItem _self;
  final $Res Function(_SnAccountTimelineItem) _then;

/// Create a copy of SnAccountTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? eventType = null,Object? activity = freezed,Object? status = freezed,}) {
  return _then(_SnAccountTimelineItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as int,activity: freezed == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as SnPresenceActivity?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnAccountStatus?,
  ));
}

/// Create a copy of SnAccountTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPresenceActivityCopyWith<$Res>? get activity {
    if (_self.activity == null) {
    return null;
  }

  return $SnPresenceActivityCopyWith<$Res>(_self.activity!, (value) {
    return _then(_self.copyWith(activity: value));
  });
}/// Create a copy of SnAccountTimelineItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $SnAccountStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// @nodoc
mixin _$SnEventCountdownItem {

 String? get eventId; int get eventType; String get title; String? get description; String? get location; DateTime get startTime; DateTime get endTime; bool get isAllDay; int get daysRemaining; int get hoursRemaining; bool get isOngoing; Map<String, dynamic>? get meta; String? get accountId;
/// Create a copy of SnEventCountdownItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnEventCountdownItemCopyWith<SnEventCountdownItem> get copyWith => _$SnEventCountdownItemCopyWithImpl<SnEventCountdownItem>(this as SnEventCountdownItem, _$identity);

  /// Serializes this SnEventCountdownItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnEventCountdownItem&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.daysRemaining, daysRemaining) || other.daysRemaining == daysRemaining)&&(identical(other.hoursRemaining, hoursRemaining) || other.hoursRemaining == hoursRemaining)&&(identical(other.isOngoing, isOngoing) || other.isOngoing == isOngoing)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventType,title,description,location,startTime,endTime,isAllDay,daysRemaining,hoursRemaining,isOngoing,const DeepCollectionEquality().hash(meta),accountId);

@override
String toString() {
  return 'SnEventCountdownItem(eventId: $eventId, eventType: $eventType, title: $title, description: $description, location: $location, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, daysRemaining: $daysRemaining, hoursRemaining: $hoursRemaining, isOngoing: $isOngoing, meta: $meta, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class $SnEventCountdownItemCopyWith<$Res>  {
  factory $SnEventCountdownItemCopyWith(SnEventCountdownItem value, $Res Function(SnEventCountdownItem) _then) = _$SnEventCountdownItemCopyWithImpl;
@useResult
$Res call({
 String? eventId, int eventType, String title, String? description, String? location, DateTime startTime, DateTime endTime, bool isAllDay, int daysRemaining, int hoursRemaining, bool isOngoing, Map<String, dynamic>? meta, String? accountId
});




}
/// @nodoc
class _$SnEventCountdownItemCopyWithImpl<$Res>
    implements $SnEventCountdownItemCopyWith<$Res> {
  _$SnEventCountdownItemCopyWithImpl(this._self, this._then);

  final SnEventCountdownItem _self;
  final $Res Function(SnEventCountdownItem) _then;

/// Create a copy of SnEventCountdownItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = freezed,Object? eventType = null,Object? title = null,Object? description = freezed,Object? location = freezed,Object? startTime = null,Object? endTime = null,Object? isAllDay = null,Object? daysRemaining = null,Object? hoursRemaining = null,Object? isOngoing = null,Object? meta = freezed,Object? accountId = freezed,}) {
  return _then(_self.copyWith(
eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,daysRemaining: null == daysRemaining ? _self.daysRemaining : daysRemaining // ignore: cast_nullable_to_non_nullable
as int,hoursRemaining: null == hoursRemaining ? _self.hoursRemaining : hoursRemaining // ignore: cast_nullable_to_non_nullable
as int,isOngoing: null == isOngoing ? _self.isOngoing : isOngoing // ignore: cast_nullable_to_non_nullable
as bool,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnEventCountdownItem].
extension SnEventCountdownItemPatterns on SnEventCountdownItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnEventCountdownItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnEventCountdownItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnEventCountdownItem value)  $default,){
final _that = this;
switch (_that) {
case _SnEventCountdownItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnEventCountdownItem value)?  $default,){
final _that = this;
switch (_that) {
case _SnEventCountdownItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? eventId,  int eventType,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  int daysRemaining,  int hoursRemaining,  bool isOngoing,  Map<String, dynamic>? meta,  String? accountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnEventCountdownItem() when $default != null:
return $default(_that.eventId,_that.eventType,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.daysRemaining,_that.hoursRemaining,_that.isOngoing,_that.meta,_that.accountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? eventId,  int eventType,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  int daysRemaining,  int hoursRemaining,  bool isOngoing,  Map<String, dynamic>? meta,  String? accountId)  $default,) {final _that = this;
switch (_that) {
case _SnEventCountdownItem():
return $default(_that.eventId,_that.eventType,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.daysRemaining,_that.hoursRemaining,_that.isOngoing,_that.meta,_that.accountId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? eventId,  int eventType,  String title,  String? description,  String? location,  DateTime startTime,  DateTime endTime,  bool isAllDay,  int daysRemaining,  int hoursRemaining,  bool isOngoing,  Map<String, dynamic>? meta,  String? accountId)?  $default,) {final _that = this;
switch (_that) {
case _SnEventCountdownItem() when $default != null:
return $default(_that.eventId,_that.eventType,_that.title,_that.description,_that.location,_that.startTime,_that.endTime,_that.isAllDay,_that.daysRemaining,_that.hoursRemaining,_that.isOngoing,_that.meta,_that.accountId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnEventCountdownItem implements SnEventCountdownItem {
  const _SnEventCountdownItem({this.eventId, required this.eventType, required this.title, this.description, this.location, required this.startTime, required this.endTime, this.isAllDay = false, required this.daysRemaining, required this.hoursRemaining, required this.isOngoing, final  Map<String, dynamic>? meta, this.accountId}): _meta = meta;
  factory _SnEventCountdownItem.fromJson(Map<String, dynamic> json) => _$SnEventCountdownItemFromJson(json);

@override final  String? eventId;
@override final  int eventType;
@override final  String title;
@override final  String? description;
@override final  String? location;
@override final  DateTime startTime;
@override final  DateTime endTime;
@override@JsonKey() final  bool isAllDay;
@override final  int daysRemaining;
@override final  int hoursRemaining;
@override final  bool isOngoing;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? accountId;

/// Create a copy of SnEventCountdownItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnEventCountdownItemCopyWith<_SnEventCountdownItem> get copyWith => __$SnEventCountdownItemCopyWithImpl<_SnEventCountdownItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnEventCountdownItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnEventCountdownItem&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isAllDay, isAllDay) || other.isAllDay == isAllDay)&&(identical(other.daysRemaining, daysRemaining) || other.daysRemaining == daysRemaining)&&(identical(other.hoursRemaining, hoursRemaining) || other.hoursRemaining == hoursRemaining)&&(identical(other.isOngoing, isOngoing) || other.isOngoing == isOngoing)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,eventType,title,description,location,startTime,endTime,isAllDay,daysRemaining,hoursRemaining,isOngoing,const DeepCollectionEquality().hash(_meta),accountId);

@override
String toString() {
  return 'SnEventCountdownItem(eventId: $eventId, eventType: $eventType, title: $title, description: $description, location: $location, startTime: $startTime, endTime: $endTime, isAllDay: $isAllDay, daysRemaining: $daysRemaining, hoursRemaining: $hoursRemaining, isOngoing: $isOngoing, meta: $meta, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class _$SnEventCountdownItemCopyWith<$Res> implements $SnEventCountdownItemCopyWith<$Res> {
  factory _$SnEventCountdownItemCopyWith(_SnEventCountdownItem value, $Res Function(_SnEventCountdownItem) _then) = __$SnEventCountdownItemCopyWithImpl;
@override @useResult
$Res call({
 String? eventId, int eventType, String title, String? description, String? location, DateTime startTime, DateTime endTime, bool isAllDay, int daysRemaining, int hoursRemaining, bool isOngoing, Map<String, dynamic>? meta, String? accountId
});




}
/// @nodoc
class __$SnEventCountdownItemCopyWithImpl<$Res>
    implements _$SnEventCountdownItemCopyWith<$Res> {
  __$SnEventCountdownItemCopyWithImpl(this._self, this._then);

  final _SnEventCountdownItem _self;
  final $Res Function(_SnEventCountdownItem) _then;

/// Create a copy of SnEventCountdownItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = freezed,Object? eventType = null,Object? title = null,Object? description = freezed,Object? location = freezed,Object? startTime = null,Object? endTime = null,Object? isAllDay = null,Object? daysRemaining = null,Object? hoursRemaining = null,Object? isOngoing = null,Object? meta = freezed,Object? accountId = freezed,}) {
  return _then(_SnEventCountdownItem(
eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,isAllDay: null == isAllDay ? _self.isAllDay : isAllDay // ignore: cast_nullable_to_non_nullable
as bool,daysRemaining: null == daysRemaining ? _self.daysRemaining : daysRemaining // ignore: cast_nullable_to_non_nullable
as int,hoursRemaining: null == hoursRemaining ? _self.hoursRemaining : hoursRemaining // ignore: cast_nullable_to_non_nullable
as int,isOngoing: null == isOngoing ? _self.isOngoing : isOngoing // ignore: cast_nullable_to_non_nullable
as bool,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
