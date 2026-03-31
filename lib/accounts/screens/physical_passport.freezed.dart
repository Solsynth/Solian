// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'physical_passport.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPhysicalPassport {

 String get id; String? get label; bool get isActive; bool get isLocked; bool get isEncrypted; DateTime? get lastSeenAt; DateTime get createdAt; String? get uid;
/// Create a copy of SnPhysicalPassport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPhysicalPassportCopyWith<SnPhysicalPassport> get copyWith => _$SnPhysicalPassportCopyWithImpl<SnPhysicalPassport>(this as SnPhysicalPassport, _$identity);

  /// Serializes this SnPhysicalPassport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPhysicalPassport&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isEncrypted, isEncrypted) || other.isEncrypted == isEncrypted)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.uid, uid) || other.uid == uid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,isActive,isLocked,isEncrypted,lastSeenAt,createdAt,uid);

@override
String toString() {
  return 'SnPhysicalPassport(id: $id, label: $label, isActive: $isActive, isLocked: $isLocked, isEncrypted: $isEncrypted, lastSeenAt: $lastSeenAt, createdAt: $createdAt, uid: $uid)';
}


}

/// @nodoc
abstract mixin class $SnPhysicalPassportCopyWith<$Res>  {
  factory $SnPhysicalPassportCopyWith(SnPhysicalPassport value, $Res Function(SnPhysicalPassport) _then) = _$SnPhysicalPassportCopyWithImpl;
@useResult
$Res call({
 String id, String? label, bool isActive, bool isLocked, bool isEncrypted, DateTime? lastSeenAt, DateTime createdAt, String? uid
});




}
/// @nodoc
class _$SnPhysicalPassportCopyWithImpl<$Res>
    implements $SnPhysicalPassportCopyWith<$Res> {
  _$SnPhysicalPassportCopyWithImpl(this._self, this._then);

  final SnPhysicalPassport _self;
  final $Res Function(SnPhysicalPassport) _then;

/// Create a copy of SnPhysicalPassport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? isActive = null,Object? isLocked = null,Object? isEncrypted = null,Object? lastSeenAt = freezed,Object? createdAt = null,Object? uid = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isEncrypted: null == isEncrypted ? _self.isEncrypted : isEncrypted // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPhysicalPassport].
extension SnPhysicalPassportPatterns on SnPhysicalPassport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPhysicalPassport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPhysicalPassport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPhysicalPassport value)  $default,){
final _that = this;
switch (_that) {
case _SnPhysicalPassport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPhysicalPassport value)?  $default,){
final _that = this;
switch (_that) {
case _SnPhysicalPassport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? label,  bool isActive,  bool isLocked,  bool isEncrypted,  DateTime? lastSeenAt,  DateTime createdAt,  String? uid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPhysicalPassport() when $default != null:
return $default(_that.id,_that.label,_that.isActive,_that.isLocked,_that.isEncrypted,_that.lastSeenAt,_that.createdAt,_that.uid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? label,  bool isActive,  bool isLocked,  bool isEncrypted,  DateTime? lastSeenAt,  DateTime createdAt,  String? uid)  $default,) {final _that = this;
switch (_that) {
case _SnPhysicalPassport():
return $default(_that.id,_that.label,_that.isActive,_that.isLocked,_that.isEncrypted,_that.lastSeenAt,_that.createdAt,_that.uid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? label,  bool isActive,  bool isLocked,  bool isEncrypted,  DateTime? lastSeenAt,  DateTime createdAt,  String? uid)?  $default,) {final _that = this;
switch (_that) {
case _SnPhysicalPassport() when $default != null:
return $default(_that.id,_that.label,_that.isActive,_that.isLocked,_that.isEncrypted,_that.lastSeenAt,_that.createdAt,_that.uid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPhysicalPassport implements SnPhysicalPassport {
  const _SnPhysicalPassport({required this.id, this.label, required this.isActive, required this.isLocked, required this.isEncrypted, this.lastSeenAt, required this.createdAt, this.uid});
  factory _SnPhysicalPassport.fromJson(Map<String, dynamic> json) => _$SnPhysicalPassportFromJson(json);

@override final  String id;
@override final  String? label;
@override final  bool isActive;
@override final  bool isLocked;
@override final  bool isEncrypted;
@override final  DateTime? lastSeenAt;
@override final  DateTime createdAt;
@override final  String? uid;

/// Create a copy of SnPhysicalPassport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPhysicalPassportCopyWith<_SnPhysicalPassport> get copyWith => __$SnPhysicalPassportCopyWithImpl<_SnPhysicalPassport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPhysicalPassportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPhysicalPassport&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isEncrypted, isEncrypted) || other.isEncrypted == isEncrypted)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.uid, uid) || other.uid == uid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,isActive,isLocked,isEncrypted,lastSeenAt,createdAt,uid);

@override
String toString() {
  return 'SnPhysicalPassport(id: $id, label: $label, isActive: $isActive, isLocked: $isLocked, isEncrypted: $isEncrypted, lastSeenAt: $lastSeenAt, createdAt: $createdAt, uid: $uid)';
}


}

/// @nodoc
abstract mixin class _$SnPhysicalPassportCopyWith<$Res> implements $SnPhysicalPassportCopyWith<$Res> {
  factory _$SnPhysicalPassportCopyWith(_SnPhysicalPassport value, $Res Function(_SnPhysicalPassport) _then) = __$SnPhysicalPassportCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, bool isActive, bool isLocked, bool isEncrypted, DateTime? lastSeenAt, DateTime createdAt, String? uid
});




}
/// @nodoc
class __$SnPhysicalPassportCopyWithImpl<$Res>
    implements _$SnPhysicalPassportCopyWith<$Res> {
  __$SnPhysicalPassportCopyWithImpl(this._self, this._then);

  final _SnPhysicalPassport _self;
  final $Res Function(_SnPhysicalPassport) _then;

/// Create a copy of SnPhysicalPassport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? isActive = null,Object? isLocked = null,Object? isEncrypted = null,Object? lastSeenAt = freezed,Object? createdAt = null,Object? uid = freezed,}) {
  return _then(_SnPhysicalPassport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isEncrypted: null == isEncrypted ? _self.isEncrypted : isEncrypted // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnScanResult {

 SnAccount get user; bool get isFriend; List<String> get actions;
/// Create a copy of SnScanResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnScanResultCopyWith<SnScanResult> get copyWith => _$SnScanResultCopyWithImpl<SnScanResult>(this as SnScanResult, _$identity);

  /// Serializes this SnScanResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnScanResult&&(identical(other.user, user) || other.user == user)&&(identical(other.isFriend, isFriend) || other.isFriend == isFriend)&&const DeepCollectionEquality().equals(other.actions, actions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,isFriend,const DeepCollectionEquality().hash(actions));

@override
String toString() {
  return 'SnScanResult(user: $user, isFriend: $isFriend, actions: $actions)';
}


}

/// @nodoc
abstract mixin class $SnScanResultCopyWith<$Res>  {
  factory $SnScanResultCopyWith(SnScanResult value, $Res Function(SnScanResult) _then) = _$SnScanResultCopyWithImpl;
@useResult
$Res call({
 SnAccount user, bool isFriend, List<String> actions
});


$SnAccountCopyWith<$Res> get user;

}
/// @nodoc
class _$SnScanResultCopyWithImpl<$Res>
    implements $SnScanResultCopyWith<$Res> {
  _$SnScanResultCopyWithImpl(this._self, this._then);

  final SnScanResult _self;
  final $Res Function(SnScanResult) _then;

/// Create a copy of SnScanResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? isFriend = null,Object? actions = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as SnAccount,isFriend: null == isFriend ? _self.isFriend : isFriend // ignore: cast_nullable_to_non_nullable
as bool,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of SnScanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get user {
  
  return $SnAccountCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnScanResult].
extension SnScanResultPatterns on SnScanResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnScanResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnScanResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnScanResult value)  $default,){
final _that = this;
switch (_that) {
case _SnScanResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnScanResult value)?  $default,){
final _that = this;
switch (_that) {
case _SnScanResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnAccount user,  bool isFriend,  List<String> actions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnScanResult() when $default != null:
return $default(_that.user,_that.isFriend,_that.actions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnAccount user,  bool isFriend,  List<String> actions)  $default,) {final _that = this;
switch (_that) {
case _SnScanResult():
return $default(_that.user,_that.isFriend,_that.actions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnAccount user,  bool isFriend,  List<String> actions)?  $default,) {final _that = this;
switch (_that) {
case _SnScanResult() when $default != null:
return $default(_that.user,_that.isFriend,_that.actions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnScanResult implements SnScanResult {
  const _SnScanResult({required this.user, this.isFriend = false, final  List<String> actions = const []}): _actions = actions;
  factory _SnScanResult.fromJson(Map<String, dynamic> json) => _$SnScanResultFromJson(json);

@override final  SnAccount user;
@override@JsonKey() final  bool isFriend;
 final  List<String> _actions;
@override@JsonKey() List<String> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}


/// Create a copy of SnScanResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnScanResultCopyWith<_SnScanResult> get copyWith => __$SnScanResultCopyWithImpl<_SnScanResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnScanResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnScanResult&&(identical(other.user, user) || other.user == user)&&(identical(other.isFriend, isFriend) || other.isFriend == isFriend)&&const DeepCollectionEquality().equals(other._actions, _actions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,isFriend,const DeepCollectionEquality().hash(_actions));

@override
String toString() {
  return 'SnScanResult(user: $user, isFriend: $isFriend, actions: $actions)';
}


}

/// @nodoc
abstract mixin class _$SnScanResultCopyWith<$Res> implements $SnScanResultCopyWith<$Res> {
  factory _$SnScanResultCopyWith(_SnScanResult value, $Res Function(_SnScanResult) _then) = __$SnScanResultCopyWithImpl;
@override @useResult
$Res call({
 SnAccount user, bool isFriend, List<String> actions
});


@override $SnAccountCopyWith<$Res> get user;

}
/// @nodoc
class __$SnScanResultCopyWithImpl<$Res>
    implements _$SnScanResultCopyWith<$Res> {
  __$SnScanResultCopyWithImpl(this._self, this._then);

  final _SnScanResult _self;
  final $Res Function(_SnScanResult) _then;

/// Create a copy of SnScanResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? isFriend = null,Object? actions = null,}) {
  return _then(_SnScanResult(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as SnAccount,isFriend: null == isFriend ? _self.isFriend : isFriend // ignore: cast_nullable_to_non_nullable
as bool,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of SnScanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get user {
  
  return $SnAccountCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
