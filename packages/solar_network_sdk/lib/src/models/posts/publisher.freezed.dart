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

 String get id; int get type; String get name; String get nick; String get bio; SnCloudFile? get picture; SnCloudFile? get background; SnAccount? get account; String? get accountId; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt; String? get realmId; SnVerificationMark? get verification; bool get followRequiresApproval; bool get postsRequireFollow;
/// Create a copy of SnPublisher
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<SnPublisher> get copyWith => _$SnPublisherCopyWithImpl<SnPublisher>(this as SnPublisher, _$identity);

  /// Serializes this SnPublisher to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisher&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.account, account) || other.account == account)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.followRequiresApproval, followRequiresApproval) || other.followRequiresApproval == followRequiresApproval)&&(identical(other.postsRequireFollow, postsRequireFollow) || other.postsRequireFollow == postsRequireFollow));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,nick,bio,picture,background,account,accountId,createdAt,updatedAt,deletedAt,realmId,verification,followRequiresApproval,postsRequireFollow);

@override
String toString() {
  return 'SnPublisher(id: $id, type: $type, name: $name, nick: $nick, bio: $bio, picture: $picture, background: $background, account: $account, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, realmId: $realmId, verification: $verification, followRequiresApproval: $followRequiresApproval, postsRequireFollow: $postsRequireFollow)';
}


}

/// @nodoc
abstract mixin class $SnPublisherCopyWith<$Res>  {
  factory $SnPublisherCopyWith(SnPublisher value, $Res Function(SnPublisher) _then) = _$SnPublisherCopyWithImpl;
@useResult
$Res call({
 String id, int type, String name, String nick, String bio, SnCloudFile? picture, SnCloudFile? background, SnAccount? account, String? accountId, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String? realmId, SnVerificationMark? verification, bool followRequiresApproval, bool postsRequireFollow
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? nick = null,Object? bio = null,Object? picture = freezed,Object? background = freezed,Object? account = freezed,Object? accountId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? realmId = freezed,Object? verification = freezed,Object? followRequiresApproval = null,Object? postsRequireFollow = null,}) {
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
as SnVerificationMark?,followRequiresApproval: null == followRequiresApproval ? _self.followRequiresApproval : followRequiresApproval // ignore: cast_nullable_to_non_nullable
as bool,postsRequireFollow: null == postsRequireFollow ? _self.postsRequireFollow : postsRequireFollow // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int type,  String name,  String nick,  String bio,  SnCloudFile? picture,  SnCloudFile? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnVerificationMark? verification,  bool followRequiresApproval,  bool postsRequireFollow)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.verification,_that.followRequiresApproval,_that.postsRequireFollow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int type,  String name,  String nick,  String bio,  SnCloudFile? picture,  SnCloudFile? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnVerificationMark? verification,  bool followRequiresApproval,  bool postsRequireFollow)  $default,) {final _that = this;
switch (_that) {
case _SnPublisher():
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.verification,_that.followRequiresApproval,_that.postsRequireFollow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int type,  String name,  String nick,  String bio,  SnCloudFile? picture,  SnCloudFile? background,  SnAccount? account,  String? accountId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? realmId,  SnVerificationMark? verification,  bool followRequiresApproval,  bool postsRequireFollow)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisher() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.nick,_that.bio,_that.picture,_that.background,_that.account,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.realmId,_that.verification,_that.followRequiresApproval,_that.postsRequireFollow);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisher implements SnPublisher {
  const _SnPublisher({this.id = '', this.type = 0, this.name = '', this.nick = '', this.bio = '', this.picture, this.background, this.account, this.accountId, this.createdAt = null, this.updatedAt = null, this.deletedAt, this.realmId, this.verification, this.followRequiresApproval = false, this.postsRequireFollow = false});
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
@override@JsonKey() final  bool followRequiresApproval;
@override@JsonKey() final  bool postsRequireFollow;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisher&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.account, account) || other.account == account)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.followRequiresApproval, followRequiresApproval) || other.followRequiresApproval == followRequiresApproval)&&(identical(other.postsRequireFollow, postsRequireFollow) || other.postsRequireFollow == postsRequireFollow));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,nick,bio,picture,background,account,accountId,createdAt,updatedAt,deletedAt,realmId,verification,followRequiresApproval,postsRequireFollow);

@override
String toString() {
  return 'SnPublisher(id: $id, type: $type, name: $name, nick: $nick, bio: $bio, picture: $picture, background: $background, account: $account, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, realmId: $realmId, verification: $verification, followRequiresApproval: $followRequiresApproval, postsRequireFollow: $postsRequireFollow)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherCopyWith<$Res> implements $SnPublisherCopyWith<$Res> {
  factory _$SnPublisherCopyWith(_SnPublisher value, $Res Function(_SnPublisher) _then) = __$SnPublisherCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, String name, String nick, String bio, SnCloudFile? picture, SnCloudFile? background, SnAccount? account, String? accountId, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String? realmId, SnVerificationMark? verification, bool followRequiresApproval, bool postsRequireFollow
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? nick = null,Object? bio = null,Object? picture = freezed,Object? background = freezed,Object? account = freezed,Object? accountId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? realmId = freezed,Object? verification = freezed,Object? followRequiresApproval = null,Object? postsRequireFollow = null,}) {
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
as SnVerificationMark?,followRequiresApproval: null == followRequiresApproval ? _self.followRequiresApproval : followRequiresApproval // ignore: cast_nullable_to_non_nullable
as bool,postsRequireFollow: null == postsRequireFollow ? _self.postsRequireFollow : postsRequireFollow // ignore: cast_nullable_to_non_nullable
as bool,
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


/// @nodoc
mixin _$SnPublisherFollowRequest {

 String get id; String get publisherId; String get accountId; FollowRequestState get state; String? get rejectReason; DateTime get createdAt; DateTime? get reviewedAt; String? get reviewedByAccountId; SnAccount? get account;
/// Create a copy of SnPublisherFollowRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherFollowRequestCopyWith<SnPublisherFollowRequest> get copyWith => _$SnPublisherFollowRequestCopyWithImpl<SnPublisherFollowRequest>(this as SnPublisherFollowRequest, _$identity);

  /// Serializes this SnPublisherFollowRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherFollowRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.state, state) || other.state == state)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedByAccountId, reviewedByAccountId) || other.reviewedByAccountId == reviewedByAccountId)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publisherId,accountId,state,rejectReason,createdAt,reviewedAt,reviewedByAccountId,account);

@override
String toString() {
  return 'SnPublisherFollowRequest(id: $id, publisherId: $publisherId, accountId: $accountId, state: $state, rejectReason: $rejectReason, createdAt: $createdAt, reviewedAt: $reviewedAt, reviewedByAccountId: $reviewedByAccountId, account: $account)';
}


}

/// @nodoc
abstract mixin class $SnPublisherFollowRequestCopyWith<$Res>  {
  factory $SnPublisherFollowRequestCopyWith(SnPublisherFollowRequest value, $Res Function(SnPublisherFollowRequest) _then) = _$SnPublisherFollowRequestCopyWithImpl;
@useResult
$Res call({
 String id, String publisherId, String accountId, FollowRequestState state, String? rejectReason, DateTime createdAt, DateTime? reviewedAt, String? reviewedByAccountId, SnAccount? account
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnPublisherFollowRequestCopyWithImpl<$Res>
    implements $SnPublisherFollowRequestCopyWith<$Res> {
  _$SnPublisherFollowRequestCopyWithImpl(this._self, this._then);

  final SnPublisherFollowRequest _self;
  final $Res Function(SnPublisherFollowRequest) _then;

/// Create a copy of SnPublisherFollowRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publisherId = null,Object? accountId = null,Object? state = null,Object? rejectReason = freezed,Object? createdAt = null,Object? reviewedAt = freezed,Object? reviewedByAccountId = freezed,Object? account = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FollowRequestState,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByAccountId: freezed == reviewedByAccountId ? _self.reviewedByAccountId : reviewedByAccountId // ignore: cast_nullable_to_non_nullable
as String?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}
/// Create a copy of SnPublisherFollowRequest
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


/// Adds pattern-matching-related methods to [SnPublisherFollowRequest].
extension SnPublisherFollowRequestPatterns on SnPublisherFollowRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherFollowRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherFollowRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherFollowRequest value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherFollowRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherFollowRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherFollowRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String publisherId,  String accountId,  FollowRequestState state,  String? rejectReason,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByAccountId,  SnAccount? account)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherFollowRequest() when $default != null:
return $default(_that.id,_that.publisherId,_that.accountId,_that.state,_that.rejectReason,_that.createdAt,_that.reviewedAt,_that.reviewedByAccountId,_that.account);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String publisherId,  String accountId,  FollowRequestState state,  String? rejectReason,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByAccountId,  SnAccount? account)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherFollowRequest():
return $default(_that.id,_that.publisherId,_that.accountId,_that.state,_that.rejectReason,_that.createdAt,_that.reviewedAt,_that.reviewedByAccountId,_that.account);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String publisherId,  String accountId,  FollowRequestState state,  String? rejectReason,  DateTime createdAt,  DateTime? reviewedAt,  String? reviewedByAccountId,  SnAccount? account)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherFollowRequest() when $default != null:
return $default(_that.id,_that.publisherId,_that.accountId,_that.state,_that.rejectReason,_that.createdAt,_that.reviewedAt,_that.reviewedByAccountId,_that.account);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherFollowRequest implements SnPublisherFollowRequest {
  const _SnPublisherFollowRequest({required this.id, required this.publisherId, required this.accountId, required this.state, this.rejectReason, required this.createdAt, this.reviewedAt, this.reviewedByAccountId, this.account});
  factory _SnPublisherFollowRequest.fromJson(Map<String, dynamic> json) => _$SnPublisherFollowRequestFromJson(json);

@override final  String id;
@override final  String publisherId;
@override final  String accountId;
@override final  FollowRequestState state;
@override final  String? rejectReason;
@override final  DateTime createdAt;
@override final  DateTime? reviewedAt;
@override final  String? reviewedByAccountId;
@override final  SnAccount? account;

/// Create a copy of SnPublisherFollowRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherFollowRequestCopyWith<_SnPublisherFollowRequest> get copyWith => __$SnPublisherFollowRequestCopyWithImpl<_SnPublisherFollowRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherFollowRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherFollowRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.state, state) || other.state == state)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedByAccountId, reviewedByAccountId) || other.reviewedByAccountId == reviewedByAccountId)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publisherId,accountId,state,rejectReason,createdAt,reviewedAt,reviewedByAccountId,account);

@override
String toString() {
  return 'SnPublisherFollowRequest(id: $id, publisherId: $publisherId, accountId: $accountId, state: $state, rejectReason: $rejectReason, createdAt: $createdAt, reviewedAt: $reviewedAt, reviewedByAccountId: $reviewedByAccountId, account: $account)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherFollowRequestCopyWith<$Res> implements $SnPublisherFollowRequestCopyWith<$Res> {
  factory _$SnPublisherFollowRequestCopyWith(_SnPublisherFollowRequest value, $Res Function(_SnPublisherFollowRequest) _then) = __$SnPublisherFollowRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String publisherId, String accountId, FollowRequestState state, String? rejectReason, DateTime createdAt, DateTime? reviewedAt, String? reviewedByAccountId, SnAccount? account
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnPublisherFollowRequestCopyWithImpl<$Res>
    implements _$SnPublisherFollowRequestCopyWith<$Res> {
  __$SnPublisherFollowRequestCopyWithImpl(this._self, this._then);

  final _SnPublisherFollowRequest _self;
  final $Res Function(_SnPublisherFollowRequest) _then;

/// Create a copy of SnPublisherFollowRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publisherId = null,Object? accountId = null,Object? state = null,Object? rejectReason = freezed,Object? createdAt = null,Object? reviewedAt = freezed,Object? reviewedByAccountId = freezed,Object? account = freezed,}) {
  return _then(_SnPublisherFollowRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FollowRequestState,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedByAccountId: freezed == reviewedByAccountId ? _self.reviewedByAccountId : reviewedByAccountId // ignore: cast_nullable_to_non_nullable
as String?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}

/// Create a copy of SnPublisherFollowRequest
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
mixin _$SnPublisherFollowResponse {

 String? get requestId; FollowRequestState? get state; String? get message;
/// Create a copy of SnPublisherFollowResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherFollowResponseCopyWith<SnPublisherFollowResponse> get copyWith => _$SnPublisherFollowResponseCopyWithImpl<SnPublisherFollowResponse>(this as SnPublisherFollowResponse, _$identity);

  /// Serializes this SnPublisherFollowResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherFollowResponse&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId,state,message);

@override
String toString() {
  return 'SnPublisherFollowResponse(requestId: $requestId, state: $state, message: $message)';
}


}

/// @nodoc
abstract mixin class $SnPublisherFollowResponseCopyWith<$Res>  {
  factory $SnPublisherFollowResponseCopyWith(SnPublisherFollowResponse value, $Res Function(SnPublisherFollowResponse) _then) = _$SnPublisherFollowResponseCopyWithImpl;
@useResult
$Res call({
 String? requestId, FollowRequestState? state, String? message
});




}
/// @nodoc
class _$SnPublisherFollowResponseCopyWithImpl<$Res>
    implements $SnPublisherFollowResponseCopyWith<$Res> {
  _$SnPublisherFollowResponseCopyWithImpl(this._self, this._then);

  final SnPublisherFollowResponse _self;
  final $Res Function(SnPublisherFollowResponse) _then;

/// Create a copy of SnPublisherFollowResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = freezed,Object? state = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FollowRequestState?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublisherFollowResponse].
extension SnPublisherFollowResponsePatterns on SnPublisherFollowResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherFollowResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherFollowResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherFollowResponse value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherFollowResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherFollowResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherFollowResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? requestId,  FollowRequestState? state,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherFollowResponse() when $default != null:
return $default(_that.requestId,_that.state,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? requestId,  FollowRequestState? state,  String? message)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherFollowResponse():
return $default(_that.requestId,_that.state,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? requestId,  FollowRequestState? state,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherFollowResponse() when $default != null:
return $default(_that.requestId,_that.state,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherFollowResponse implements SnPublisherFollowResponse {
  const _SnPublisherFollowResponse({this.requestId, this.state, this.message});
  factory _SnPublisherFollowResponse.fromJson(Map<String, dynamic> json) => _$SnPublisherFollowResponseFromJson(json);

@override final  String? requestId;
@override final  FollowRequestState? state;
@override final  String? message;

/// Create a copy of SnPublisherFollowResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherFollowResponseCopyWith<_SnPublisherFollowResponse> get copyWith => __$SnPublisherFollowResponseCopyWithImpl<_SnPublisherFollowResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherFollowResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherFollowResponse&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.state, state) || other.state == state)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestId,state,message);

@override
String toString() {
  return 'SnPublisherFollowResponse(requestId: $requestId, state: $state, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherFollowResponseCopyWith<$Res> implements $SnPublisherFollowResponseCopyWith<$Res> {
  factory _$SnPublisherFollowResponseCopyWith(_SnPublisherFollowResponse value, $Res Function(_SnPublisherFollowResponse) _then) = __$SnPublisherFollowResponseCopyWithImpl;
@override @useResult
$Res call({
 String? requestId, FollowRequestState? state, String? message
});




}
/// @nodoc
class __$SnPublisherFollowResponseCopyWithImpl<$Res>
    implements _$SnPublisherFollowResponseCopyWith<$Res> {
  __$SnPublisherFollowResponseCopyWithImpl(this._self, this._then);

  final _SnPublisherFollowResponse _self;
  final $Res Function(_SnPublisherFollowResponse) _then;

/// Create a copy of SnPublisherFollowResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = freezed,Object? state = freezed,Object? message = freezed,}) {
  return _then(_SnPublisherFollowResponse(
requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FollowRequestState?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnPublisherFollowRequestListResponse {

 List<SnPublisherFollowRequest> get requests;
/// Create a copy of SnPublisherFollowRequestListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherFollowRequestListResponseCopyWith<SnPublisherFollowRequestListResponse> get copyWith => _$SnPublisherFollowRequestListResponseCopyWithImpl<SnPublisherFollowRequestListResponse>(this as SnPublisherFollowRequestListResponse, _$identity);

  /// Serializes this SnPublisherFollowRequestListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherFollowRequestListResponse&&const DeepCollectionEquality().equals(other.requests, requests));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(requests));

@override
String toString() {
  return 'SnPublisherFollowRequestListResponse(requests: $requests)';
}


}

/// @nodoc
abstract mixin class $SnPublisherFollowRequestListResponseCopyWith<$Res>  {
  factory $SnPublisherFollowRequestListResponseCopyWith(SnPublisherFollowRequestListResponse value, $Res Function(SnPublisherFollowRequestListResponse) _then) = _$SnPublisherFollowRequestListResponseCopyWithImpl;
@useResult
$Res call({
 List<SnPublisherFollowRequest> requests
});




}
/// @nodoc
class _$SnPublisherFollowRequestListResponseCopyWithImpl<$Res>
    implements $SnPublisherFollowRequestListResponseCopyWith<$Res> {
  _$SnPublisherFollowRequestListResponseCopyWithImpl(this._self, this._then);

  final SnPublisherFollowRequestListResponse _self;
  final $Res Function(SnPublisherFollowRequestListResponse) _then;

/// Create a copy of SnPublisherFollowRequestListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requests = null,}) {
  return _then(_self.copyWith(
requests: null == requests ? _self.requests : requests // ignore: cast_nullable_to_non_nullable
as List<SnPublisherFollowRequest>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublisherFollowRequestListResponse].
extension SnPublisherFollowRequestListResponsePatterns on SnPublisherFollowRequestListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherFollowRequestListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherFollowRequestListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherFollowRequestListResponse value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherFollowRequestListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherFollowRequestListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherFollowRequestListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SnPublisherFollowRequest> requests)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherFollowRequestListResponse() when $default != null:
return $default(_that.requests);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SnPublisherFollowRequest> requests)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherFollowRequestListResponse():
return $default(_that.requests);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SnPublisherFollowRequest> requests)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherFollowRequestListResponse() when $default != null:
return $default(_that.requests);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherFollowRequestListResponse implements SnPublisherFollowRequestListResponse {
  const _SnPublisherFollowRequestListResponse({required final  List<SnPublisherFollowRequest> requests}): _requests = requests;
  factory _SnPublisherFollowRequestListResponse.fromJson(Map<String, dynamic> json) => _$SnPublisherFollowRequestListResponseFromJson(json);

 final  List<SnPublisherFollowRequest> _requests;
@override List<SnPublisherFollowRequest> get requests {
  if (_requests is EqualUnmodifiableListView) return _requests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requests);
}


/// Create a copy of SnPublisherFollowRequestListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherFollowRequestListResponseCopyWith<_SnPublisherFollowRequestListResponse> get copyWith => __$SnPublisherFollowRequestListResponseCopyWithImpl<_SnPublisherFollowRequestListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherFollowRequestListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherFollowRequestListResponse&&const DeepCollectionEquality().equals(other._requests, _requests));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_requests));

@override
String toString() {
  return 'SnPublisherFollowRequestListResponse(requests: $requests)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherFollowRequestListResponseCopyWith<$Res> implements $SnPublisherFollowRequestListResponseCopyWith<$Res> {
  factory _$SnPublisherFollowRequestListResponseCopyWith(_SnPublisherFollowRequestListResponse value, $Res Function(_SnPublisherFollowRequestListResponse) _then) = __$SnPublisherFollowRequestListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SnPublisherFollowRequest> requests
});




}
/// @nodoc
class __$SnPublisherFollowRequestListResponseCopyWithImpl<$Res>
    implements _$SnPublisherFollowRequestListResponseCopyWith<$Res> {
  __$SnPublisherFollowRequestListResponseCopyWithImpl(this._self, this._then);

  final _SnPublisherFollowRequestListResponse _self;
  final $Res Function(_SnPublisherFollowRequestListResponse) _then;

/// Create a copy of SnPublisherFollowRequestListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requests = null,}) {
  return _then(_SnPublisherFollowRequestListResponse(
requests: null == requests ? _self._requests : requests // ignore: cast_nullable_to_non_nullable
as List<SnPublisherFollowRequest>,
  ));
}


}


/// @nodoc
mixin _$SnPublisherFollowStatus {

 bool get isSubscribed; FollowRequestState? get followRequestState; String? get followRequestId;
/// Create a copy of SnPublisherFollowStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherFollowStatusCopyWith<SnPublisherFollowStatus> get copyWith => _$SnPublisherFollowStatusCopyWithImpl<SnPublisherFollowStatus>(this as SnPublisherFollowStatus, _$identity);

  /// Serializes this SnPublisherFollowStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherFollowStatus&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&(identical(other.followRequestState, followRequestState) || other.followRequestState == followRequestState)&&(identical(other.followRequestId, followRequestId) || other.followRequestId == followRequestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isSubscribed,followRequestState,followRequestId);

@override
String toString() {
  return 'SnPublisherFollowStatus(isSubscribed: $isSubscribed, followRequestState: $followRequestState, followRequestId: $followRequestId)';
}


}

/// @nodoc
abstract mixin class $SnPublisherFollowStatusCopyWith<$Res>  {
  factory $SnPublisherFollowStatusCopyWith(SnPublisherFollowStatus value, $Res Function(SnPublisherFollowStatus) _then) = _$SnPublisherFollowStatusCopyWithImpl;
@useResult
$Res call({
 bool isSubscribed, FollowRequestState? followRequestState, String? followRequestId
});




}
/// @nodoc
class _$SnPublisherFollowStatusCopyWithImpl<$Res>
    implements $SnPublisherFollowStatusCopyWith<$Res> {
  _$SnPublisherFollowStatusCopyWithImpl(this._self, this._then);

  final SnPublisherFollowStatus _self;
  final $Res Function(SnPublisherFollowStatus) _then;

/// Create a copy of SnPublisherFollowStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSubscribed = null,Object? followRequestState = freezed,Object? followRequestId = freezed,}) {
  return _then(_self.copyWith(
isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,followRequestState: freezed == followRequestState ? _self.followRequestState : followRequestState // ignore: cast_nullable_to_non_nullable
as FollowRequestState?,followRequestId: freezed == followRequestId ? _self.followRequestId : followRequestId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublisherFollowStatus].
extension SnPublisherFollowStatusPatterns on SnPublisherFollowStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherFollowStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherFollowStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherFollowStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherFollowStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherFollowStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherFollowStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSubscribed,  FollowRequestState? followRequestState,  String? followRequestId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherFollowStatus() when $default != null:
return $default(_that.isSubscribed,_that.followRequestState,_that.followRequestId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSubscribed,  FollowRequestState? followRequestState,  String? followRequestId)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherFollowStatus():
return $default(_that.isSubscribed,_that.followRequestState,_that.followRequestId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSubscribed,  FollowRequestState? followRequestState,  String? followRequestId)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherFollowStatus() when $default != null:
return $default(_that.isSubscribed,_that.followRequestState,_that.followRequestId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherFollowStatus implements SnPublisherFollowStatus {
  const _SnPublisherFollowStatus({this.isSubscribed = false, this.followRequestState, this.followRequestId});
  factory _SnPublisherFollowStatus.fromJson(Map<String, dynamic> json) => _$SnPublisherFollowStatusFromJson(json);

@override@JsonKey() final  bool isSubscribed;
@override final  FollowRequestState? followRequestState;
@override final  String? followRequestId;

/// Create a copy of SnPublisherFollowStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherFollowStatusCopyWith<_SnPublisherFollowStatus> get copyWith => __$SnPublisherFollowStatusCopyWithImpl<_SnPublisherFollowStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherFollowStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherFollowStatus&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&(identical(other.followRequestState, followRequestState) || other.followRequestState == followRequestState)&&(identical(other.followRequestId, followRequestId) || other.followRequestId == followRequestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isSubscribed,followRequestState,followRequestId);

@override
String toString() {
  return 'SnPublisherFollowStatus(isSubscribed: $isSubscribed, followRequestState: $followRequestState, followRequestId: $followRequestId)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherFollowStatusCopyWith<$Res> implements $SnPublisherFollowStatusCopyWith<$Res> {
  factory _$SnPublisherFollowStatusCopyWith(_SnPublisherFollowStatus value, $Res Function(_SnPublisherFollowStatus) _then) = __$SnPublisherFollowStatusCopyWithImpl;
@override @useResult
$Res call({
 bool isSubscribed, FollowRequestState? followRequestState, String? followRequestId
});




}
/// @nodoc
class __$SnPublisherFollowStatusCopyWithImpl<$Res>
    implements _$SnPublisherFollowStatusCopyWith<$Res> {
  __$SnPublisherFollowStatusCopyWithImpl(this._self, this._then);

  final _SnPublisherFollowStatus _self;
  final $Res Function(_SnPublisherFollowStatus) _then;

/// Create a copy of SnPublisherFollowStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSubscribed = null,Object? followRequestState = freezed,Object? followRequestId = freezed,}) {
  return _then(_SnPublisherFollowStatus(
isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,followRequestState: freezed == followRequestState ? _self.followRequestState : followRequestState // ignore: cast_nullable_to_non_nullable
as FollowRequestState?,followRequestId: freezed == followRequestId ? _self.followRequestId : followRequestId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnPublisherSubscriptionStatus {

 SnPublisherFollowStatus? get subscription; SnPublisherFollowRequest? get followRequest; bool get requiresApproval; String get status; String get message;
/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherSubscriptionStatusCopyWith<SnPublisherSubscriptionStatus> get copyWith => _$SnPublisherSubscriptionStatusCopyWithImpl<SnPublisherSubscriptionStatus>(this as SnPublisherSubscriptionStatus, _$identity);

  /// Serializes this SnPublisherSubscriptionStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherSubscriptionStatus&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.followRequest, followRequest) || other.followRequest == followRequest)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subscription,followRequest,requiresApproval,status,message);

@override
String toString() {
  return 'SnPublisherSubscriptionStatus(subscription: $subscription, followRequest: $followRequest, requiresApproval: $requiresApproval, status: $status, message: $message)';
}


}

/// @nodoc
abstract mixin class $SnPublisherSubscriptionStatusCopyWith<$Res>  {
  factory $SnPublisherSubscriptionStatusCopyWith(SnPublisherSubscriptionStatus value, $Res Function(SnPublisherSubscriptionStatus) _then) = _$SnPublisherSubscriptionStatusCopyWithImpl;
@useResult
$Res call({
 SnPublisherFollowStatus? subscription, SnPublisherFollowRequest? followRequest, bool requiresApproval, String status, String message
});


$SnPublisherFollowStatusCopyWith<$Res>? get subscription;$SnPublisherFollowRequestCopyWith<$Res>? get followRequest;

}
/// @nodoc
class _$SnPublisherSubscriptionStatusCopyWithImpl<$Res>
    implements $SnPublisherSubscriptionStatusCopyWith<$Res> {
  _$SnPublisherSubscriptionStatusCopyWithImpl(this._self, this._then);

  final SnPublisherSubscriptionStatus _self;
  final $Res Function(SnPublisherSubscriptionStatus) _then;

/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscription = freezed,Object? followRequest = freezed,Object? requiresApproval = null,Object? status = null,Object? message = null,}) {
  return _then(_self.copyWith(
subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherFollowStatus?,followRequest: freezed == followRequest ? _self.followRequest : followRequest // ignore: cast_nullable_to_non_nullable
as SnPublisherFollowRequest?,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherFollowStatusCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SnPublisherFollowStatusCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherFollowRequestCopyWith<$Res>? get followRequest {
    if (_self.followRequest == null) {
    return null;
  }

  return $SnPublisherFollowRequestCopyWith<$Res>(_self.followRequest!, (value) {
    return _then(_self.copyWith(followRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPublisherSubscriptionStatus].
extension SnPublisherSubscriptionStatusPatterns on SnPublisherSubscriptionStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherSubscriptionStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherSubscriptionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnPublisherFollowStatus? subscription,  SnPublisherFollowRequest? followRequest,  bool requiresApproval,  String status,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus() when $default != null:
return $default(_that.subscription,_that.followRequest,_that.requiresApproval,_that.status,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnPublisherFollowStatus? subscription,  SnPublisherFollowRequest? followRequest,  bool requiresApproval,  String status,  String message)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus():
return $default(_that.subscription,_that.followRequest,_that.requiresApproval,_that.status,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnPublisherFollowStatus? subscription,  SnPublisherFollowRequest? followRequest,  bool requiresApproval,  String status,  String message)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherSubscriptionStatus() when $default != null:
return $default(_that.subscription,_that.followRequest,_that.requiresApproval,_that.status,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherSubscriptionStatus implements SnPublisherSubscriptionStatus {
  const _SnPublisherSubscriptionStatus({this.subscription, this.followRequest, this.requiresApproval = false, this.status = 'none', this.message = ''});
  factory _SnPublisherSubscriptionStatus.fromJson(Map<String, dynamic> json) => _$SnPublisherSubscriptionStatusFromJson(json);

@override final  SnPublisherFollowStatus? subscription;
@override final  SnPublisherFollowRequest? followRequest;
@override@JsonKey() final  bool requiresApproval;
@override@JsonKey() final  String status;
@override@JsonKey() final  String message;

/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherSubscriptionStatusCopyWith<_SnPublisherSubscriptionStatus> get copyWith => __$SnPublisherSubscriptionStatusCopyWithImpl<_SnPublisherSubscriptionStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherSubscriptionStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherSubscriptionStatus&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.followRequest, followRequest) || other.followRequest == followRequest)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subscription,followRequest,requiresApproval,status,message);

@override
String toString() {
  return 'SnPublisherSubscriptionStatus(subscription: $subscription, followRequest: $followRequest, requiresApproval: $requiresApproval, status: $status, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherSubscriptionStatusCopyWith<$Res> implements $SnPublisherSubscriptionStatusCopyWith<$Res> {
  factory _$SnPublisherSubscriptionStatusCopyWith(_SnPublisherSubscriptionStatus value, $Res Function(_SnPublisherSubscriptionStatus) _then) = __$SnPublisherSubscriptionStatusCopyWithImpl;
@override @useResult
$Res call({
 SnPublisherFollowStatus? subscription, SnPublisherFollowRequest? followRequest, bool requiresApproval, String status, String message
});


@override $SnPublisherFollowStatusCopyWith<$Res>? get subscription;@override $SnPublisherFollowRequestCopyWith<$Res>? get followRequest;

}
/// @nodoc
class __$SnPublisherSubscriptionStatusCopyWithImpl<$Res>
    implements _$SnPublisherSubscriptionStatusCopyWith<$Res> {
  __$SnPublisherSubscriptionStatusCopyWithImpl(this._self, this._then);

  final _SnPublisherSubscriptionStatus _self;
  final $Res Function(_SnPublisherSubscriptionStatus) _then;

/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscription = freezed,Object? followRequest = freezed,Object? requiresApproval = null,Object? status = null,Object? message = null,}) {
  return _then(_SnPublisherSubscriptionStatus(
subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnPublisherFollowStatus?,followRequest: freezed == followRequest ? _self.followRequest : followRequest // ignore: cast_nullable_to_non_nullable
as SnPublisherFollowRequest?,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherFollowStatusCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SnPublisherFollowStatusCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}/// Create a copy of SnPublisherSubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherFollowRequestCopyWith<$Res>? get followRequest {
    if (_self.followRequest == null) {
    return null;
  }

  return $SnPublisherFollowRequestCopyWith<$Res>(_self.followRequest!, (value) {
    return _then(_self.copyWith(followRequest: value));
  });
}
}

// dart format on
