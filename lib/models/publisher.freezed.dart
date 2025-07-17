// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publisher.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPublisher {

 String get id; int get type; String get name; String get nick; String get bio; SnCloudFile? get picture; SnCloudFile? get background; SnAccount? get account; String? get accountId; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt; String? get realmId; SnVerificationMark? get verification;
/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<SnPublisher> get copyWith => _$SnPublisherCopyWithImpl<SnPublisher>(this as SnPublisher, _$identity);

  /// Serializes this SnPublisher to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisher&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.account, account) || other.account == account)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.verification, verification) || other.verification == verification));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,nick,bio,picture,background,account,accountId,createdAt,updatedAt,deletedAt,realmId,verification);

@override
String toString() {
  return 'SnPublisher(id: $id, type: $type, name: $name, nick: $nick, bio: $bio, picture: $picture, background: $background, account: $account, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, realmId: $realmId, verification: $verification)';
}


}

/// @nodoc
abstract mixin class $SnPublisherCopyWith<$Res>  {
  factory $SnPublisherCopyWith(SnPublisher value, $Res Function(SnPublisher) _then) = _$SnPublisherCopyWithImpl;
@useResult
$Res call({
 String id, int type, String name, String nick, String bio, SnCloudFile? picture, SnCloudFile? background, SnAccount? account, String? accountId, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String? realmId, SnVerificationMark? verification
});


$SnCloudFileCopyWith<$Res>? get picture;$SnCloudFileCopyWith<$Res>? get background;$SnAccountCopyWith<$Res>? get account;$SnVerificationMarkCopyWith<$Res>? get verification;

}
/// @nodoc
class _$SnPublisherCopyWithImpl<$Res>
    implements $SnPublisherCopyWith<$Res> {
  _$SnPublisherCopyWithImpl(this._self, this._then);

  final SnPublisher _self;
  final $Res Function(SnPublisher) _then;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? nick = null,Object? bio = null,Object? picture = freezed,Object? background = freezed,Object? account = freezed,Object? accountId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? realmId = freezed,Object? verification = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,
  ));
}
/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnPublisher
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
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisher].
extension SnPublisherPatterns on SnPublisher {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisher value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisher value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisher():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisher value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int type,  String name,  String nick,  String bio,  SnCloudFile? picture,  SnCloudFile? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnVerificationMark? verification)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.verification);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int type,  String name,  String nick,  String bio,  SnCloudFile? picture,  SnCloudFile? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnVerificationMark? verification)  $default,) {final _that = this;
switch (_that) {
case _SnPublisher():
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.verification);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int type,  String name,  String nick,  String bio,  SnCloudFile? picture,  SnCloudFile? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnVerificationMark? verification)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.verification);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisher implements SnPublisher {
  const _SnPublisher({this.id = '', this.type = 0, this.name = '', this.nick = '', this.bio = '', this.picture, this.background, this.account, this.accountId, this.createdAt = null, this.updatedAt = null, this.deletedAt, this.realmId, this.verification});
  factory _SnPublisher.fromJson(Map<String, dynamic> json) => _$SnPublisherFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  int type;
@override@JsonKey() final  String name;
@override@JsonKey() final  String nick;
@override@JsonKey() final  String bio;
@override final  SnCloudFile? picture;
@override final  SnCloudFile? background;
@override final  SnAccount? account;
@override final  String? accountId;
@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey() final  DateTime? updatedAt;
@override final  DateTime? deletedAt;
@override final  String? realmId;
@override final  SnVerificationMark? verification;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherCopyWith<_SnPublisher> get copyWith => __$SnPublisherCopyWithImpl<_SnPublisher>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisher&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.account, account) || other.account == account)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.verification, verification) || other.verification == verification));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,nick,bio,picture,background,account,accountId,createdAt,updatedAt,deletedAt,realmId,verification);

@override
String toString() {
  return 'SnPublisher(id: $id, type: $type, name: $name, nick: $nick, bio: $bio, picture: $picture, background: $background, account: $account, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, realmId: $realmId, verification: $verification)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherCopyWith<$Res> implements $SnPublisherCopyWith<$Res> {
  factory _$SnPublisherCopyWith(_SnPublisher value, $Res Function(_SnPublisher) _then) = __$SnPublisherCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, String name, String nick, String bio, SnCloudFile? picture, SnCloudFile? background, SnAccount? account, String? accountId, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String? realmId, SnVerificationMark? verification
});


@override $SnCloudFileCopyWith<$Res>? get picture;@override $SnCloudFileCopyWith<$Res>? get background;@override $SnAccountCopyWith<$Res>? get account;@override $SnVerificationMarkCopyWith<$Res>? get verification;

}
/// @nodoc
class __$SnPublisherCopyWithImpl<$Res>
    implements _$SnPublisherCopyWith<$Res> {
  __$SnPublisherCopyWithImpl(this._self, this._then);

  final _SnPublisher _self;
  final $Res Function(_SnPublisher) _then;

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? nick = null,Object? bio = null,Object? picture = freezed,Object? background = freezed,Object? account = freezed,Object? accountId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? realmId = freezed,Object? verification = freezed,}) {
  return _then(_SnPublisher(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,
  ));
}

/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnPublisher
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
}/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}
}


/// @nodoc
mixin _$SnPublisherMember {

 String get publisherId; SnPublisher? get publisher; String get accountId; SnAccount? get account; int get role; DateTime? get joinedAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherMemberCopyWith<SnPublisherMember> get copyWith => _$SnPublisherMemberCopyWithImpl<SnPublisherMember>(this as SnPublisherMember, _$identity);

  /// Serializes this SnPublisherMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherMember&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publisherId,publisher,accountId,account,role,joinedAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPublisherMember(publisherId: $publisherId, publisher: $publisher, accountId: $accountId, account: $account, role: $role, joinedAt: $joinedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPublisherMemberCopyWith<$Res>  {
  factory $SnPublisherMemberCopyWith(SnPublisherMember value, $Res Function(SnPublisherMember) _then) = _$SnPublisherMemberCopyWithImpl;
@useResult
$Res call({
 String publisherId, SnPublisher? publisher, String accountId, SnAccount? account, int role, DateTime? joinedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnPublisherCopyWith<$Res>? get publisher;$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnPublisherMemberCopyWithImpl<$Res>
    implements $SnPublisherMemberCopyWith<$Res> {
  _$SnPublisherMemberCopyWithImpl(this._self, this._then);

  final SnPublisherMember _self;
  final $Res Function(SnPublisherMember) _then;

/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publisherId = null,Object? publisher = freezed,Object? accountId = null,Object? account = freezed,Object? role = null,Object? joinedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPublisherMember
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


/// Adds pattern-matching-related methods to [SnPublisherMember].
extension SnPublisherMemberPatterns on SnPublisherMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherMember value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherMember value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String publisherId,  SnPublisher? publisher,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherMember() when $default != null:
return $default(_that.publisherId,_that.publisher,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String publisherId,  SnPublisher? publisher,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherMember():
return $default(_that.publisherId,_that.publisher,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String publisherId,  SnPublisher? publisher,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherMember() when $default != null:
return $default(_that.publisherId,_that.publisher,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherMember implements SnPublisherMember {
  const _SnPublisherMember({required this.publisherId, required this.publisher, required this.accountId, required this.account, required this.role, required this.joinedAt, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnPublisherMember.fromJson(Map<String, dynamic> json) => _$SnPublisherMemberFromJson(json);

@override final  String publisherId;
@override final  SnPublisher? publisher;
@override final  String accountId;
@override final  SnAccount? account;
@override final  int role;
@override final  DateTime? joinedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherMemberCopyWith<_SnPublisherMember> get copyWith => __$SnPublisherMemberCopyWithImpl<_SnPublisherMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherMember&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publisherId,publisher,accountId,account,role,joinedAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPublisherMember(publisherId: $publisherId, publisher: $publisher, accountId: $accountId, account: $account, role: $role, joinedAt: $joinedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherMemberCopyWith<$Res> implements $SnPublisherMemberCopyWith<$Res> {
  factory _$SnPublisherMemberCopyWith(_SnPublisherMember value, $Res Function(_SnPublisherMember) _then) = __$SnPublisherMemberCopyWithImpl;
@override @useResult
$Res call({
 String publisherId, SnPublisher? publisher, String accountId, SnAccount? account, int role, DateTime? joinedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnPublisherCopyWith<$Res>? get publisher;@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnPublisherMemberCopyWithImpl<$Res>
    implements _$SnPublisherMemberCopyWith<$Res> {
  __$SnPublisherMemberCopyWithImpl(this._self, this._then);

  final _SnPublisherMember _self;
  final $Res Function(_SnPublisherMember) _then;

/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publisherId = null,Object? publisher = freezed,Object? accountId = null,Object? account = freezed,Object? role = null,Object? joinedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPublisherMember(
publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPublisherMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPublisherMember
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
