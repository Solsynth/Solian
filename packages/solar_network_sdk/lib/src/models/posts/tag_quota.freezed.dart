// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag_quota.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnProtectedTagRecord {

 String get id; String get slug; String? get name; String? get description;@JsonKey(name: 'is_protected') bool get isProtected;@JsonKey(name: 'is_event') bool get isEvent;@JsonKey(name: 'event_ends_at') DateTime? get eventEndsAt;
/// Create a copy of SnProtectedTagRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnProtectedTagRecordCopyWith<SnProtectedTagRecord> get copyWith => _$SnProtectedTagRecordCopyWithImpl<SnProtectedTagRecord>(this as SnProtectedTagRecord, _$identity);

  /// Serializes this SnProtectedTagRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnProtectedTagRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isProtected, isProtected) || other.isProtected == isProtected)&&(identical(other.isEvent, isEvent) || other.isEvent == isEvent)&&(identical(other.eventEndsAt, eventEndsAt) || other.eventEndsAt == eventEndsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,isProtected,isEvent,eventEndsAt);

@override
String toString() {
  return 'SnProtectedTagRecord(id: $id, slug: $slug, name: $name, description: $description, isProtected: $isProtected, isEvent: $isEvent, eventEndsAt: $eventEndsAt)';
}


}

/// @nodoc
abstract mixin class $SnProtectedTagRecordCopyWith<$Res>  {
  factory $SnProtectedTagRecordCopyWith(SnProtectedTagRecord value, $Res Function(SnProtectedTagRecord) _then) = _$SnProtectedTagRecordCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String? name, String? description,@JsonKey(name: 'is_protected') bool isProtected,@JsonKey(name: 'is_event') bool isEvent,@JsonKey(name: 'event_ends_at') DateTime? eventEndsAt
});




}
/// @nodoc
class _$SnProtectedTagRecordCopyWithImpl<$Res>
    implements $SnProtectedTagRecordCopyWith<$Res> {
  _$SnProtectedTagRecordCopyWithImpl(this._self, this._then);

  final SnProtectedTagRecord _self;
  final $Res Function(SnProtectedTagRecord) _then;

/// Create a copy of SnProtectedTagRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? description = freezed,Object? isProtected = null,Object? isEvent = null,Object? eventEndsAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isProtected: null == isProtected ? _self.isProtected : isProtected // ignore: cast_nullable_to_non_nullable
as bool,isEvent: null == isEvent ? _self.isEvent : isEvent // ignore: cast_nullable_to_non_nullable
as bool,eventEndsAt: freezed == eventEndsAt ? _self.eventEndsAt : eventEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnProtectedTagRecord].
extension SnProtectedTagRecordPatterns on SnProtectedTagRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnProtectedTagRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnProtectedTagRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnProtectedTagRecord value)  $default,){
final _that = this;
switch (_that) {
case _SnProtectedTagRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnProtectedTagRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SnProtectedTagRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'is_protected')  bool isProtected, @JsonKey(name: 'is_event')  bool isEvent, @JsonKey(name: 'event_ends_at')  DateTime? eventEndsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnProtectedTagRecord() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.isProtected,_that.isEvent,_that.eventEndsAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'is_protected')  bool isProtected, @JsonKey(name: 'is_event')  bool isEvent, @JsonKey(name: 'event_ends_at')  DateTime? eventEndsAt)  $default,) {final _that = this;
switch (_that) {
case _SnProtectedTagRecord():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.isProtected,_that.isEvent,_that.eventEndsAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'is_protected')  bool isProtected, @JsonKey(name: 'is_event')  bool isEvent, @JsonKey(name: 'event_ends_at')  DateTime? eventEndsAt)?  $default,) {final _that = this;
switch (_that) {
case _SnProtectedTagRecord() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.isProtected,_that.isEvent,_that.eventEndsAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnProtectedTagRecord implements SnProtectedTagRecord {
  const _SnProtectedTagRecord({required this.id, required this.slug, this.name, this.description, @JsonKey(name: 'is_protected') this.isProtected = false, @JsonKey(name: 'is_event') this.isEvent = false, @JsonKey(name: 'event_ends_at') this.eventEndsAt});
  factory _SnProtectedTagRecord.fromJson(Map<String, dynamic> json) => _$SnProtectedTagRecordFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String? name;
@override final  String? description;
@override@JsonKey(name: 'is_protected') final  bool isProtected;
@override@JsonKey(name: 'is_event') final  bool isEvent;
@override@JsonKey(name: 'event_ends_at') final  DateTime? eventEndsAt;

/// Create a copy of SnProtectedTagRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnProtectedTagRecordCopyWith<_SnProtectedTagRecord> get copyWith => __$SnProtectedTagRecordCopyWithImpl<_SnProtectedTagRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnProtectedTagRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnProtectedTagRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isProtected, isProtected) || other.isProtected == isProtected)&&(identical(other.isEvent, isEvent) || other.isEvent == isEvent)&&(identical(other.eventEndsAt, eventEndsAt) || other.eventEndsAt == eventEndsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,isProtected,isEvent,eventEndsAt);

@override
String toString() {
  return 'SnProtectedTagRecord(id: $id, slug: $slug, name: $name, description: $description, isProtected: $isProtected, isEvent: $isEvent, eventEndsAt: $eventEndsAt)';
}


}

/// @nodoc
abstract mixin class _$SnProtectedTagRecordCopyWith<$Res> implements $SnProtectedTagRecordCopyWith<$Res> {
  factory _$SnProtectedTagRecordCopyWith(_SnProtectedTagRecord value, $Res Function(_SnProtectedTagRecord) _then) = __$SnProtectedTagRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String? name, String? description,@JsonKey(name: 'is_protected') bool isProtected,@JsonKey(name: 'is_event') bool isEvent,@JsonKey(name: 'event_ends_at') DateTime? eventEndsAt
});




}
/// @nodoc
class __$SnProtectedTagRecordCopyWithImpl<$Res>
    implements _$SnProtectedTagRecordCopyWith<$Res> {
  __$SnProtectedTagRecordCopyWithImpl(this._self, this._then);

  final _SnProtectedTagRecord _self;
  final $Res Function(_SnProtectedTagRecord) _then;

/// Create a copy of SnProtectedTagRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? description = freezed,Object? isProtected = null,Object? isEvent = null,Object? eventEndsAt = freezed,}) {
  return _then(_SnProtectedTagRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isProtected: null == isProtected ? _self.isProtected : isProtected // ignore: cast_nullable_to_non_nullable
as bool,isEvent: null == isEvent ? _self.isEvent : isEvent // ignore: cast_nullable_to_non_nullable
as bool,eventEndsAt: freezed == eventEndsAt ? _self.eventEndsAt : eventEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnTagQuota {

 int get total; int get used; int get remaining; int get level;@JsonKey(name: 'perk_level') int get perkLevel; List<SnProtectedTagRecord> get records;
/// Create a copy of SnTagQuota
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnTagQuotaCopyWith<SnTagQuota> get copyWith => _$SnTagQuotaCopyWithImpl<SnTagQuota>(this as SnTagQuota, _$identity);

  /// Serializes this SnTagQuota to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnTagQuota&&(identical(other.total, total) || other.total == total)&&(identical(other.used, used) || other.used == used)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.level, level) || other.level == level)&&(identical(other.perkLevel, perkLevel) || other.perkLevel == perkLevel)&&const DeepCollectionEquality().equals(other.records, records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,used,remaining,level,perkLevel,const DeepCollectionEquality().hash(records));

@override
String toString() {
  return 'SnTagQuota(total: $total, used: $used, remaining: $remaining, level: $level, perkLevel: $perkLevel, records: $records)';
}


}

/// @nodoc
abstract mixin class $SnTagQuotaCopyWith<$Res>  {
  factory $SnTagQuotaCopyWith(SnTagQuota value, $Res Function(SnTagQuota) _then) = _$SnTagQuotaCopyWithImpl;
@useResult
$Res call({
 int total, int used, int remaining, int level,@JsonKey(name: 'perk_level') int perkLevel, List<SnProtectedTagRecord> records
});




}
/// @nodoc
class _$SnTagQuotaCopyWithImpl<$Res>
    implements $SnTagQuotaCopyWith<$Res> {
  _$SnTagQuotaCopyWithImpl(this._self, this._then);

  final SnTagQuota _self;
  final $Res Function(SnTagQuota) _then;

/// Create a copy of SnTagQuota
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? used = null,Object? remaining = null,Object? level = null,Object? perkLevel = null,Object? records = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,perkLevel: null == perkLevel ? _self.perkLevel : perkLevel // ignore: cast_nullable_to_non_nullable
as int,records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as List<SnProtectedTagRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnTagQuota].
extension SnTagQuotaPatterns on SnTagQuota {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnTagQuota value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnTagQuota() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnTagQuota value)  $default,){
final _that = this;
switch (_that) {
case _SnTagQuota():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnTagQuota value)?  $default,){
final _that = this;
switch (_that) {
case _SnTagQuota() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int used,  int remaining,  int level, @JsonKey(name: 'perk_level')  int perkLevel,  List<SnProtectedTagRecord> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnTagQuota() when $default != null:
return $default(_that.total,_that.used,_that.remaining,_that.level,_that.perkLevel,_that.records);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int used,  int remaining,  int level, @JsonKey(name: 'perk_level')  int perkLevel,  List<SnProtectedTagRecord> records)  $default,) {final _that = this;
switch (_that) {
case _SnTagQuota():
return $default(_that.total,_that.used,_that.remaining,_that.level,_that.perkLevel,_that.records);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int used,  int remaining,  int level, @JsonKey(name: 'perk_level')  int perkLevel,  List<SnProtectedTagRecord> records)?  $default,) {final _that = this;
switch (_that) {
case _SnTagQuota() when $default != null:
return $default(_that.total,_that.used,_that.remaining,_that.level,_that.perkLevel,_that.records);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnTagQuota implements SnTagQuota {
  const _SnTagQuota({required this.total, required this.used, required this.remaining, required this.level, @JsonKey(name: 'perk_level') required this.perkLevel, required final  List<SnProtectedTagRecord> records}): _records = records;
  factory _SnTagQuota.fromJson(Map<String, dynamic> json) => _$SnTagQuotaFromJson(json);

@override final  int total;
@override final  int used;
@override final  int remaining;
@override final  int level;
@override@JsonKey(name: 'perk_level') final  int perkLevel;
 final  List<SnProtectedTagRecord> _records;
@override List<SnProtectedTagRecord> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}


/// Create a copy of SnTagQuota
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnTagQuotaCopyWith<_SnTagQuota> get copyWith => __$SnTagQuotaCopyWithImpl<_SnTagQuota>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnTagQuotaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnTagQuota&&(identical(other.total, total) || other.total == total)&&(identical(other.used, used) || other.used == used)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.level, level) || other.level == level)&&(identical(other.perkLevel, perkLevel) || other.perkLevel == perkLevel)&&const DeepCollectionEquality().equals(other._records, _records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,used,remaining,level,perkLevel,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'SnTagQuota(total: $total, used: $used, remaining: $remaining, level: $level, perkLevel: $perkLevel, records: $records)';
}


}

/// @nodoc
abstract mixin class _$SnTagQuotaCopyWith<$Res> implements $SnTagQuotaCopyWith<$Res> {
  factory _$SnTagQuotaCopyWith(_SnTagQuota value, $Res Function(_SnTagQuota) _then) = __$SnTagQuotaCopyWithImpl;
@override @useResult
$Res call({
 int total, int used, int remaining, int level,@JsonKey(name: 'perk_level') int perkLevel, List<SnProtectedTagRecord> records
});




}
/// @nodoc
class __$SnTagQuotaCopyWithImpl<$Res>
    implements _$SnTagQuotaCopyWith<$Res> {
  __$SnTagQuotaCopyWithImpl(this._self, this._then);

  final _SnTagQuota _self;
  final $Res Function(_SnTagQuota) _then;

/// Create a copy of SnTagQuota
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? used = null,Object? remaining = null,Object? level = null,Object? perkLevel = null,Object? records = null,}) {
  return _then(_SnTagQuota(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,perkLevel: null == perkLevel ? _self.perkLevel : perkLevel // ignore: cast_nullable_to_non_nullable
as int,records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<SnProtectedTagRecord>,
  ));
}


}

// dart format on
