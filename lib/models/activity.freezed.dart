// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnActivity {

 String get id; String get type; String get resourceIdentifier; dynamic get data; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityCopyWith<SnActivity> get copyWith => _$SnActivityCopyWithImpl<SnActivity>(this as SnActivity, _$identity);

  /// Serializes this SnActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,resourceIdentifier,const DeepCollectionEquality().hash(data),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnActivity(id: $id, type: $type, resourceIdentifier: $resourceIdentifier, data: $data, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnActivityCopyWith<$Res>  {
  factory $SnActivityCopyWith(SnActivity value, $Res Function(SnActivity) _then) = _$SnActivityCopyWithImpl;
@useResult
$Res call({
 String id, String type, String resourceIdentifier, dynamic data, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnActivityCopyWithImpl<$Res>
    implements $SnActivityCopyWith<$Res> {
  _$SnActivityCopyWithImpl(this._self, this._then);

  final SnActivity _self;
  final $Res Function(SnActivity) _then;

/// Create a copy of SnActivity
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


/// @nodoc
@JsonSerializable()

class _SnActivity implements SnActivity {
  const _SnActivity({required this.id, required this.type, required this.resourceIdentifier, required this.data, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnActivity.fromJson(Map<String, dynamic> json) => _$SnActivityFromJson(json);

@override final  String id;
@override final  String type;
@override final  String resourceIdentifier;
@override final  dynamic data;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActivityCopyWith<_SnActivity> get copyWith => __$SnActivityCopyWithImpl<_SnActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,resourceIdentifier,const DeepCollectionEquality().hash(data),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnActivity(id: $id, type: $type, resourceIdentifier: $resourceIdentifier, data: $data, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnActivityCopyWith<$Res> implements $SnActivityCopyWith<$Res> {
  factory _$SnActivityCopyWith(_SnActivity value, $Res Function(_SnActivity) _then) = __$SnActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String resourceIdentifier, dynamic data, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnActivityCopyWithImpl<$Res>
    implements _$SnActivityCopyWith<$Res> {
  __$SnActivityCopyWithImpl(this._self, this._then);

  final _SnActivity _self;
  final $Res Function(_SnActivity) _then;

/// Create a copy of SnActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? resourceIdentifier = null,Object? data = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnActivity(
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

 DateTime get date; SnCheckInResult? get checkInResult; List<dynamic> get statuses;
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
 DateTime date, SnCheckInResult? checkInResult, List<dynamic> statuses
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
as List<dynamic>,
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
@JsonSerializable()

class _SnEventCalendarEntry implements SnEventCalendarEntry {
  const _SnEventCalendarEntry({required this.date, required this.checkInResult, required final  List<dynamic> statuses}): _statuses = statuses;
  factory _SnEventCalendarEntry.fromJson(Map<String, dynamic> json) => _$SnEventCalendarEntryFromJson(json);

@override final  DateTime date;
@override final  SnCheckInResult? checkInResult;
 final  List<dynamic> _statuses;
@override List<dynamic> get statuses {
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
 DateTime date, SnCheckInResult? checkInResult, List<dynamic> statuses
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
as List<dynamic>,
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

// dart format on
