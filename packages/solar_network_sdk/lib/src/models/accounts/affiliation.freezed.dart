// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'affiliation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAffiliationSpell {

 String get id; String get spell; int get type; DateTime? get expiresAt; DateTime? get affectedAt; Map<String, dynamic> get meta; String? get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAffiliationSpell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAffiliationSpellCopyWith<SnAffiliationSpell> get copyWith => _$SnAffiliationSpellCopyWithImpl<SnAffiliationSpell>(this as SnAffiliationSpell, _$identity);

  /// Serializes this SnAffiliationSpell to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAffiliationSpell&&(identical(other.id, id) || other.id == id)&&(identical(other.spell, spell) || other.spell == spell)&&(identical(other.type, type) || other.type == type)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.affectedAt, affectedAt) || other.affectedAt == affectedAt)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spell,type,expiresAt,affectedAt,const DeepCollectionEquality().hash(meta),accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAffiliationSpell(id: $id, spell: $spell, type: $type, expiresAt: $expiresAt, affectedAt: $affectedAt, meta: $meta, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAffiliationSpellCopyWith<$Res>  {
  factory $SnAffiliationSpellCopyWith(SnAffiliationSpell value, $Res Function(SnAffiliationSpell) _then) = _$SnAffiliationSpellCopyWithImpl;
@useResult
$Res call({
 String id, String spell, int type, DateTime? expiresAt, DateTime? affectedAt, Map<String, dynamic> meta, String? accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAffiliationSpellCopyWithImpl<$Res>
    implements $SnAffiliationSpellCopyWith<$Res> {
  _$SnAffiliationSpellCopyWithImpl(this._self, this._then);

  final SnAffiliationSpell _self;
  final $Res Function(SnAffiliationSpell) _then;

/// Create a copy of SnAffiliationSpell
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spell = null,Object? type = null,Object? expiresAt = freezed,Object? affectedAt = freezed,Object? meta = null,Object? accountId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spell: null == spell ? _self.spell : spell // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,affectedAt: freezed == affectedAt ? _self.affectedAt : affectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAffiliationSpell].
extension SnAffiliationSpellPatterns on SnAffiliationSpell {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAffiliationSpell value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAffiliationSpell() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAffiliationSpell value)  $default,){
final _that = this;
switch (_that) {
case _SnAffiliationSpell():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAffiliationSpell value)?  $default,){
final _that = this;
switch (_that) {
case _SnAffiliationSpell() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String spell,  int type,  DateTime? expiresAt,  DateTime? affectedAt,  Map<String, dynamic> meta,  String? accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAffiliationSpell() when $default != null:
return $default(_that.id,_that.spell,_that.type,_that.expiresAt,_that.affectedAt,_that.meta,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String spell,  int type,  DateTime? expiresAt,  DateTime? affectedAt,  Map<String, dynamic> meta,  String? accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAffiliationSpell():
return $default(_that.id,_that.spell,_that.type,_that.expiresAt,_that.affectedAt,_that.meta,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String spell,  int type,  DateTime? expiresAt,  DateTime? affectedAt,  Map<String, dynamic> meta,  String? accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAffiliationSpell() when $default != null:
return $default(_that.id,_that.spell,_that.type,_that.expiresAt,_that.affectedAt,_that.meta,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAffiliationSpell implements SnAffiliationSpell {
  const _SnAffiliationSpell({required this.id, required this.spell, this.type = 0, this.expiresAt, this.affectedAt, final  Map<String, dynamic> meta = const {}, this.accountId, required this.createdAt, required this.updatedAt, this.deletedAt}): _meta = meta;
  factory _SnAffiliationSpell.fromJson(Map<String, dynamic> json) => _$SnAffiliationSpellFromJson(json);

@override final  String id;
@override final  String spell;
@override@JsonKey() final  int type;
@override final  DateTime? expiresAt;
@override final  DateTime? affectedAt;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override final  String? accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAffiliationSpell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAffiliationSpellCopyWith<_SnAffiliationSpell> get copyWith => __$SnAffiliationSpellCopyWithImpl<_SnAffiliationSpell>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAffiliationSpellToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAffiliationSpell&&(identical(other.id, id) || other.id == id)&&(identical(other.spell, spell) || other.spell == spell)&&(identical(other.type, type) || other.type == type)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.affectedAt, affectedAt) || other.affectedAt == affectedAt)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,spell,type,expiresAt,affectedAt,const DeepCollectionEquality().hash(_meta),accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAffiliationSpell(id: $id, spell: $spell, type: $type, expiresAt: $expiresAt, affectedAt: $affectedAt, meta: $meta, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAffiliationSpellCopyWith<$Res> implements $SnAffiliationSpellCopyWith<$Res> {
  factory _$SnAffiliationSpellCopyWith(_SnAffiliationSpell value, $Res Function(_SnAffiliationSpell) _then) = __$SnAffiliationSpellCopyWithImpl;
@override @useResult
$Res call({
 String id, String spell, int type, DateTime? expiresAt, DateTime? affectedAt, Map<String, dynamic> meta, String? accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAffiliationSpellCopyWithImpl<$Res>
    implements _$SnAffiliationSpellCopyWith<$Res> {
  __$SnAffiliationSpellCopyWithImpl(this._self, this._then);

  final _SnAffiliationSpell _self;
  final $Res Function(_SnAffiliationSpell) _then;

/// Create a copy of SnAffiliationSpell
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spell = null,Object? type = null,Object? expiresAt = freezed,Object? affectedAt = freezed,Object? meta = null,Object? accountId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAffiliationSpell(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,spell: null == spell ? _self.spell : spell // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,affectedAt: freezed == affectedAt ? _self.affectedAt : affectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnAffiliationResult {

 String get id; String get resourceIdentifier; String get spellId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAffiliationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAffiliationResultCopyWith<SnAffiliationResult> get copyWith => _$SnAffiliationResultCopyWithImpl<SnAffiliationResult>(this as SnAffiliationResult, _$identity);

  /// Serializes this SnAffiliationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAffiliationResult&&(identical(other.id, id) || other.id == id)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.spellId, spellId) || other.spellId == spellId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resourceIdentifier,spellId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAffiliationResult(id: $id, resourceIdentifier: $resourceIdentifier, spellId: $spellId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAffiliationResultCopyWith<$Res>  {
  factory $SnAffiliationResultCopyWith(SnAffiliationResult value, $Res Function(SnAffiliationResult) _then) = _$SnAffiliationResultCopyWithImpl;
@useResult
$Res call({
 String id, String resourceIdentifier, String spellId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAffiliationResultCopyWithImpl<$Res>
    implements $SnAffiliationResultCopyWith<$Res> {
  _$SnAffiliationResultCopyWithImpl(this._self, this._then);

  final SnAffiliationResult _self;
  final $Res Function(SnAffiliationResult) _then;

/// Create a copy of SnAffiliationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? resourceIdentifier = null,Object? spellId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resourceIdentifier: null == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String,spellId: null == spellId ? _self.spellId : spellId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAffiliationResult].
extension SnAffiliationResultPatterns on SnAffiliationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAffiliationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAffiliationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAffiliationResult value)  $default,){
final _that = this;
switch (_that) {
case _SnAffiliationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAffiliationResult value)?  $default,){
final _that = this;
switch (_that) {
case _SnAffiliationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String resourceIdentifier,  String spellId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAffiliationResult() when $default != null:
return $default(_that.id,_that.resourceIdentifier,_that.spellId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String resourceIdentifier,  String spellId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAffiliationResult():
return $default(_that.id,_that.resourceIdentifier,_that.spellId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String resourceIdentifier,  String spellId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAffiliationResult() when $default != null:
return $default(_that.id,_that.resourceIdentifier,_that.spellId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAffiliationResult implements SnAffiliationResult {
  const _SnAffiliationResult({required this.id, required this.resourceIdentifier, required this.spellId, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory _SnAffiliationResult.fromJson(Map<String, dynamic> json) => _$SnAffiliationResultFromJson(json);

@override final  String id;
@override final  String resourceIdentifier;
@override final  String spellId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAffiliationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAffiliationResultCopyWith<_SnAffiliationResult> get copyWith => __$SnAffiliationResultCopyWithImpl<_SnAffiliationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAffiliationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAffiliationResult&&(identical(other.id, id) || other.id == id)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.spellId, spellId) || other.spellId == spellId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resourceIdentifier,spellId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAffiliationResult(id: $id, resourceIdentifier: $resourceIdentifier, spellId: $spellId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAffiliationResultCopyWith<$Res> implements $SnAffiliationResultCopyWith<$Res> {
  factory _$SnAffiliationResultCopyWith(_SnAffiliationResult value, $Res Function(_SnAffiliationResult) _then) = __$SnAffiliationResultCopyWithImpl;
@override @useResult
$Res call({
 String id, String resourceIdentifier, String spellId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAffiliationResultCopyWithImpl<$Res>
    implements _$SnAffiliationResultCopyWith<$Res> {
  __$SnAffiliationResultCopyWithImpl(this._self, this._then);

  final _SnAffiliationResult _self;
  final $Res Function(_SnAffiliationResult) _then;

/// Create a copy of SnAffiliationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? resourceIdentifier = null,Object? spellId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAffiliationResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resourceIdentifier: null == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String,spellId: null == spellId ? _self.spellId : spellId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
